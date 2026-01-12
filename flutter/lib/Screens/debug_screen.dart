import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:managment/data/model/add_date.dart';
import 'package:managment/data/utlity.dart';

class DebugScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Debug Data'),
        backgroundColor: Color.fromARGB(255, 47, 125, 121),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Add_data>('data').listenable(),
        builder: (context, Box<Add_data> box, _) {
          final allData = box.values.toList();
          final todayData = today();
          final weekData = week();
          final monthData = month();
          final yearData = year();
          
          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection('Total Data', allData.length.toString()),
                _buildSection('Today Data', todayData.length.toString()),
                _buildSection('Week Data', weekData.length.toString()),
                _buildSection('Month Data', monthData.length.toString()),
                _buildSection('Year Data', yearData.length.toString()),
                
                SizedBox(height: 20),
                Text('All Transactions:', 
                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                
                ...allData.map((data) => Card(
                  child: ListTile(
                    title: Text('${data.name} - ${data.amount}'),
                    subtitle: Text('${data.IN} - ${data.datetime}'),
                    trailing: Text(data.explain),
                  ),
                )).toList(),
                
                if (allData.isEmpty)
                  Container(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        'No data found in Hive database.\nAdd some transactions first.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildSection(String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(fontSize: 16, color: Colors.blue)),
        ],
      ),
    );
  }
}