import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:numstatus/models/status_file.dart';
import 'package:numstatus/services/saf_directory_service.dart';
import 'package:numstatus/pages/video_controller.dart';
import 'package:numstatus/utils/dialogs.dart';
import 'package:video_player/video_player.dart';

class PlayStatusVideo extends StatefulWidget {
  final StatusFile? statusFile;
  final String? localPath;

  PlayStatusVideo(dynamic source, {Key? key})
      : statusFile = source is StatusFile ? source : null,
        localPath = source is String ? source : null,
        super(key: key);

  @override
  _PlayStatusVideoState createState() => _PlayStatusVideoState();
}

class _PlayStatusVideoState extends State<PlayStatusVideo> {
  File? _localFile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _prepareVideo();
  }

  Future<void> _prepareVideo() async {
    File? file;
    if (widget.localPath != null) {
      file = File(widget.localPath!);
    } else if (widget.statusFile != null) {
      file = await SafDirectoryService.copyToCache(widget.statusFile!);
    }
    if (mounted) {
      setState(() {
        _localFile = file;
        _loading = false;
      });
    }
  }

  Future<void> _saveVideo() async {
    if (_localFile == null) return;
    Directory? directory = await getExternalStorageDirectory();
    if (directory == null) return;

    String videoDir = "${directory.path}/Downloaded Status/Videos";
    if (!Directory(videoDir).existsSync()) {
      Directory(videoDir).createSync(recursive: true);
    }

    String curDate = DateTime.now().millisecondsSinceEpoch.toString();
    String newFileName = "$videoDir/VIDEO-$curDate.mp4";
    await _localFile!.copy(newFileName);

    if (mounted) {
      showSaveSuccessDialog(context,
          "If Video not available in gallery\n\nYou can find all videos at");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.grey[850]! : Colors.deepOrange;

    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.close, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Container(
            padding: EdgeInsets.symmetric(horizontal: 0, vertical: 5.0),
            child: Row(
              children: [
                ElevatedButton.icon(
                  label: Text('Save', style: TextStyle(fontSize: 14.0)),
                  onPressed: _saveVideo,
                  icon: Icon(Icons.file_download),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      textStyle: TextStyle(fontSize: 16)),
                ),
                SizedBox(width: 6),
                ElevatedButton.icon(
                  label: Text('Share', style: TextStyle(fontSize: 14.0)),
                  onPressed: () async {
                    if (_localFile != null) {
                      await Share.shareXFiles(
                        [XFile(_localFile!.path)],
                        text: "Share from Number Status Download",
                      );
                    }
                  },
                  icon: Icon(Icons.share),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      textStyle: TextStyle(fontSize: 16)),
                ),
                SizedBox(width: 6),
                ElevatedButton.icon(
                  label: Text('Repost', style: TextStyle(fontSize: 14.0)),
                  onPressed: () async {
                    if (_localFile != null) {
                      await Share.shareXFiles(
                        [XFile(_localFile!.path)],
                        text: "Repost via Number Status Download",
                      );
                    }
                  },
                  icon: Icon(Icons.repeat),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      textStyle: TextStyle(fontSize: 16)),
                ),
              ],
            )),
      ),
      body: Container(
        color: bgColor,
        child: Padding(
          padding: EdgeInsets.fromLTRB(10, 30, 10, 30),
          child: Card(
            elevation: 5,
            child: ClipPath(
              child: _loading
                  ? Center(child: CircularProgressIndicator())
                  : _localFile != null
                      ? StatusVideo(
                          videoPlayerController:
                              VideoPlayerController.file(_localFile!),
                          looping: true,
                          videoSrc: _localFile!.path,
                          aspectRatio: 6 / 9,
                        )
                      : Center(child: Text('Failed to load video')),
            ),
          ),
        ),
      ),
    );
  }
}
