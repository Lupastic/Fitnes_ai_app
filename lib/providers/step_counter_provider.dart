import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/summary_provider.dart';

class StepCounterProvider with ChangeNotifier {
  final SummaryProvider summaryProvider;
  
  StreamSubscription<StepCount>? _subscription;
  int _lastKnownTotalSteps = -1;
  int _stepsOffset = 0;
  String _status = 'Manual Mode';
  bool _isInitialized = false;

  StepCounterProvider(this.summaryProvider);

  int get todaySteps => summaryProvider.today.steps;
  String get status => _status;

  Future<void> initPedometer() async {
    if (_isInitialized) return;

    final status = await Permission.activityRecognition.request();

    if (status.isGranted) {
      _startListening();
      _status = 'Initialized';
    } else {
      _status = 'Permission Denied';
    }

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _startListening() async {
    print("🚶 StepCounter: Начинаем прослушивание стрима...");
    _subscription = Pedometer.stepCountStream.listen(
      _onStepCount,
      onError: _onStepCountError,
    );
  }

  void _onStepCount(StepCount event) async {
    print("🚶 StepCounter: Получены данные от датчика: ${event.steps} шагов");
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final todayStr = "${now.year}-${now.month}-${now.day}";
    final lastResetDate = prefs.getString('last_step_reset_date') ?? "";

    if (lastResetDate != todayStr) {
      _stepsOffset = event.steps;
      await prefs.setInt('step_offset', _stepsOffset);
      await prefs.setString('last_step_reset_date', todayStr);
      summaryProvider.update(steps: 0);
    } else {
      _stepsOffset = prefs.getInt('step_offset') ?? event.steps;
    }

    int currentTodaySteps = event.steps - _stepsOffset;
    if (currentTodaySteps < 0) {
      _stepsOffset = event.steps;
      await prefs.setInt('step_offset', _stepsOffset);
      currentTodaySteps = 0;
    }

    summaryProvider.update(steps: currentTodaySteps);
    _status = 'Walking';
    notifyListeners();
  }

  void _onStepCountError(error) {
    print("❌ StepCounter Error: $error");
    _status = 'Step Count not available';
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
