import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'constants.dart';
import 'status_directory_helper.dart';

class StatusHistory {
  static Future<Directory> _getHistoryDir(String mediaType) async {
    final appDir = await getApplicationDocumentsDirectory();
    final historyDir = Directory('${appDir.path}/status_history/$mediaType');
    if (!historyDir.existsSync()) {
      historyDir.createSync(recursive: true);
    }
    return historyDir;
  }

  static Future<void> cacheCurrentStatuses() async {
    await _cacheMediaType('images', imageExtensions);
    await _cacheMediaType('videos', videoExtensions);
  }

  static Future<void> _cacheMediaType(
      String mediaType, List<String> extensions) async {
    final historyDir = await _getHistoryDir(mediaType);
    final existingFiles =
        historyDir.listSync().map((f) => p.basename(f.path)).toSet();

    for (final appType in statusDirectories.keys) {
      final dirs = getAvailableStatusDirs(appType);
      for (final dir in dirs) {
        try {
          final files = dir
              .listSync()
              .where((item) => extensions
                  .any((ext) => item.path.toLowerCase().endsWith(ext)))
              .toList();

          for (final file in files) {
            final fileName = p.basename(file.path);
            if (!existingFiles.contains(fileName)) {
              try {
                await File(file.path)
                    .copy('${historyDir.path}/$fileName');
              } catch (_) {}
            }
          }
        } catch (_) {}
      }
    }
  }

  static Future<List<String>> getHistoryImages() async {
    final historyDir = await _getHistoryDir('images');
    if (!historyDir.existsSync()) return [];
    return historyDir
        .listSync()
        .map((item) => item.path)
        .where((item) =>
            imageExtensions.any((ext) => item.toLowerCase().endsWith(ext)))
        .toList()
      ..sort((a, b) {
        final aStat = File(a).statSync();
        final bStat = File(b).statSync();
        return bStat.modified.compareTo(aStat.modified);
      });
  }

  static Future<List<String>> getHistoryVideos() async {
    final historyDir = await _getHistoryDir('videos');
    if (!historyDir.existsSync()) return [];
    return historyDir
        .listSync()
        .map((item) => item.path)
        .where((item) =>
            videoExtensions.any((ext) => item.toLowerCase().endsWith(ext)))
        .toList()
      ..sort((a, b) {
        final aStat = File(a).statSync();
        final bStat = File(b).statSync();
        return bStat.modified.compareTo(aStat.modified);
      });
  }

  static Future<int> getCacheSizeBytes() async {
    int totalSize = 0;
    for (final mediaType in ['images', 'videos']) {
      final dir = await _getHistoryDir(mediaType);
      if (dir.existsSync()) {
        for (final file in dir.listSync()) {
          if (file is File) {
            totalSize += await file.length();
          }
        }
      }
    }
    return totalSize;
  }

  static String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1073741824) {
      return '${(bytes / 1048576).toStringAsFixed(1)} MB';
    }
    return '${(bytes / 1073741824).toStringAsFixed(1)} GB';
  }

  static Future<void> clearCache() async {
    for (final mediaType in ['images', 'videos']) {
      final dir = await _getHistoryDir(mediaType);
      if (dir.existsSync()) {
        dir.deleteSync(recursive: true);
        dir.createSync(recursive: true);
      }
    }
  }

  static Future<void> clearOlderThan(int days) async {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    for (final mediaType in ['images', 'videos']) {
      final dir = await _getHistoryDir(mediaType);
      if (dir.existsSync()) {
        for (final file in dir.listSync()) {
          if (file is File) {
            final stat = await file.stat();
            if (stat.modified.isBefore(cutoff)) {
              await file.delete();
            }
          }
        }
      }
    }
  }
}
