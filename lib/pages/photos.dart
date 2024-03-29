import 'dart:io';
import 'package:flutter/material.dart';
import 'package:whatschat/pages/view_photo.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

final Directory _photoDir =
    new Directory('/storage/emulated/0/WhatsApp/Media/.Statuses');

final Directory _photoDir2 = new Directory(
    '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/.Statuses');

class Photos extends StatefulWidget {
  @override
  PhotosState createState() {
    return new PhotosState();
  }
}

class PhotosState extends State<Photos> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!Directory("${_photoDir.path}").existsSync() &&
        !Directory("${_photoDir2.path}").existsSync()) {
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
      var imageList = [];
      if (Directory("${_photoDir.path}").existsSync()) {
        imageList = _photoDir
            .listSync()
            .map((item) => item.path)
            .where((item) => item.endsWith(".jpg"))
            .toList(growable: false);
        if (Directory("${_photoDir2.path}").existsSync()) {
          imageList = _photoDir2
              .listSync()
              .map((item) => item.path)
              .where((item) => item.endsWith(".jpg"))
              .toList(growable: false);
        }
      } else if (Directory("${_photoDir2.path}").existsSync()) {
        imageList = _photoDir2
            .listSync()
            .map((item) => item.path)
            .where((item) => item.endsWith(".jpg"))
            .toList(growable: false);
      }

      if (imageList.length > 0) {
        return Scaffold(
          body: Container(
            color: Colors.deepOrange,
            child: Padding(
              padding: EdgeInsets.fromLTRB(10, 30, 10, 30),
              child: Card(
                elevation: 5,
                child: ClipPath(
                  child: MasonryGridView.count(
                    padding: const EdgeInsets.all(8.0),
                    crossAxisCount: 2,
                    itemCount: imageList.length,
                    itemBuilder: (context, index) {
                      String imgPath = imageList[index];
                      return Material(
                        elevation: 8.0,
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        child: InkWell(
                          onTap: () => Navigator.push(
                            context,
                            new MaterialPageRoute(
                                builder: (context) => new ViewPhotos(imgPath)),
                          ),
                          child: Hero(
                            tag: imgPath,
                            child: Image.file(
                              File(imgPath),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                    // staggeredTileBuilder: (i) =>
                    //     StaggeredTile.count(2, i.isEven ? 2 : 3),
                    mainAxisSpacing: 8.0,
                    crossAxisSpacing: 8.0,
                  ),
                ),
              ),
            ),
          ),
        );
      } else {
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
                      "Sorry, No Images Found.",
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }
  }
}
