import 'package:flutter/material.dart';
import 'package:numstatus/pages/dashboard.dart';
import 'package:numstatus/includes/myNavigationDrawer.dart';
import 'package:numstatus/services/saf_directory_service.dart';

class statusStartup extends StatefulWidget {
  @override
  _statusStartupState createState() => _statusStartupState();
}

class _statusStartupState extends State<statusStartup> {
  Future<bool>? _hasAccess;

  @override
  void initState() {
    super.initState();
    _checkAccess();
  }

  void _checkAccess() {
    _hasAccess = SafDirectoryService.hasPersistedUri('whatsapp');
  }

  Future<void> _pickFolder() async {
    final uri = await SafDirectoryService.pickStatusDirectory('whatsapp');
    if (uri != null && mounted) {
      setState(() {
        _hasAccess = Future.value(true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.grey[850]! : Colors.deepOrange;

    return FutureBuilder<bool>(
      future: _hasAccess,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.data == true) {
            return statusDashboard();
          } else {
            // Show folder picker screen
            return Scaffold(
              body: Container(
                color: bgColor,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_open, size: 80, color: Colors.white),
                        SizedBox(height: 20),
                        Text(
                          "Select Status Folder",
                          style: TextStyle(
                              fontSize: 24.0,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 16),
                        Text(
                          "To view and save statuses, please select the .Statuses folder.\n\n"
                          "Navigate to:\nInternal Storage > Android > media > com.whatsapp > WhatsApp > Media > .Statuses",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 14.0, color: Colors.white70),
                        ),
                        SizedBox(height: 30),
                        ElevatedButton.icon(
                          icon: Icon(Icons.folder_open),
                          label: Text('Select Folder'),
                          onPressed: _pickFolder,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: EdgeInsets.symmetric(
                                horizontal: 40, vertical: 16),
                            textStyle: TextStyle(fontSize: 18),
                          ),
                        ),
                        SizedBox(height: 16),
                        TextButton(
                          child: Text(
                            'Add WhatsApp Business folder',
                            style: TextStyle(color: Colors.white70),
                          ),
                          onPressed: () async {
                            await SafDirectoryService.pickStatusDirectory(
                                'whatsapp_business');
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        } else {
          return Scaffold(
            body: Container(
              color: bgColor,
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }
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
