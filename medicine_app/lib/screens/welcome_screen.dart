import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Medicine Dispenser"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Welcome! Choose an option.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),

            SizedBox(height: 30),

            _menuButton(
              context,
              Icons.add,
              "Add Medicine",
              Colors.green,
              () => Navigator.pushNamed(context, "/add"),
            ),

            _menuButton(
              context,
              Icons.delete,
              "Delete Medicine",
              Colors.red,
              () => Navigator.pushNamed(context, "/delete"),
            ),

            _menuButton(
              context,
              Icons.inventory,
              "See Stock",
              Colors.blue,
              () => Navigator.pushNamed(context, "/stock"),
            ),

            _menuButton(
              context,
              Icons.warning_amber_rounded,
              "Alerts",
              Colors.orange,
              () => Navigator.pushNamed(context, "/alerts"),
            ),

            _menuButton(
              context,
              Icons.notifications,
              "Notifications",
              Colors.purple,
              () => Navigator.pushNamed(context, "/notifications"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuButton(
    BuildContext context,
    IconData icon,
    String text,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 30),
        label: Text(text, style: TextStyle(fontSize: 18)),
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
