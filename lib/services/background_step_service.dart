import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:pedometer/pedometer.dart';

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      foregroundServiceNotificationId: 999,
      initialNotificationTitle: 'Fitness AI',
      initialNotificationContent: 'Step counter is running',
    ),
    iosConfiguration: IosConfiguration(),
  );

  service.startService();
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) {
  if (service is AndroidServiceInstance) {
    service.setAsForegroundService();
  }

  Pedometer.stepCountStream.listen((event) {
    print("BACKGROUND STEPS: ${event.steps}");

    service.invoke(
      'step_update',
      {
        "steps": event.steps,
      },
    );
  });
}