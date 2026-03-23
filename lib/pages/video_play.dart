import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:numstatus/pages/video_controller.dart';
import 'package:numstatus/utils/dialogs.dart';
import 'package:video_player/video_player.dart';

class PlayStatusVideo extends StatefulWidget {
  final String videoFile;
  PlayStatusVideo(this.videoFile);

  @override
  _PlayStatusVideoState createState() => _PlayStatusVideoState();
}

class _PlayStatusVideoState extends State<PlayStatusVideo> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.grey[850]! : Colors.deepOrange;

    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          color: Colors.indigo,
          icon: Icon(Icons.close, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Container(
            padding: EdgeInsets.symmetric(horizontal: 0, vertical: 5.0),
            child: Row(
              children: [
                ElevatedButton.icon(
                  label: Text('Save', style: TextStyle(fontSize: 14.0)),
                  onPressed: () async {
                    File originalVideoFile = File(widget.videoFile);
                    Directory? directory =
                        await getExternalStorageDirectory();
                    if (!Directory(
                            "${directory!.path}/Downloaded Status/Videos")
                        .existsSync()) {
                      Directory(
                              "${directory.path}/Downloaded Status/Videos")
                          .createSync(recursive: true);
                    }
                    String path = directory.path;
                    String curDate = DateTime.now().toString();
                    String newFileName =
                        "$path/Downloaded Status/Videos/VIDEO-$curDate.mp4";
                    await originalVideoFile.copy(newFileName);

                    if (mounted) {
                      showSaveSuccessDialog(context,
                          "If Video not available in gallery\n\nYou can find all videos at");
                    }
                  },
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
                    await Share.shareXFiles(
                      [XFile(widget.videoFile)],
                      text: "Share from Number Status Download",
                    );
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
                    await Share.shareXFiles(
                      [XFile(widget.videoFile)],
                      text: "Repost via Number Status Download",
                    );
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
              child: StatusVideo(
                videoPlayerController:
                    VideoPlayerController.file(File(widget.videoFile)),
                looping: true,
                videoSrc: widget.videoFile,
                aspectRatio: 6 / 9,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
