import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateStockPage extends StatefulWidget {
  @override
  _UpdateStockPageState createState() => _UpdateStockPageState();
}

class _UpdateStockPageState extends State<UpdateStockPage> {
  final nameController = TextEditingController();
  final stockController = TextEditingController();
  String? selectedDose;

  Future<void> updateStock() async {
    if (nameController.text.isEmpty ||
        stockController.text.isEmpty ||
        selectedDose == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Fill all fields!")));
      return;
    }

    String medName = nameController.text.trim();
    int newStock = int.tryParse(stockController.text.trim()) ?? 0;

    final collection = FirebaseFirestore.instance.collection(selectedDose!);

    final snapshot = await collection
        .where('medicineName', isEqualTo: medName)
        .get();

    if (snapshot.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Medicine not found in $selectedDose")),
      );
      return;
    }

    // Update all matched documents
    for (var doc in snapshot.docs) {
      await collection.doc(doc.id).update({'stock': newStock});
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Stock Updated!")));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Update Stock"),
        backgroundColor: Colors.green,
      ),

      body: Padding(
        padding: EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Medicine Name",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 15),

            TextField(
              controller: stockController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "New Stock",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 15),

            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Dose Time",
              ),
              value: selectedDose,
              items: ["morning", "day", "night"]
                  .map(
                    (t) => DropdownMenuItem(
                      value: t,
                      child: Text(t.toUpperCase()),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                setState(() {
                  selectedDose = v;
                });
              },
            ),

            SizedBox(height: 25),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: updateStock,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                  ),
                  child: Text("UPDATE"),
                ),

                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                  ),
                  child: Text("CANCEL"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
