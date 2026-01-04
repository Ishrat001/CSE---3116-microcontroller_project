import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

void startListeningToESP32() {
  final String databaseUrl =
      "https://medismart-37b87-default-rtdb.asia-southeast1.firebasedatabase.app/";

  DatabaseReference statusRef = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: databaseUrl,
  ).ref('pill_trigger/status');

  statusRef.onValue.listen((DatabaseEvent event) {
    if (event.snapshot.exists) {
      String status = event.snapshot.value.toString();
      if (status == "taken") {
        _showDispensedNotification(
          "Medicine Dispensed!",
          "আপনার ঔষধটি মেশিন থেকে বের করা হয়েছে। দয়া করে গ্রহণ করুন।",
        );
        // স্ট্যাটাস রিসেট করে 'idle' করে দেওয়া
        statusRef.set("idle");
      }
    }
  });
}

Future<void> _showDispensedNotification(String title, String body) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'esp32_channel',
    'ESP32 Status',
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
  );
  const NotificationDetails platformDetails = NotificationDetails(
    android: androidDetails,
  );
  await flutterLocalNotificationsPlugin.show(101, title, body, platformDetails);
}
