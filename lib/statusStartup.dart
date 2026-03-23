import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:numstatus/pages/dashboard.dart';
import 'package:numstatus/pages/photos.dart';
import 'package:numstatus/pages/videos.dart';
import 'package:numstatus/pages/about_us.dart';
import 'package:numstatus/includes/myNavigationDrawer.dart';

class statusStartup extends StatefulWidget {
  @override
  _statusStartupState createState() => _statusStartupState();
}

class _statusStartupState extends State<statusStartup> {
  bool? _readPermissionCheck;
  bool? _writePermissionCheck;
  Future<int>? _readwritePermissionChecker;

  Future<bool> checkReadPermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await Permission.storage.status;
      setState(() {
        _readPermissionCheck = true;
      });
      return androidInfo.isGranted;
    }
    return true;
  }

  Future<bool> checkWritePermission() async {
    if (Platform.isAndroid) {
      var status = await Permission.manageExternalStorage.status;
      setState(() {
        _writePermissionCheck = true;
      });
      return status.isGranted;
    }
    return true;
  }

  Future<int> requestReadPermission() async {
    int output = 0;
    if (Platform.isAndroid) {
      // For Android 13+, request media permissions
      if (await Permission.photos.request().isGranted ||
          await Permission.storage.request().isGranted) {
        if (await Permission.manageExternalStorage.request().isGranted) {
          output = 1;
        }
      }
    }
    return output;
  }

  @override
  void initState() {
    super.initState();

    _readwritePermissionChecker = (() async {
      int finalPermission;
      if (_readPermissionCheck == null || _readPermissionCheck == false) {
        _readPermissionCheck = await checkReadPermission();
      } else {
        _readPermissionCheck = true;
      }
      if (_writePermissionCheck == null || _writePermissionCheck == false) {
        _writePermissionCheck = await checkWritePermission();
      } else {
        _writePermissionCheck = true;
      }
      if (_readPermissionCheck! && _writePermissionCheck!) {
        finalPermission = 1;
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
              if (status.data == 1) {
                return statusDashboard();
              } else {
                return Scaffold(
                  body: Container(
                    color: Colors.deepOrange,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              "File Read Permission Required",
                              style: TextStyle(
                                  fontSize: 20.0, color: Colors.white),
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
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 20),
                                textStyle: TextStyle(fontSize: 20),
                              )),
                        ],
                      ),
                    ),
                  ),
                );
              }
            } else {
              return Scaffold(
                body: Container(
                  color: Colors.deepOrange,
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
                color: Colors.deepOrange,
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
      body: DashboardScreen(),
      drawer: Drawer(
        child: MyNavigationDrawer(),
      ),
    );
  }
}
