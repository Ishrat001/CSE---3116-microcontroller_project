import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DeleteMedicineScreen extends StatefulWidget {
  @override
  _DeleteMedicineScreenState createState() => _DeleteMedicineScreenState();
}

class _DeleteMedicineScreenState extends State<DeleteMedicineScreen> {
  final TextEditingController _nameController = TextEditingController();
  String _doseTime = "morning"; // default value

  // DELETE FUNCTION
  Future<void> _deleteMedicine() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Please enter medicine name.")));
      return;
    }

    String medName = _nameController.text.trim();

    try {
      await FirebaseFirestore.instance
          .collection(_doseTime)
          .doc(medName)
          .delete();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Medicine deleted successfully!")));

      Navigator.pop(context); // back to home
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error deleting medicine: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Delete Medicine"), centerTitle: true),

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

            // DOSE TIME DROPDOWN
            DropdownButtonFormField(
              value: _doseTime,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Choose Dose Time",
              ),
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
            ),

            SizedBox(height: 30),

            // BUTTONS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _deleteMedicine,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  ),
                  child: Text("Delete", style: TextStyle(fontSize: 18)),
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
