import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/summary_provider.dart';

class StepCounterProvider with ChangeNotifier {
  final SummaryProvider summaryProvider;
  
  StreamSubscription<StepCount>? _subscription;
  int _stepsOffset = 0;
  String _status = 'Initializing...';
  bool _isInitialized = false;

  StepCounterProvider(this.summaryProvider);

  int get todaySteps => summaryProvider.today.steps;
  String get status => _status;

  Future<void> initPedometer() async {
    if (_isInitialized) return;
    
    debugPrint("Initializing Pedometer...");
    _status = 'Requesting Permissions...';
    notifyListeners();

    // Check if permission is already granted
    var status = await Permission.activityRecognition.status;
    debugPrint("Current Activity Recognition status: $status");

    if (!status.isGranted) {
      status = await Permission.activityRecognition.request();
      debugPrint("New Activity Recognition status: $status");
    }
    
    if (status.isGranted) {
      _startListening();
      _isInitialized = true;
    } else {
      _status = 'Permission Denied ($status)';
      debugPrint("Pedometer failed: Permission Denied");
      notifyListeners();
    }
  }

  void _startListening() {
    debugPrint("Starting step count stream...");
    _status = 'Connecting to sensor...';
    notifyListeners();
    
    _subscription = Pedometer.stepCountStream.listen(
      (event) {
        debugPrint("StepCount Event received: ${event.steps} total steps");
        _onStepCount(event);
      },
      onError: (error) {
        debugPrint("StepCount Stream Error: $error");
        _onStepCountError(error);
      },
      cancelOnError: false,
    );
  }

  int _lastStepsUpdate = -1;
  final int _updateThreshold = 10; 

  void _onStepCount(StepCount event) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final todayStr = "${now.year}-${now.month}-${now.day}";
    final lastResetDate = prefs.getString('last_step_reset_date') ?? "";

    if (lastResetDate != todayStr) {
      debugPrint("New day detected in StepCounter. Resetting offset to ${event.steps}");
      _stepsOffset = event.steps;
      await prefs.setInt('step_offset', _stepsOffset);
      await prefs.setString('last_step_reset_date', todayStr);
      summaryProvider.update(steps: 0);
      _lastStepsUpdate = 0;
    } else {
      _stepsOffset = prefs.getInt('step_offset') ?? event.steps;
    }

    int currentTodaySteps = event.steps - _stepsOffset;
    
    if (currentTodaySteps < 0) {
      debugPrint("Negative steps detected (reboot?). Resetting offset.");
      _stepsOffset = event.steps;
      await prefs.setInt('step_offset', _stepsOffset);
      currentTodaySteps = 0;
    }

    // Update if first time or exceeded threshold
    if (_lastStepsUpdate == -1 || (currentTodaySteps - _lastStepsUpdate).abs() >= _updateThreshold) {
      debugPrint("Updating SummaryProvider with $currentTodaySteps steps");
      summaryProvider.update(steps: currentTodaySteps);
      _lastStepsUpdate = currentTodaySteps;
    }

    _status = 'Active';
    notifyListeners();
  }

  void _onStepCountError(error) {
    debugPrint("Pedometer Error: $error");
    _status = 'Step sensor unavailable';
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
