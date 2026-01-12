import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:managment/data/model/add_date.dart';
import 'package:managment/services/transaction_service.dart';

class SyncStatusScreen extends StatefulWidget {
  @override
  _SyncStatusScreenState createState() => _SyncStatusScreenState();
}

class _SyncStatusScreenState extends State<SyncStatusScreen> {
  Map<String, int> counts = {'local': 0, 'remote': 0};
  bool isLoading = true;
  bool isSyncing = false;

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    setState(() => isLoading = true);
    final result = await TransactionService.getTransactionCounts();
    setState(() {
      counts = result;
      isLoading = false;
    });
  }

  Future<void> _syncAll() async {
    setState(() => isSyncing = true);
    final syncedCount = await TransactionService.syncAllToBackend();
    setState(() => isSyncing = false);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Synced $syncedCount transactions'),
        backgroundColor: Colors.green,
      ),
    );
    
    _loadCounts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sync Status'),
        backgroundColor: Color(0xff368983),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Transaction Count Analysis',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    if (isLoading)
                      CircularProgressIndicator()
                    else ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Local (Hive):'),
                          Text(
                            '${counts['local']} transactions',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Remote (MySQL):'),
                          Text(
                            '${counts['remote']} transactions',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Sync Status:'),
                          Text(
                            counts['local'] == counts['remote'] 
                                ? 'In Sync ✅' 
                                : 'Out of Sync ⚠️',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: counts['local'] == counts['remote'] 
                                  ? Colors.green 
                                  : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSyncing ? null : _syncAll,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff368983),
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                child: isSyncing
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          ),
                          SizedBox(width: 10),
                          Text('Syncing...', style: TextStyle(color: Colors.white)),
                        ],
                      )
                    : Text('Sync All to Backend', style: TextStyle(color: Colors.white)),
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loadCounts,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[600],
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                child: Text('Refresh Status', style: TextStyle(color: Colors.white)),
              ),
            ),
            SizedBox(height: 30),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: Hive.box<Add_data>('data').listenable(),
                builder: (context, Box<Add_data> box, _) {
                  final transactions = box.values.toList();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Local Transactions (${transactions.length}):',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          itemCount: transactions.length,
                          itemBuilder: (context, index) {
                            final transaction = transactions[index];
                            return Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: transaction.IN == 'Income' 
                                      ? Colors.green 
                                      : Colors.red,
                                  child: Text(
                                    transaction.IN == 'Income' ? '+' : '-',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                title: Text('${transaction.name} - ${transaction.amount}'),
                                subtitle: Text(
                                  '${transaction.explain} • ${transaction.datetime.toString().split(' ')[0]}',
                                ),
                                trailing: Text(transaction.IN),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
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