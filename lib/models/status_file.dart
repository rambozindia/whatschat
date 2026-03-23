class StatusFile {
  final String uri; // content:// URI or file path
  final String displayName;
  final String? mimeType;
  final int? size;
  final DateTime? lastModified;

  // For cached/history files that are on local filesystem
  final String? localPath;

  StatusFile({
    required this.uri,
    required this.displayName,
    this.mimeType,
    this.size,
    this.lastModified,
    this.localPath,
  });

  bool get isLocal => localPath != null;

  bool get isImage {
    final name = displayName.toLowerCase();
    return name.endsWith('.jpg') ||
        name.endsWith('.jpeg') ||
        name.endsWith('.png') ||
        name.endsWith('.webp');
  }

  bool get isVideo {
    final name = displayName.toLowerCase();
    return name.endsWith('.mp4');
  }
}
