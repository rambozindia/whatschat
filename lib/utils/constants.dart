import 'dart:io';

import 'package:flutter/material.dart';

// App info
const String appName = 'Number Status Download';

// Status directory paths for supported apps
final Map<String, List<Directory>> statusDirectories = {
  'whatsapp': [
    Directory('/storage/emulated/0/WhatsApp/Media/.Statuses'),
    Directory(
        '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/.Statuses'),
  ],
  'whatsapp_business': [
    Directory('/storage/emulated/0/WhatsApp Business/Media/.Statuses'),
    Directory(
        '/storage/emulated/0/Android/media/com.whatsapp.w4b/WhatsApp Business/Media/.Statuses'),
  ],
};

// Supported image extensions
const List<String> imageExtensions = ['.jpg', '.jpeg', '.png', '.webp'];

// Supported video extensions
const List<String> videoExtensions = ['.mp4'];

// Ad Unit IDs
String getBannerAdUnitId() {
  if (Platform.isIOS || Platform.isAndroid) {
    return 'ca-app-pub-5924361002999470/2628163306';
  }
  return "";
}

String getNativeAdUnitId() {
  if (Platform.isIOS || Platform.isAndroid) {
    return 'ca-app-pub-5924361002999470/4345357040';
  }
  return "";
}

String getInterstitialAdUnitId() {
  if (Platform.isIOS || Platform.isAndroid) {
    return 'ca-app-pub-5924361002999470/4978515543';
  }
  return "";
}

// Theme colors
const Color primaryColor = Colors.deepOrange;
