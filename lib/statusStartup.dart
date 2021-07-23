import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:whatschat/includes/myNavigationDrawer.dart';
import 'package:whatschat/pages/about_us.dart';
import 'package:whatschat/pages/dashboard.dart';
import 'package:whatschat/pages/photos.dart';
import 'package:whatschat/pages/videos.dart';

// void main() => runApp(statusStartup());

class statusStartup extends StatefulWidget {
  @override
  _statusStartupState createState() => _statusStartupState();
}

class _statusStartupState extends State<statusStartup> {
  bool? _readPermissionCheck;
  bool? _writePermissionCheck;
  Future<int>? _readwritePermissionChecker;

  Future<bool> checkReadPermission() async {
    var status = await Permission.manageExternalStorage.status;

    print("Checking Read Permission : " + status.toString());
    setState(() {
      _readPermissionCheck = true;
    });
    switch (status) {
      case PermissionStatus.denied:
        return false;
      case PermissionStatus.granted:
        return true;
      default:
        return false;
    }
  }

  Future<bool> checkWritePermission() async {
    var status = await Permission.manageExternalStorage.status;

    print("Checking Read Permission : " + status.toString());
    setState(() {
      _readPermissionCheck = true;
    });
    switch (status) {
      case PermissionStatus.denied:
        return false;
      case PermissionStatus.granted:
        return true;
      default:
        return false;
    }
  }

  Future<int> requestReadPermission() async {
    if (await Permission.contacts.request().isGranted) {
      print("pass");
      return 1;
      // Either the permission was already granted before or the user just granted it.
    } else {
      print("fail");
      return 0;
    }
  }

  // Future<int> requestWritePermission() async {
  //   PermissionStatus result = await SimplePermissions.requestPermission(
  //       Permission.WriteExternalmanageExternalStorage);
  //   print("Requesting Write Permission $result");
  //   if (result.toString() == "PermissionStatus.denied") {
  //     return 1;
  //   } else if (result.toString() == "PermissionStatus.authorized") {
  //     return 2;
  //   } else {
  //     return 1;
  //   }
  // }

  @override
  void initState() {
    super.initState();

    _readwritePermissionChecker = (() async {
      int readPermissionCheckInt;
      int writePermissionCheckInt;
      int finalPermission;

      print(
          "Initial Values of $_readPermissionCheck AND $_writePermissionCheck");
      if (_readPermissionCheck == null || _readPermissionCheck == false) {
        _readPermissionCheck = await checkReadPermission();
      } else {
        _readPermissionCheck = true;
      }
      if (_readPermissionCheck!) {
        readPermissionCheckInt = 1;
      } else {
        readPermissionCheckInt = 0;
      }

      if (_writePermissionCheck == null || _writePermissionCheck == false) {
        _writePermissionCheck = await checkWritePermission();
      }
      if (_writePermissionCheck!) {
        writePermissionCheckInt = 1;
      } else {
        writePermissionCheckInt = 0;
      }
      if (readPermissionCheckInt == 1) {
        if (writePermissionCheckInt == 1) {
          finalPermission = 2;
        } else {
          finalPermission = 1;
        }
      } else {
        finalPermission = 0;
      }
      return finalPermission;
    })();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Status Downloader',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        future: _readwritePermissionChecker,
        builder: (context, status) {
          if (status.connectionState == ConnectionState.done) {
            if (status.hasData) {
              if (status.data == 2) {
                return statusDashboard();
              } else if (status.data == 1) {
                return Scaffold(
                  body: Container(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              "Write Permission Required",
                              style: TextStyle(fontSize: 20.0),
                            ),
                          ),
                          // FlatButton(
                          //   padding: EdgeInsets.all(15.0),
                          //   child: Text(
                          //     "Allow Write Permission",
                          //     style: TextStyle(fontSize: 20.0),
                          //   ),
                          //   color: Colors.indigo,
                          //   textColor: Colors.white,
                          //   onPressed: () {
                          //     setState(() {
                          //       _readwritePermissionChecker =
                          //           requestWritePermission();
                          //     });
                          //   },
                          // )
                        ],
                      ),
                    ),
                  ),
                );
              } else {
                return Scaffold(
                  body: Container(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              "File Read Permission Required",
                              style: TextStyle(fontSize: 20.0),
                            ),
                          ),
                          ElevatedButton(
                            child: Text('Allow File Read Permission'),
                            onPressed: () {
                              setState(() {
                                _readwritePermissionChecker =
                                    requestReadPermission();
                              });
                            },
                            style: ElevatedButton.styleFrom(
                                primary: Colors.deepOrange,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 50, vertical: 20),
                                textStyle: TextStyle(fontSize: 20)),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              }
            } else {
              return Scaffold(
                body: Container(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            "Something went wrong.. Please uninstall and Install Again.",
                            style: TextStyle(fontSize: 20.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
          } else {
            return Scaffold(
              body: Container(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            );
          }
        },
      ),
      routes: <String, WidgetBuilder>{
        "/home": (BuildContext context) => DashboardScreen(),
        "/photos": (BuildContext context) => Photos(),
        "/videos": (BuildContext context) => VideoListView(),
        "/aboutus": (BuildContext context) => AboutScreen(),
      },
    );
  }
}

class statusDashboard extends StatefulWidget {
  @override
  _statusDashboardState createState() => _statusDashboardState();
}

class _statusDashboardState extends State<statusDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Download WhatsApp Status"),
        //elevation: defaultTargetPlatform == TargetPlatform.android ? 5.0 : 0.0,
      ),
      body: DashboardScreen(),
      drawer: Drawer(
        child: MyNavigationDrawer(),
      ),
    );
  }
}
