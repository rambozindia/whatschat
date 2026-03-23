import 'dart:io';
import 'dart:typed_data';

import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path_provider/path_provider.dart';

Future<bool> saveImageToGallery(String imgPath) async {
  try {
    File originalImageFile = File(imgPath);
    Uint8List bytes = await originalImageFile.readAsBytes();
    await ImageGallerySaverPlus.saveImage(Uint8List.fromList(bytes));
    return true;
  } catch (e) {
    return false;
  }
}

Future<bool> saveVideoToStorage(String videoPath) async {
  try {
    File originalVideoFile = File(videoPath);
    Directory? directory = await getExternalStorageDirectory();
    if (directory == null) return false;

    String videoDir = "${directory.path}/Downloaded Status/Videos";
    if (!Directory(videoDir).existsSync()) {
      Directory(videoDir).createSync(recursive: true);
    }

    String curDate = DateTime.now().millisecondsSinceEpoch.toString();
    String newFileName = "$videoDir/VIDEO-$curDate.mp4";
    await originalVideoFile.copy(newFileName);
    return true;
  } catch (e) {
    return false;
  }
}

Future<Map<String, int>> bulkSaveImages(
    List<String> paths, Function(int done, int total)? onProgress) async {
  int success = 0;
  int failed = 0;
  for (int i = 0; i < paths.length; i++) {
    bool saved = await saveImageToGallery(paths[i]);
    if (saved) {
      success++;
    } else {
      failed++;
    }
    onProgress?.call(i + 1, paths.length);
  }
  return {'success': success, 'failed': failed};
}

Future<Map<String, int>> bulkSaveVideos(
    List<String> paths, Function(int done, int total)? onProgress) async {
  int success = 0;
  int failed = 0;
  for (int i = 0; i < paths.length; i++) {
    bool saved = await saveVideoToStorage(paths[i]);
    if (saved) {
      success++;
    } else {
      failed++;
    }
    onProgress?.call(i + 1, paths.length);
  }
  return {'success': success, 'failed': failed};
}
