import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddMedicineScreen extends StatefulWidget {
  @override
  _AddMedicineScreenState createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();

  TimeOfDay? _selectedTime;
  String _doseTime = "morning"; // default dropdown value

  // PICK TIME
  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  // FIREBASE ADD FUNCTION
  Future<void> _addMedicine() async {
    if (_nameController.text.isEmpty ||
        _stockController.text.isEmpty ||
        _selectedTime == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Please fill all fields.")));
      return;
    }

    final timeString =
        "${_selectedTime!.hourOfPeriod}:${_selectedTime!.minute.toString().padLeft(2, '0')} ${_selectedTime!.period == DayPeriod.am ? 'AM' : 'PM'}";

    await FirebaseFirestore.instance
        .collection(_doseTime) // morning/day/night
        .doc(_nameController.text) // medicine name as doc ID
        .set({
          "medicineName": _nameController.text,
          "stock": int.parse(_stockController.text),
          "time": timeString,
        });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Medicine Added Successfully!")));

    Navigator.pop(context); // back to home
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Medicine"), centerTitle: true),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // MEDICINE NAME
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Medicine Name",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 20),

            // STOCK
            TextField(
              controller: _stockController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Stock (e.g., 10, 20)",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 20),

            // TIME PICKER
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedTime == null
                        ? "Select Taking Time"
                        : "Time: ${_selectedTime!.format(context)}",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                ElevatedButton(onPressed: _pickTime, child: Text("Pick Time")),
              ],
            ),

            SizedBox(height: 20),

            // DOSE TIME DROPDOWN
            DropdownButtonFormField(
              value: _doseTime,
              items: [
                DropdownMenuItem(value: "morning", child: Text("Morning")),
                DropdownMenuItem(value: "day", child: Text("Day")),
                DropdownMenuItem(value: "night", child: Text("Night")),
              ],
              onChanged: (value) {
                setState(() {
                  _doseTime = value.toString();
                });
              },
              decoration: InputDecoration(
                labelText: "Choose Dose Time",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 30),

            // BUTTONS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _addMedicine,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  ),
                  child: Text("Add", style: TextStyle(fontSize: 18)),
                ),

                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  ),
                  child: Text("Cancel", style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
