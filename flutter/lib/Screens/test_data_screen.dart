import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:managment/data/model/add_date.dart';

class TestDataScreen extends StatelessWidget {
  final box = Hive.box<Add_data>('data');

  void addTestData() {
    // Add some test transactions to Hive
    final testTransactions = [
      Add_data('Expand', '30000', DateTime.now().subtract(Duration(days: 1)), 'Coffee shop', 'food'),
      Add_data('Income', '75000', DateTime.now().subtract(Duration(days: 2)), 'Freelance payment', 'Transfer'),
      Add_data('Expand', '20000', DateTime.now(), 'Bus ticket', 'Transportation'),
    ];
    
    for (var transaction in testTransactions) {
      box.add(transaction);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test Data'),
        backgroundColor: Color(0xff368983),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: addTestData,
              child: Text('Add Test Data to Hive'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => box.clear(),
              child: Text('Clear All Hive Data'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
            SizedBox(height: 20),
            Text('Current Hive Data Count: ${box.length}'),
            SizedBox(height: 20),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: box.listenable(),
                builder: (context, Box<Add_data> box, _) {
                  final transactions = box.values.toList();
                  return ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];
                      return ListTile(
                        title: Text('${transaction.name} - ${transaction.amount}'),
                        subtitle: Text('${transaction.explain} • ${transaction.IN}'),
                        trailing: Text(transaction.datetime.toString().split(' ')[0]),
                      );
                    },
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