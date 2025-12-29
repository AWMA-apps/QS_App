import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quantum_space/features/webview/domain/repository/repository_intf.dart';

class WebviewRepositoryImpl extends WebViewRepositoryIntrf {
  @override
  Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      if (await Permission.storage.request().isGranted) return true;
      return await Permission.manageExternalStorage.request().isGranted;
    }
    return true;
  }

  @override
  Future<String?> saveFile(List<int> bytes, String fileName) async {
    try {
      Directory? directory;

      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download/Quantum Space');
      } else {
        directory = await getApplicationDocumentsDirectory();
      }
      if (!await directory.exists()) await directory.create(recursive: true);

      final String filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      return filePath;
    } catch (e) {
      print("Save File Error ❌$e");
    }
    return null;
  }
}
