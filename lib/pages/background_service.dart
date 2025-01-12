import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

void onStart(ServiceInstance service) async {
  // Initialize preferences
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int remainingTime = prefs.getInt('remainingTime') ?? 0;

  // Keep the service alive
  service.on('startTimer').listen((event) async {
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (remainingTime > 0) {
        remainingTime--;
        prefs.setInt('remainingTime', remainingTime);

        // Send updates to the foreground app
        service.invoke('update', {'remainingTime': remainingTime});
      } else {
        timer.cancel();
      }
    });
  });

  // Listen for stop requests
  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  if (service is AndroidServiceInstance) {
    service.setForegroundNotificationInfo(
      title: "Timer Running",
      content: "Your timer is currently active.",
    );
  }
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
    ),
    iosConfiguration: IosConfiguration(
      onForeground: onStart,
      autoStart: true,
    ),
  );

  await service.startService();
}
