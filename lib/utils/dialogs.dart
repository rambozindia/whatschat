import 'package:flutter/material.dart';

void showSaveSuccessDialog(BuildContext context, String message) {
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
                      "Great, Saved in Gallery",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Padding(padding: EdgeInsets.all(10.0)),
                    Text(message, style: TextStyle(fontSize: 16.0)),
                    Padding(padding: EdgeInsets.all(10.0)),
                    Text("FileManager > Downloaded Status",
                        style: TextStyle(fontSize: 16.0, color: Colors.teal)),
                    Padding(padding: EdgeInsets.all(10.0)),
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
    },
  );
}

void showProgressDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return SimpleDialog(
        children: <Widget>[
          Center(
            child: Container(
              padding: EdgeInsets.all(10.0),
              child: CircularProgressIndicator(),
            ),
          ),
        ],
      );
    },
  );
}

void showBulkDownloadProgress(
    BuildContext context, int done, int total, bool isComplete) {
  showDialog(
    context: context,
    barrierDismissible: isComplete,
    builder: (BuildContext context) {
      return SimpleDialog(
        children: <Widget>[
          Center(
            child: Container(
              padding: EdgeInsets.all(15.0),
              child: Column(
                children: <Widget>[
                  if (!isComplete) ...[
                    CircularProgressIndicator(),
                    Padding(padding: EdgeInsets.all(10.0)),
                    Text("Downloading $done / $total",
                        style: TextStyle(fontSize: 16.0)),
                  ] else ...[
                    Icon(Icons.check_circle, color: Colors.green, size: 48),
                    Padding(padding: EdgeInsets.all(10.0)),
                    Text("Downloaded $done items!",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Padding(padding: EdgeInsets.all(10.0)),
                    MaterialButton(
                      child: Text("Close"),
                      color: Colors.teal,
                      textColor: Colors.white,
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ],
              ),
            ),
          ),
        ],
      );
    },
  );
}
