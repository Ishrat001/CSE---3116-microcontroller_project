import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'update_stock_page.dart';

class AlertPage extends StatefulWidget {
  @override
  _AlertPageState createState() => _AlertPageState();
}

class _AlertPageState extends State<AlertPage> {
  List<Map<String, dynamic>> lowStockMedicines = [];
  bool loading = false;

  Future<void> loadAlerts() async {
    setState(() => loading = true);

    lowStockMedicines.clear();

    // collections to check
    List<String> doseTimes = ["morning", "day", "night"];

    for (String dose in doseTimes) {
      final snapshot = await FirebaseFirestore.instance
          .collection(dose)
          .where('stock', isLessThan: 5)
          .get();

      for (var doc in snapshot.docs) {
        lowStockMedicines.add({
          "name": doc['medicineName'],
          "stock": doc['stock'],
          "dose": dose,
        });
      }
    }

    setState(() => loading = false);
  }

  @override
  void initState() {
    super.initState();
    loadAlerts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Alert (Low Stock)"),
        backgroundColor: Colors.redAccent,
      ),

      body: Padding(
        padding: EdgeInsets.all(20),

        child: Column(
          children: [
            ElevatedButton(
              onPressed: loadAlerts,
              child: Text("Refresh", style: TextStyle(fontSize: 16)),
            ),

            SizedBox(height: 10),

            Expanded(
              child: loading
                  ? Center(child: CircularProgressIndicator())
                  : lowStockMedicines.isEmpty
                  ? Center(child: Text("No low-stock medicines"))
                  : ListView.builder(
                      itemCount: lowStockMedicines.length,
                      itemBuilder: (context, index) {
                        var med = lowStockMedicines[index];
                        return Card(
                          child: ListTile(
                            title: Text(med['name']),
                            subtitle: Text(
                              "Stock: ${med['stock']} | Dose: ${med['dose']}",
                            ),
                          ),
                        );
                      },
                    ),
            ),

            SizedBox(height: 15),

            /// -------- Update Stock Button --------
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => UpdateStockPage()),
                );
              },
              child: Text("UPDATE STOCK", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
