import 'dart:io';
import 'dart:typed_data';

import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path_provider/path_provider.dart';

import 'package:numstatus/models/status_file.dart';
import 'package:numstatus/services/saf_directory_service.dart';

Future<bool> saveImageToGallery(StatusFile file) async {
  try {
    final bytes = await SafDirectoryService.readFileBytes(file.uri);
    if (bytes == null) return false;
    await ImageGallerySaverPlus.saveImage(Uint8List.fromList(bytes));
    return true;
  } catch (e) {
    return false;
  }
}

Future<bool> saveVideoToStorage(StatusFile file) async {
  try {
    final cachedFile = await SafDirectoryService.copyToCache(file);
    if (cachedFile == null) return false;

    Directory? directory = await getExternalStorageDirectory();
    if (directory == null) return false;

    String videoDir = "${directory.path}/Downloaded Status/Videos";
    if (!Directory(videoDir).existsSync()) {
      Directory(videoDir).createSync(recursive: true);
    }

    String curDate = DateTime.now().millisecondsSinceEpoch.toString();
    String newFileName = "$videoDir/VIDEO-$curDate.mp4";
    await cachedFile.copy(newFileName);
    return true;
  } catch (e) {
    return false;
  }
}

Future<Map<String, int>> bulkSaveImages(
    List<StatusFile> files, Function(int done, int total)? onProgress) async {
  int success = 0;
  int failed = 0;
  for (int i = 0; i < files.length; i++) {
    bool saved = await saveImageToGallery(files[i]);
    if (saved) {
      success++;
    } else {
      failed++;
    }
    onProgress?.call(i + 1, files.length);
  }
  return {'success': success, 'failed': failed};
}

Future<Map<String, int>> bulkSaveVideos(
    List<StatusFile> files, Function(int done, int total)? onProgress) async {
  int success = 0;
  int failed = 0;
  for (int i = 0; i < files.length; i++) {
    bool saved = await saveVideoToStorage(files[i]);
    if (saved) {
      success++;
    } else {
      failed++;
    }
    onProgress?.call(i + 1, files.length);
  }
  return {'success': success, 'failed': failed};
}
