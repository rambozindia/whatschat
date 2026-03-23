import 'dart:io';
import 'dart:typed_data';

import 'package:docman/docman.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:numstatus/models/status_file.dart';

class SafDirectoryService {
  static const _prefKeyWhatsApp = 'saf_uri_whatsapp';
  static const _prefKeyWhatsAppBusiness = 'saf_uri_whatsapp_business';

  static String _prefKey(String appType) {
    return appType == 'whatsapp_business'
        ? _prefKeyWhatsAppBusiness
        : _prefKeyWhatsApp;
  }

  /// Check if a persisted URI exists and is still valid
  static Future<bool> hasPersistedUri(String appType) async {
    final prefs = await SharedPreferences.getInstance();
    final uri = prefs.getString(_prefKey(appType));
    if (uri == null || uri.isEmpty) return false;

    try {
      final doc = await DocumentFile(uri: uri).get();
      return doc != null && doc.exists && doc.isDirectory;
    } catch (_) {
      await prefs.remove(_prefKey(appType));
      return false;
    }
  }

  /// Get the persisted URI string
  static Future<String?> getPersistedUri(String appType) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefKey(appType));
  }

  /// Launch SAF directory picker
  static Future<String?> pickStatusDirectory(String appType) async {
    try {
      final dir = await DocMan.pick.directory();
      if (dir != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_prefKey(appType), dir.uri);
        return dir.uri;
      }
    } catch (_) {}
    return null;
  }

  /// List status files from persisted directory
  static Future<List<StatusFile>> listFiles(
      String appType, List<String> extensions) async {
    final prefs = await SharedPreferences.getInstance();
    final uri = prefs.getString(_prefKey(appType));
    if (uri == null || uri.isEmpty) return [];

    try {
      final dir = DocumentFile(uri: uri);
      final children = await dir.listDocuments(
        extensions: extensions.map((e) => e.replaceFirst('.', '')).toList(),
      );

      return children
          .where((child) => child.isFile)
          .map((child) => StatusFile(
                uri: child.uri,
                displayName: child.name,
                mimeType: child.type,
                size: child.size,
                lastModified: child.lastModifiedDate,
              ))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Read file bytes from a content URI
  static Future<Uint8List?> readFileBytes(String contentUri) async {
    final doc = DocumentFile(uri: contentUri);
    return await doc.read();
  }

  /// Copy a SAF file to local cache, returning the local File
  static Future<File?> copyToCache(StatusFile file) async {
    if (file.isLocal && file.localPath != null) {
      return File(file.localPath!);
    }
    final doc = DocumentFile(uri: file.uri);
    return await doc.cache();
  }

  /// Get thumbnail file for a document
  static Future<File?> getThumbnailFile(StatusFile file,
      {int width = 256, int height = 256}) async {
    final doc = DocumentFile(uri: file.uri);
    return await doc.thumbnailFile(width: width, height: height, webp: true);
  }

  /// Get available app types that have persisted URIs
  static Future<List<String>> getAvailableApps() async {
    final apps = <String>[];
    if (await hasPersistedUri('whatsapp')) apps.add('whatsapp');
    if (await hasPersistedUri('whatsapp_business')) {
      apps.add('whatsapp_business');
    }
    return apps;
  }

  /// Remove persisted URI
  static Future<void> removePersistedUri(String appType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey(appType));
  }
}
