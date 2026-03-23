import 'dart:io';

import 'constants.dart';

List<Directory> getAvailableStatusDirs(String appType) {
  final dirs = statusDirectories[appType] ?? [];
  return dirs.where((dir) => dir.existsSync()).toList();
}

List<String> getStatusImages(String appType) {
  final dirs = getAvailableStatusDirs(appType);
  final List<String> images = [];
  for (final dir in dirs) {
    images.addAll(dir
        .listSync()
        .map((item) => item.path)
        .where((item) =>
            imageExtensions.any((ext) => item.toLowerCase().endsWith(ext)))
        .toList());
  }
  return images;
}

List<String> getStatusVideos(String appType) {
  final dirs = getAvailableStatusDirs(appType);
  final List<String> videos = [];
  for (final dir in dirs) {
    videos.addAll(dir
        .listSync()
        .map((item) => item.path)
        .where((item) =>
            videoExtensions.any((ext) => item.toLowerCase().endsWith(ext)))
        .toList());
  }
  return videos;
}

bool hasAnyStatusDirs(String appType) {
  return getAvailableStatusDirs(appType).isNotEmpty;
}

List<String> getAvailableApps() {
  final apps = <String>[];
  for (final appType in statusDirectories.keys) {
    if (hasAnyStatusDirs(appType)) {
      apps.add(appType);
    }
  }
  return apps;
}

String getAppLabel(String appType) {
  switch (appType) {
    case 'whatsapp':
      return 'WhatsApp';
    case 'whatsapp_business':
      return 'WA Business';
    default:
      return appType;
  }
}
