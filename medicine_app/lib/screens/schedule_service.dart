import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'notification_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';

class ScheduleService {
  static String? _lastTriggeredTime; // একই মিনিটে বারবার ট্রিগার হওয়া আটকাবে

  static void startScheduler() {
    Timer.periodic(Duration(seconds: 30), (timer) async {
      await checkMedicineSchedule();
    });
  }

  static Future<void> checkMedicineSchedule() async {
    List<String> doses = ["morning", "day", "night"];
    DateTime now = DateTime.now();
    // বর্তমান সময়কে "10:10 AM" ফরম্যাটে নিয়ে আসা
    String currentTimeString = "${now.hour}:${now.minute}";

    for (String dose in doses) {
      var snapshot = await FirebaseFirestore.instance.collection(dose).get();

      for (var doc in snapshot.docs) {
        var data = doc.data();
        String medName = data["medicineName"];
        String takingTime = data["time"]; // e.g. "10:10 AM"

        DateTime target = convertToDateTime(takingTime);

        // সময় মিলে গেলে এবং ওই মিনিটের জন্য আগে পাঠানো না হয়ে থাকলে
        if (now.hour == target.hour && now.minute == target.minute) {
          String triggerKey = "${medName}_${target.hour}_${target.minute}";

          if (_lastTriggeredTime != triggerKey) {
            _lastTriggeredTime = triggerKey;

            // ESP32-কে কমান্ড পাঠানো
            await sendToESP(medName, dose, takingTime);

            // স্টক কমানো
            int stock = data["stock"];
            if (stock > 0) {
              await FirebaseFirestore.instance
                  .collection(dose)
                  .doc(doc.id)
                  .update({"stock": stock - 1});
            }
          }
        }
      }
    }
  }

  static DateTime convertToDateTime(String timeStr) {
    final now = DateTime.now();
    final parts = timeStr.split(RegExp(r'[: ]'));
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);
    String period = parts[2];

    if (period.toUpperCase() == 'PM' && hour != 12) hour += 12;
    if (period.toUpperCase() == 'AM' && hour == 12) hour = 0;

    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  static Future<void> sendToESP(String name, String dose, String time) async {
    try {
      // আপনার নির্দিষ্ট রিলেশনাল ডেটাবেস URL
      final String databaseUrl =
          "https://medismart-37b87-default-rtdb.asia-southeast1.firebasedatabase.app/";

      DatabaseReference ref = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: databaseUrl,
      ).ref("pill_trigger");

      await ref.set({
        "medicine_name": name,
        "dose_type": dose,
        "timestamp": ServerValue.timestamp,
        "status": "pending",
      });

      print("Firebase-এ সফলভাবে কমান্ড পাঠানো হয়েছে: $name");
      await _showLocalNotification("$name খাওয়ার সময় হয়েছে", dose, time);
    } catch (e) {
      print("Firebase Update Error: $e");
    }
  }

  static Future<void> _showLocalNotification(
    String message,
    String dose,
    String time,
  ) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'med_channel',
          'Medicine Notifications',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        );
    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );
    await flutterLocalNotificationsPlugin.show(
      0,
      'Medicine Alert',
      message,
      platformDetails,
    );
  }
}
