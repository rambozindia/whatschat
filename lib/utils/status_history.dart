import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'package:numstatus/utils/constants.dart';
import 'package:numstatus/services/saf_directory_service.dart';
import 'package:numstatus/utils/status_directory_helper.dart';

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
    try {
      final apps = await getAvailableApps();
      for (final appType in apps) {
        await _cacheMediaForApp(appType, 'images', imageExtensions);
        await _cacheMediaForApp(appType, 'videos', videoExtensions);
      }
    } catch (_) {}
  }

  static Future<void> _cacheMediaForApp(
      String appType, String mediaType, List<String> extensions) async {
    final historyDir = await _getHistoryDir(mediaType);
    final existingFiles =
        historyDir.listSync().map((f) => p.basename(f.path)).toSet();

    final files =
        await SafDirectoryService.listFiles(appType, extensions);

    for (final file in files) {
      if (!existingFiles.contains(file.displayName)) {
        try {
          final bytes = await SafDirectoryService.readFileBytes(file.uri);
          if (bytes != null) {
            await File('${historyDir.path}/${file.displayName}')
                .writeAsBytes(bytes);
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
