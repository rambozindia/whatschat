import 'dart:io';
import 'package:flutter/material.dart';
import 'package:numstatus/pages/view_photo.dart';
import 'package:numstatus/utils/status_directory_helper.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class Photos extends StatefulWidget {
  final String appType;
  Photos({Key? key, this.appType = 'whatsapp'}) : super(key: key);

  @override
  PhotosState createState() => PhotosState();
}

class PhotosState extends State<Photos> {
  @override
  Widget build(BuildContext context) {
    if (!hasAnyStatusDirs(widget.appType)) {
      return Scaffold(
        body: Container(
          color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[850] : Colors.deepOrange,
          child: Padding(
            padding: EdgeInsets.fromLTRB(10, 30, 10, 30),
            child: Card(
              elevation: 5,
              child: Center(
                child: Text(
                  "No Status Found\nYour Friend's Status will be available here.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18.0),
                ),
              ),
            ),
          ),
        ),
      );
    }

    final imageList = getStatusImages(widget.appType);

    if (imageList.isNotEmpty) {
      return Scaffold(
        body: Container(
          color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[850] : Colors.deepOrange,
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
                          MaterialPageRoute(
                              builder: (context) => ViewPhotos(imgPath)),
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
          color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[850] : Colors.deepOrange,
          child: Padding(
            padding: EdgeInsets.fromLTRB(10, 30, 10, 30),
            child: Card(
              elevation: 5,
              child: Center(
                child: Text(
                  "Sorry, No Images Found.",
                  style: TextStyle(fontSize: 18.0),
                ),
              ),
            ),
          ),
        ),
      );
    }
  }
}
