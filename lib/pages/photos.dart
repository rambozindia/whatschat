import 'dart:io';
import 'package:flutter/material.dart';
import 'package:numstatus/models/status_file.dart';
import 'package:numstatus/pages/view_photo.dart';
import 'package:numstatus/services/saf_directory_service.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.grey[850] : Colors.deepOrange;

    return FutureBuilder<List<StatusFile>>(
      future: getStatusImages(widget.appType),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            body: Container(
              color: bgColor,
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final imageList = snapshot.data ?? [];

        if (imageList.isEmpty) {
          return Scaffold(
            body: Container(
              color: bgColor,
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

        return Scaffold(
          body: Container(
            color: bgColor,
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
                      final statusFile = imageList[index];
                      return _PhotoThumbnail(
                        statusFile: statusFile,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ViewPhotos(statusFile)),
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
      },
    );
  }
}

class _PhotoThumbnail extends StatefulWidget {
  final StatusFile statusFile;
  final VoidCallback onTap;

  _PhotoThumbnail({required this.statusFile, required this.onTap});

  @override
  _PhotoThumbnailState createState() => _PhotoThumbnailState();
}

class _PhotoThumbnailState extends State<_PhotoThumbnail> {
  File? _thumbFile;

  @override
  void initState() {
    super.initState();
    _loadThumbnail();
  }

  Future<void> _loadThumbnail() async {
    final thumb = await SafDirectoryService.getThumbnailFile(
        widget.statusFile,
        width: 300,
        height: 300);
    if (mounted && thumb != null) {
      setState(() => _thumbFile = thumb);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8.0,
      borderRadius: BorderRadius.all(Radius.circular(8)),
      child: InkWell(
        onTap: widget.onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: _thumbFile != null
              ? Image.file(_thumbFile!, fit: BoxFit.cover)
              : Container(
                  height: 150,
                  color: Colors.grey[300],
                  child: Center(child: CircularProgressIndicator()),
                ),
        ),
      ),
    );
  }
}
