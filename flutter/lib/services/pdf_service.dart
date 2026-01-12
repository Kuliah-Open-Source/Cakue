import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import '../config/app_config.dart';

class PdfService {
  static Future<bool> downloadFinancialReport({
    required String startDate,
    required String endDate,
    String? token,
  }) async {
    try {
      // Request storage permission
      if (Platform.isAndroid) {
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          status = await Permission.storage.request();
          if (!status.isGranted) {
            throw Exception('Storage permission denied');
          }
        }
      }

      // Make API request
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/finance/pdf-test?startDate=$startDate&endDate=$endDate'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Get downloads directory
        Directory? directory;
        if (Platform.isAndroid) {
          directory = await getExternalStorageDirectory();
        } else {
          directory = await getApplicationDocumentsDirectory();
        }

        if (directory == null) {
          throw Exception('Could not access storage directory');
        }

        // Create file path
        final fileName = 'financial-report-$startDate-to-$endDate.pdf';
        final filePath = '${directory.path}/$fileName';
        
        // Write file
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        // Open file
        await OpenFile.open(filePath);
        
        return true;
      } else {
        throw Exception('Failed to download PDF: ${response.statusCode}');
      }
    } catch (e) {
      print('PDF download error: $e');
      return false;
    }
  }
}