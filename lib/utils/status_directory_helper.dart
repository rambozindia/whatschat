import 'package:numstatus/models/status_file.dart';
import 'package:numstatus/services/saf_directory_service.dart';
import 'package:numstatus/utils/constants.dart';

Future<List<StatusFile>> getStatusImages(String appType) async {
  return await SafDirectoryService.listFiles(appType, imageExtensions);
}

Future<List<StatusFile>> getStatusVideos(String appType) async {
  return await SafDirectoryService.listFiles(appType, videoExtensions);
}

Future<bool> hasAnyStatusDirs(String appType) async {
  return await SafDirectoryService.hasPersistedUri(appType);
}

Future<List<String>> getAvailableApps() async {
  return await SafDirectoryService.getAvailableApps();
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
