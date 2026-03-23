import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:share_plus/share_plus.dart';

import 'package:numstatus/utils/dialogs.dart';

class ViewPhotos extends StatefulWidget {
  final String imgPath;
  ViewPhotos(this.imgPath);

  @override
  _ViewPhotosState createState() => _ViewPhotosState();
}

class _ViewPhotosState extends State<ViewPhotos> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.grey[850]! : Colors.deepOrange;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          color: Colors.indigo,
          icon: Icon(Icons.close, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            ElevatedButton.icon(
              label: Text('Save', style: TextStyle(fontSize: 14.0)),
              onPressed: () async {
                Uri myUri = Uri.parse(widget.imgPath);
                File originalImageFile = File.fromUri(myUri);
                Uint8List bytes = await originalImageFile.readAsBytes();
                await ImageGallerySaverPlus.saveImage(
                    Uint8List.fromList(bytes));
                if (mounted) {
                  showSaveSuccessDialog(context,
                      "If Image not available in gallery\n\nYou can find all images at");
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
                await Share.shareXFiles(
                  [XFile(widget.imgPath)],
                  text: "Share from Number Status Download",
                );
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
                await Share.shareXFiles(
                  [XFile(widget.imgPath)],
                  text: "Repost via Number Status Download",
                );
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
            child: ClipPath(
              child: Container(
                margin: const EdgeInsets.only(left: 10.0, right: 10.0),
                child: SizedBox.expand(
                  child: Stack(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.center,
                        child: Hero(
                          tag: widget.imgPath,
                          child: Image.file(
                            File(widget.imgPath),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
