import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:whatschat/pages/video_controller.dart';
import 'package:video_player/video_player.dart';

class PlayStatusVideo extends StatefulWidget {
  final String videoFile;
  PlayStatusVideo(this.videoFile);

  @override
  _PlayStatusVideoState createState() => _PlayStatusVideoState();
}

class _PlayStatusVideoState extends State<PlayStatusVideo> {
  @override
  void initState() {
    super.initState();
  }

  void dispose() {
    super.dispose();
  }

  void _onLoading(bool t, String str) {
    if (t) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return SimpleDialog(
              children: <Widget>[
                Center(
                  child: Container(
                      padding: EdgeInsets.all(10.0),
                      child: CircularProgressIndicator()),
                ),
              ],
            );
          });
    } else {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: SimpleDialog(
                children: <Widget>[
                  Center(
                    child: Container(
                      padding: EdgeInsets.all(15.0),
                      child: Column(
                        children: <Widget>[
                          Text(
                            "Great, Saved in Gallary",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Padding(
                            padding: EdgeInsets.all(10.0),
                          ),
                          Text(str,
                              style: TextStyle(
                                fontSize: 16.0,
                              )),
                          Padding(
                            padding: EdgeInsets.all(10.0),
                          ),
                          Text("FileManager > Downloaded Status",
                              style: TextStyle(
                                  fontSize: 16.0, color: Colors.teal)),
                          Padding(
                            padding: EdgeInsets.all(10.0),
                          ),
                          MaterialButton(
                            child: Text("Close"),
                            color: Colors.teal,
                            textColor: Colors.white,
                            onPressed: () => Navigator.pop(context),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          color: Colors.indigo,
          icon: Icon(
            Icons.close,
            color: Colors.black,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Container(
            padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
            child: Row(
              children: [
                ElevatedButton.icon(
                  label: Text(
                    'Save',
                    style: TextStyle(fontSize: 16.0),
                  ), //`T
                  onPressed: () async {
                    //_onLoading(true, "");

                    File originalVideoFile = File(widget.videoFile);
                    Directory? directory = await getExternalStorageDirectory();
                    if (!Directory(
                            "${directory!.path}/Downloaded Status/Videos")
                        .existsSync()) {
                      Directory("${directory.path}/Downloaded Status/Videos")
                          .createSync(recursive: true);
                    }
                    String path = directory.path;
                    String curDate = DateTime.now().toString();
                    String newFileName =
                        "$path/Downloaded Status/Videos/VIDEO-$curDate.mp4";
                    await originalVideoFile.copy(newFileName);

                    _onLoading(false,
                        "If Video not available in gallary\n\nYou can find all videos at");
                  },
                  icon: Icon(Icons.file_download),
                  style: ElevatedButton.styleFrom(
                      primary: Colors.deepOrange,
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      textStyle: TextStyle(fontSize: 20)),
                ),
                SizedBox(width: 10),
                ElevatedButton.icon(
                  label: Text(
                    'Share',
                    style: TextStyle(fontSize: 16.0),
                  ), //`T
                  onPressed: () async {
                    await Share.shareFiles([widget.videoFile],
                        text: "Share from Number to WhatsChat");
                  },
                  icon: Icon(Icons.share),
                  style: ElevatedButton.styleFrom(
                      primary: Colors.deepOrange,
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      textStyle: TextStyle(fontSize: 20)),
                ),
              ],
            )),
      ),
      body: Container(
        color: Colors.deepOrange,
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
