import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class CsvExportHelper {
  static Future<void> exportToCsv({
    required String fileName,
    required List<String> headers,
    required List<List<dynamic>> data,
  }) async {
    try {
      // Convert to CSV
      final csvData = [
        headers,
        ...data,
      ];
      final String csvString = const ListToCsvConverter().convert(csvData);

      // Get temp directory
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/$fileName.csv';
      final file = File(path);

      // Write to file
      await file.writeAsString(csvString);

      // Share file
      await Share.shareXFiles([XFile(path)], text: 'Export CSV: $fileName');
    } catch (e) {
      print('Error exporting CSV: $e');
      rethrow;
    }
  }
}
