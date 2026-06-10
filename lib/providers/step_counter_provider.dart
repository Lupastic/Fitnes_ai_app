import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/summary_provider.dart';
import 'dart:developer' as developer;

class StepCounterProvider with ChangeNotifier {
  final SummaryProvider summaryProvider;
  
  StreamSubscription<StepCount>? _subscription;
  int _lastSensorSteps = -1;
  String _status = 'Initializing...';
  bool _isInitialized = false;

  StepCounterProvider(this.summaryProvider);

  String get status => _status;

  Future<void> initPedometer() async {
    if (_isInitialized) return;

    final status = await Permission.activityRecognition.request();

    if (status.isGranted) {
      _startListening();
      _status = 'Active';
    } else {
      _status = 'Permission Denied';
    }

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _startListening() async {
    developer.log("🚶 StepCounter: Starting pedometer stream...", name: "StepCounter");
    _subscription = Pedometer.stepCountStream.listen(
      _onStepCount,
      onError: _onStepCountError,
    );
  }

  void _onStepCount(StepCount event) async {
    developer.log("🚶 Sensor steps: ${event.steps}", name: "StepCounter");
    
    final prefs = await SharedPreferences.getInstance();
    
    // 1. Initial run or sensor reset
    if (_lastSensorSteps == -1) {
      _lastSensorSteps = prefs.getInt('last_sensor_total') ?? event.steps;
    }

    // 2. Calculate delta
    int delta = event.steps - _lastSensorSteps;

    // 3. Handle sensor reset (e.g., phone reboot)
    if (delta < 0) {
      developer.log("🔄 Sensor reset detected (Total decreased from $_lastSensorSteps to ${event.steps})", name: "StepCounter");
      _lastSensorSteps = event.steps;
      await prefs.setInt('last_sensor_total', _lastSensorSteps);
      return;
    }

    // 4. If we have new steps, add them to the daily total
    if (delta > 0) {
      developer.log("👣 Adding $delta steps to total", name: "StepCounter");
      
      // Update the daily summary by ADDING the delta
      summaryProvider.update(steps: delta, add: true);
      
      _lastSensorSteps = event.steps;
      await prefs.setInt('last_sensor_total', _lastSensorSteps);
      
      _status = 'Walking';
      notifyListeners();
    }
  }

  void _onStepCountError(error) {
    developer.log("❌ StepCounter Error: $error", name: "StepCounter");
    _status = 'Hardware error';
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
