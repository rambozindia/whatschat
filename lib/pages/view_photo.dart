import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:share_plus/share_plus.dart';

import 'package:numstatus/models/status_file.dart';
import 'package:numstatus/services/saf_directory_service.dart';
import 'package:numstatus/utils/dialogs.dart';

class ViewPhotos extends StatefulWidget {
  final StatusFile? statusFile;
  final String? localPath;

  /// Use StatusFile for SAF sources, or localPath for history/cached files
  ViewPhotos(dynamic source, {Key? key})
      : statusFile = source is StatusFile ? source : null,
        localPath = source is String ? source : null,
        super(key: key);

  @override
  _ViewPhotosState createState() => _ViewPhotosState();
}

class _ViewPhotosState extends State<ViewPhotos> {
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    Uint8List? bytes;
    if (widget.localPath != null) {
      bytes = await File(widget.localPath!).readAsBytes();
    } else if (widget.statusFile != null) {
      bytes = await SafDirectoryService.readFileBytes(widget.statusFile!.uri);
    }
    if (mounted && bytes != null) {
      setState(() => _imageBytes = bytes);
    }
  }

  Future<String?> _getSharePath() async {
    if (widget.localPath != null) return widget.localPath;
    if (widget.statusFile != null) {
      final file = await SafDirectoryService.copyToCache(widget.statusFile!);
      return file?.path;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.grey[850]! : Colors.deepOrange;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.close, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            ElevatedButton.icon(
              label: Text('Save', style: TextStyle(fontSize: 14.0)),
              onPressed: () async {
                if (_imageBytes != null) {
                  await ImageGallerySaverPlus.saveImage(
                      Uint8List.fromList(_imageBytes!));
                  if (mounted) {
                    showSaveSuccessDialog(context,
                        "If Image not available in gallery\n\nYou can find all images at");
                  }
                }
              },
              icon: Icon(Icons.file_download),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  textStyle: TextStyle(fontSize: 16)),
            ),
            SizedBox(width: 6),
            ElevatedButton.icon(
              label: Text('Share', style: TextStyle(fontSize: 14.0)),
              onPressed: () async {
                final path = await _getSharePath();
                if (path != null) {
                  await Share.shareXFiles(
                    [XFile(path)],
                    text: "Share from Number Status Download",
                  );
                }
              },
              icon: Icon(Icons.share),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  textStyle: TextStyle(fontSize: 16)),
            ),
            SizedBox(width: 6),
            ElevatedButton.icon(
              label: Text('Repost', style: TextStyle(fontSize: 14.0)),
              onPressed: () async {
                final path = await _getSharePath();
                if (path != null) {
                  await Share.shareXFiles(
                    [XFile(path)],
                    text: "Repost via Number Status Download",
                  );
                }
              },
              icon: Icon(Icons.repeat),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  textStyle: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
      body: Container(
        color: bgColor,
        child: Padding(
          padding: EdgeInsets.fromLTRB(10, 30, 10, 30),
          child: Card(
            elevation: 5,
            child: Container(
              margin: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: SizedBox.expand(
                child: Center(
                  child: _imageBytes != null
                      ? Image.memory(_imageBytes!, fit: BoxFit.cover)
                      : CircularProgressIndicator(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
