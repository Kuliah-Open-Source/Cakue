import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import '../config/app_config.dart';
import '../data/model/add_date.dart';

class TransactionService {
  static final box = Hive.box<Add_data>('data');
  
  // Save transaction to both local and remote
  static Future<bool> saveTransaction(Add_data transaction) async {
    try {
      // Save to local Hive first
      await box.add(transaction);
      
      // Try to sync to backend
      await syncToBackend(transaction);
      
      return true;
    } catch (e) {
      print('Error saving transaction: $e');
      return false;
    }
  }
  
  // Sync single transaction to backend
  static Future<bool> syncToBackend(Add_data transaction) async {
    try {
      print('Syncing transaction: ${transaction.name} - ${transaction.amount}');
      
      // Map category names to IDs
      Map<String, int> categoryMap = {
        'food': 13,
        'Transfer': 16,
        'Transportation': 14,
        'Education': 15,
      };
      
      final categoryId = categoryMap[transaction.name] ?? 13;
      final transactionType = transaction.IN == 'Income' ? 'income' : 'expense';
      final dateStr = transaction.datetime.toIso8601String().split('T')[0];
      
      // Use GET request with query parameters (simpler for testing)
      final uri = Uri.parse('${AppConfig.apiUrl}/transactions-simple').replace(
        queryParameters: {
          'account_id': '3',
          'category_id': categoryId.toString(),
          'amount': transaction.amount,
          'type': transactionType,
          'description': transaction.explain.isNotEmpty ? transaction.explain : 'No description',
          'transaction_date': dateStr,
        },
      );
      
      print('Request URL: $uri');
      
      final response = await http.get(uri);
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      
      return false;
    } catch (e) {
      print('Error syncing to backend: $e');
      return false;
    }
  }
  
  // Sync all local transactions to backend
  static Future<int> syncAllToBackend() async {
    int syncedCount = 0;
    final transactions = box.values.toList();
    
    for (var transaction in transactions) {
      if (await syncToBackend(transaction)) {
        syncedCount++;
      }
    }
    
    return syncedCount;
  }
  
  // Get transaction count comparison
  static Future<Map<String, int>> getTransactionCounts() async {
    try {
      final localCount = box.length;
      
      // Get remote count from MySQL
      final response = await http.get(
        Uri.parse('${AppConfig.apiUrl}/transactions-count'),
      );
      
      int remoteCount = 0;
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        remoteCount = data['count'] ?? 0;
      }
      
      return {
        'local': localCount,
        'remote': remoteCount,
      };
    } catch (e) {
      print('Error getting counts: $e');
      return {
        'local': box.length,
        'remote': 0,
      };
    }
  }
}