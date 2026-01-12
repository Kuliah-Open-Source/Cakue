import 'package:hive/hive.dart';
import 'package:managment/data/model/add_date.dart';

int totals = 0;

final box = Hive.box<Add_data>('data');

int total() {
  var history2 = box.values.toList();
  List a = [0, 0];
  for (var i = 0; i < history2.length; i++) {
    a.add(history2[i].IN == 'Income'
        ? int.parse(history2[i].amount)
        : int.parse(history2[i].amount) * -1);
  }
  totals = a.reduce((value, element) => value + element);
  return totals;
}

int income() {
  var history2 = box.values.toList();
  List a = [0, 0];
  for (var i = 0; i < history2.length; i++) {
    a.add(history2[i].IN == 'Income' ? int.parse(history2[i].amount) : 0);
  }
  totals = a.reduce((value, element) => value + element);
  return totals;
}

int expenses() {
  var history2 = box.values.toList();
  List a = [0, 0];
  for (var i = 0; i < history2.length; i++) {
    a.add(history2[i].IN == 'Income' ? 0 : int.parse(history2[i].amount) * -1);
  }
  totals = a.reduce((value, element) => value + element);
  return totals;
}

List<Add_data> today() {
  List<Add_data> a = [];
  var history2 = box.values.toList();
  DateTime date = DateTime.now();
  
  for (var i = 0; i < history2.length; i++) {
    if (history2[i].datetime.day == date.day &&
        history2[i].datetime.month == date.month &&
        history2[i].datetime.year == date.year) {
      a.add(history2[i]);
    }
  }
  print('Today data count: ${a.length}');
  return a;
}

List<Add_data> week() {
  List<Add_data> a = [];
  DateTime date = DateTime.now();
  DateTime weekStart = date.subtract(Duration(days: 7));
  var history2 = box.values.toList();
  
  for (var i = 0; i < history2.length; i++) {
    if (history2[i].datetime.isAfter(weekStart) && 
        history2[i].datetime.isBefore(date.add(Duration(days: 1)))) {
      a.add(history2[i]);
    }
  }
  return a;
}

List<Add_data> month() {
  List<Add_data> a = [];
  var history2 = box.values.toList();
  DateTime date = new DateTime.now();
  for (var i = 0; i < history2.length; i++) {
    if (history2[i].datetime.month == date.month) {
      a.add(history2[i]);
    }
  }
  return a;
}

List<Add_data> year() {
  List<Add_data> a = [];
  var history2 = box.values.toList();
  DateTime date = new DateTime.now();
  for (var i = 0; i < history2.length; i++) {
    if (history2[i].datetime.year == date.year) {
      a.add(history2[i]);
    }
  }
  return a;
}

int total_chart(List<Add_data> history2) {
  List a = [0, 0];

  for (var i = 0; i < history2.length; i++) {
    a.add(history2[i].IN == 'Income'
        ? int.parse(history2[i].amount)
        : int.parse(history2[i].amount) * -1);
  }
  totals = a.reduce((value, element) => value + element);
  return totals;
}

List time(List<Add_data> history2, bool hour) {
  if (history2.isEmpty) return [];
  
  Map<String, int> groupedData = {};
  
  for (var transaction in history2) {
    String key;
    if (hour) {
      key = transaction.datetime.hour.toString();
    } else {
      key = transaction.datetime.day.toString();
    }
    
    int amount = int.parse(transaction.amount);
    if (transaction.IN != 'Income') {
      amount = -amount; // Expenses are negative
    }
    
    groupedData[key] = (groupedData[key] ?? 0) + amount;
  }
  
  List<int> result = groupedData.values.toList();
  print('Time function result: $result');
  return result;
}
