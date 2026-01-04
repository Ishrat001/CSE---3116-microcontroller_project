import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SeeStockScreen extends StatefulWidget {
  @override
  _SeeStockState createState() => _SeeStockState();
}

class _SeeStockState extends State<SeeStockScreen> {
  String? selectedDoseTime;
  bool showResult = false;
  List<Map<String, dynamic>> medicines = [];

  Future<void> fetchStock() async {
    if (selectedDoseTime == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(selectedDoseTime!) // morning / day / night
          .get();

      // Null safety check for each document
      medicines = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'medicineName': data['medicineName'] ?? 'Unknown',
          'stock': data['stock']?.toString() ?? '0',
        };
      }).toList();

      setState(() {
        showResult = true;
      });
    } catch (e) {
      print("Error fetching stock: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to fetch stock")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("See Stock"), backgroundColor: Colors.teal),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ---------- Select Dose Time Dropdown ----------
            Text(
              "Choose Dose Time:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Select Time",
              ),
              value: selectedDoseTime,
              items: ["morning", "day", "night"]
                  .map(
                    (time) => DropdownMenuItem(
                      value: time,
                      child: Text(time.toUpperCase()),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedDoseTime = value;
                });
              },
            ),
            SizedBox(height: 20),

            /// ---------- OK Button ----------
            ElevatedButton(
              onPressed: fetchStock,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              child: Text("OK", style: TextStyle(fontSize: 16)),
            ),
            SizedBox(height: 25),

            /// ---------- Display Stock List ----------
            if (showResult)
              Expanded(
                child: medicines.isEmpty
                    ? Center(child: Text("No medicines found"))
                    : ListView.separated(
                        itemCount: medicines.length,
                        separatorBuilder: (_, __) => SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          var med = medicines[index];
                          return Card(
                            elevation: 2,
                            child: ListTile(
                              title: Text(med['medicineName']),
                              subtitle: Text("Stock: ${med['stock']}"),
                            ),
                          );
                        },
                      ),
              ),
          ],
        ),
      ),
    );
  }
}
