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
  String _status = 'Unknown';
  bool _isInitialized = false;

  StepCounterProvider(this.summaryProvider);

  int get todaySteps => summaryProvider.today.steps;
  String get status => _status;

  Future<void> initPedometer() async {
    if (_isInitialized) return;
    
    // 1. Запрос разрешений
    if (await Permission.activityRecognition.request().isGranted) {
      _startListening();
    } else {
      _status = 'Permission Denied';
      notifyListeners();
    }
    _isInitialized = true;
  }

  void _startListening() {
    _subscription = Pedometer.stepCountStream.listen(
      _onStepCount,
      onError: _onStepCountError,
    );
  }

  void _onStepCount(StepCount event) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final todayStr = "${now.year}-${now.month}-${now.day}";
    final lastResetDate = prefs.getString('last_step_reset_date') ?? "";

    // 2. Логика сброса в полночь
    if (lastResetDate != todayStr) {
      // Наступил новый день
      _stepsOffset = event.steps;
      await prefs.setInt('step_offset', _stepsOffset);
      await prefs.setString('last_step_reset_date', todayStr);
      
      // Обнуляем шаги в SummaryProvider для нового дня
      summaryProvider.update(steps: 0);
    } else {
      _stepsOffset = prefs.getInt('step_offset') ?? event.steps;
    }

    // 3. Вычисление шагов за сегодня
    // Датчик возвращает шаги с момента загрузки телефона, поэтому вычитаем смещение
    int currentTodaySteps = event.steps - _stepsOffset;
    if (currentTodaySteps < 0) {
      // Если телефон перезагрузился, смещение станет неверным
      _stepsOffset = event.steps;
      await prefs.setInt('step_offset', _stepsOffset);
      currentTodaySteps = 0;
    }

    // Обновляем данные в провайдере (который сам сохранит их в Hive и Firestore)
    summaryProvider.update(steps: currentTodaySteps);
    _status = 'Walking';
    notifyListeners();
  }

  void _onStepCountError(error) {
    _status = 'Step Count not available';
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
