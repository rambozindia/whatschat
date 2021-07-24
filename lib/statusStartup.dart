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
    var status = await Permission.storage.status;

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
    var status = await Permission.storage.status;

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
    if (await Permission.storage.request().isGranted) {
      print("pass");
      return 1;
      // Either the permission was already granted before or the user just granted it.
    } else {
      print("fail");
      return 0;
    }
  }

  @override
  void initState() {
    super.initState();

    _readwritePermissionChecker = (() async {
      int finalPermission;

      print(
          "Initial Values of $_readPermissionCheck AND $_writePermissionCheck");
      if (_readPermissionCheck == null || _readPermissionCheck == false) {
        _readPermissionCheck = await checkReadPermission();
      } else {
        _readPermissionCheck = true;
      }
      if (_readPermissionCheck!) {
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
      title: 'WhatsApp Status Downloader',
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
                                primary: Colors.white,
                                onPrimary: Colors.black,
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
