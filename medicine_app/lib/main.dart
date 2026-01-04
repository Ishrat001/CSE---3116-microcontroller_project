import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/welcome_screen.dart';
import 'screens/add_medicine.dart';
import 'screens/delete_medicine.dart';
import 'screens/see_stock.dart';
import 'screens/alert_screen.dart';
import 'screens/notification_screen.dart';
import 'screens/notification_service.dart';
import 'screens/schedule_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initNotifications(); // Initialize local notifications

  // নতুন যোগ করা লিসেনার যা ESP32-এর ফিডব্যাক শুনবে
  startListeningToESP32();

  // Start background scheduler for ESP32 / medicine notifications
  ScheduleService.startScheduler();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Medicine Dispenser",
      theme: ThemeData(primarySwatch: Colors.blue),
      home: WelcomeScreen(),
      routes: {
        "/add": (_) => AddMedicineScreen(),
        "/delete": (_) => DeleteMedicineScreen(),
        "/stock": (_) => SeeStockScreen(),
        "/alerts": (_) => AlertPage(),
        "/notifications": (_) => NotificationScreen(),
      },
    );
  }
}
