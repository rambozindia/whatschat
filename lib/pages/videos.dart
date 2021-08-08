import 'dart:io';
import 'package:flutter/material.dart';
import 'package:whatschat/pages/video_play.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

final Directory _videoDir =
    new Directory('/storage/emulated/0/WhatsApp/Media/.Statuses');

final Directory _videoDir2 = new Directory(
    '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/.Statuses');

class VideoListView extends StatefulWidget {
  @override
  VideoListViewState createState() {
    return new VideoListViewState();
  }
}

class VideoListViewState extends State<VideoListView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!Directory("${_videoDir.path}").existsSync() &&
        !Directory("${_videoDir2.path}").existsSync()) {
      return Scaffold(
        body: Container(
          color: Colors.deepOrange,
          child: Padding(
            padding: EdgeInsets.fromLTRB(10, 30, 10, 30),
            child: Card(
              elevation: 5,
              child: ClipPath(
                child: Center(
                  child: Text(
                    "Install WhatsApp\nYour Friend's Status will be available here.",
                    style: TextStyle(fontSize: 18.0),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      if (Directory("${_videoDir2.path}").existsSync()) {
        return Scaffold(
          body: VideoGrid(directory: _videoDir2),
        );
      } else {
        return Scaffold(
          body: VideoGrid(directory: _videoDir),
        );
      }
    }
  }
}

class VideoGrid extends StatefulWidget {
  final Directory directory;

  const VideoGrid({Key? key, required this.directory}) : super(key: key);

  @override
  _VideoGridState createState() => _VideoGridState();
}

class _VideoGridState extends State<VideoGrid> {
  _getImage(videoPathUrl) async {
    //await Future.delayed(Duration(milliseconds: 500));
    String? uint8list = await VideoThumbnail.thumbnailFile(
      video: videoPathUrl,
      imageFormat: ImageFormat.PNG,
      quality: 10,
    );
    // String thumb = await Thumbnails.getThumbnail(
    //     videoFile: videoPathUrl,
    //     imageType:
    //         ThumbFormat.PNG, //this image will store in created folderpath
    //     quality: 10);
    return uint8list;
  }

  @override
  Widget build(BuildContext context) {
    var videoList = widget.directory
        .listSync()
        .map((item) => item.path)
        .where((item) => item.endsWith(".mp4"))
        .toList(growable: false);

    if (videoList != null) {
      if (videoList.length > 0) {
        return Container(
          color: Colors.deepOrange,
          child: Padding(
            padding: EdgeInsets.fromLTRB(10, 30, 10, 30),
            child: Card(
              elevation: 5,
              child: ClipPath(
                child: GridView.builder(
                  itemCount: videoList.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, childAspectRatio: 1),
                  itemBuilder: (context, index) {
                    return Container(
                      padding: EdgeInsets.all(10.0),
                      child: InkWell(
                        onTap: () => Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (context) =>
                                  new PlayStatusVideo(videoList[index])),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              // Where the linear gradient begins and ends
                              begin: Alignment.bottomLeft,
                              end: Alignment.topRight,
                              // Add one stop for each color. Stops should increase from 0 to 1
                              stops: [0.1, 0.3, 0.5, 0.7, 0.9],
                              colors: [
                                // Colors are easy thanks to Flutter's Colors class.
                                Color(0xffb7d8cf),
                                Color(0xffb7d8cf),
                                Color(0xffb7d8cf),
                                Color(0xffb7d8cf),
                                Color(0xffb7d8cf),
                              ],
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          child: FutureBuilder(
                              future: _getImage(videoList[index]),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  if (snapshot.hasData) {
                                    return Column(children: <Widget>[
                                      Hero(
                                        tag: videoList[index],
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              new MaterialPageRoute(
                                                  builder: (context) =>
                                                      new PlayStatusVideo(
                                                          videoList[index])),
                                            );
                                          },
                                          child: Image.file(
                                            File(snapshot.data.toString()),
                                            height: 170,
                                          ),
                                        ),
                                      ),
                                    ]);
                                  } else {
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                } else {
                                  return Hero(
                                    tag: videoList[index],
                                    child: Container(
                                      height: 170,
                                      child: Image.asset(
                                          "images/video_loader.gif"),
                                    ),
                                  );
                                }
                              }),
                          //new cod
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      } else {
        return Center(
          child: Container(
            padding: EdgeInsets.only(bottom: 60.0),
            child: Text(
              "Sorry, No Videos Found.",
              style: TextStyle(fontSize: 18.0),
            ),
          ),
        );
      }
    } else {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
  }
}
