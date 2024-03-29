import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:share/share.dart';

class ViewPhotos extends StatefulWidget {
  final String imgPath;
  ViewPhotos(this.imgPath);

  @override
  _ViewPhotosState createState() => _ViewPhotosState();
}

class _ViewPhotosState extends State<ViewPhotos> {
  var filePath;

  final LinearGradient backgroundGradient = new LinearGradient(
    colors: [
      Color(0x00000000),
      Color(0x00333333),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

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
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          color: Colors.indigo,
          icon: Icon(
            Icons.close,
            color: Colors.black,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Center(
          child: Row(
            children: [
              ElevatedButton.icon(
                label: Text('Download', style: TextStyle(fontSize: 16.0)),
                onPressed: () async {
                  // _onLoading(true, "");
//                File originalImageFile1 = File(widget.imgPath);
//
//                Directory directory = await getExternalStorageDirectory();
//                if(!Directory("${directory.path}/Downloaded Status/Images").existsSync()){
//                  Directory("${directory.path}/Downloaded Status/Images").createSync(recursive: true);
//                }
//                String path = directory.path;
//                String curDate = DateTime.now().toString();
//                String newFileName = "$path/Downloaded Status/Images/IMG-$curDate.jpg";
//                print(newFileName);
//                await originalImageFile1.copy(newFileName);

                  Uri myUri = Uri.parse(widget.imgPath);
                  File originalImageFile = new File.fromUri(myUri);
                  Uint8List? bytes;
                  await originalImageFile.readAsBytes().then((value) {
                    bytes = Uint8List.fromList(value);
                  }).catchError((onError) {});
                  final result = await ImageGallerySaver.saveImage(
                      Uint8List.fromList(bytes!));
                  _onLoading(false,
                      "If Image not available in gallary\n\nYou can find all images at");
                },
                icon: Icon(Icons.file_download),
                style: ElevatedButton.styleFrom(
                    primary: Colors.deepOrange,
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    textStyle: TextStyle(fontSize: 20)),
              ),
              SizedBox(width: 10),
              ElevatedButton.icon(
                label: Text(
                  'Share',
                  style: TextStyle(fontSize: 16.0),
                ), //`T
                onPressed: () async {
                  await Share.shareFiles([widget.imgPath],
                      text: "Share from Number to WhatsChat");
                },
                icon: Icon(Icons.share),
                style: ElevatedButton.styleFrom(
                    primary: Colors.deepOrange,
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    textStyle: TextStyle(fontSize: 20)),
              ),
            ],
          ),
        ),
      ),
      body: Container(
        color: Colors.deepOrange,
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
