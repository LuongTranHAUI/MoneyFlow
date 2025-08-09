import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

void main() async {
  // Get the database directory
  final dbFolder = await getApplicationDocumentsDirectory();
  final file = File(path.join(dbFolder.path, 'app_database.db'));
  
  if (await file.exists()) {
    await file.delete();
    print('Database deleted successfully at: ${file.path}');
  } else {
    print('Database file not found');
  }
  
  // Also try common locations
  final commonPaths = [
    'app_database.db',
    'database.db',
    'finance_tracker.db',
  ];
  
  for (final dbName in commonPaths) {
    final dbFile = File(path.join(dbFolder.path, dbName));
    if (await dbFile.exists()) {
      await dbFile.delete();
      print('Deleted: ${dbFile.path}');
    }
  }
  
  print('Database reset complete. Please restart the app.');
}