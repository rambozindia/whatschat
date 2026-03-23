import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:numstatus/main.dart';
import 'pages/about_us.dart';

class aboutPage extends StatefulWidget {
  aboutPage({Key? key}) : super(key: key);

  @override
  _aboutPageState createState() => _aboutPageState();
}

class _aboutPageState extends State<aboutPage> {

  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  Widget _infoTile(String title, String subtitle) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle.isNotEmpty ? subtitle : 'Not set'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.grey[850]! : Colors.deepOrange;
    final appState = MyApp.of(context);

    final _menutextcolor = TextStyle(
      color: isDark ? Colors.white : Colors.black,
      fontSize: 14.0,
      fontWeight: FontWeight.w500,
    );
    final _iconcolor = IconThemeData(
      color: isDark ? Colors.white70 : Color(0xff757575),
    );

    return Container(
      color: bgColor,
      child: Padding(
        padding: EdgeInsets.fromLTRB(10, 30, 10, 30),
        child: Card(
          elevation: 5,
          child: ClipPath(
            child: ListView(
              padding: EdgeInsets.all(0),
              children: <Widget>[
                UserAccountsDrawerHeader(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.deepOrange,
                  ),
                  accountName: Text(
                    "Number Status Download",
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.white,
                    ),
                  ),
                  accountEmail: Text("Easily Download Status & Chat",
                      style: TextStyle(color: Colors.white70)),
                  currentAccountPicture: Image.asset('images/avatar.png'),
                ),
                // Dark Mode Toggle
                SwitchListTile(
                  secondary: IconTheme(
                    data: _iconcolor,
                    child: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
                  ),
                  title: Text("Dark Mode", style: _menutextcolor),
                  value: isDark,
                  onChanged: (value) {
                    appState?.themeNotifier.toggleTheme();
                  },
                ),
                ListTile(
                  leading: IconTheme(
                    data: _iconcolor,
                    child: Icon(Icons.info),
                  ),
                  title: Text("About Us", style: _menutextcolor),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AboutScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: IconTheme(
                    data: _iconcolor,
                    child: Icon(Icons.share),
                  ),
                  title: Text("Share with Friends", style: _menutextcolor),
                  onTap: () {
                    Share.share(
                      "Hello, Good News\n\n*Download Anyone's Status* \n\nDownload Your Contact's Status Photos\nDownload Your Contact's Video Status \n\n*Just Download this Application and You will be able to download other's photo and video Status* \n\n \u{1F447}\u{1F447}\u{1F447}\u{1F447}\u{1F447} \nDownload Now\nhttps://play.google.com/store/apps/details?id=com.blueburn.numstatus",
                    );
                  },
                ),
                ListTile(
                  leading: IconTheme(
                    data: _iconcolor,
                    child: Icon(Icons.rate_review),
                  ),
                  title: Text("Rate and Review", style: _menutextcolor),
                  onTap: () async {
                    final url = Uri.parse(
                        'https://play.google.com/store/apps/details?id=com.blueburn.numstatus');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url,
                          mode: LaunchMode.externalApplication);
                    }
                  },
                ),
                ListTile(
                  leading: IconTheme(
                    data: _iconcolor,
                    child: Icon(Icons.security),
                  ),
                  title: Text("Privacy Policy", style: _menutextcolor),
                  onTap: () async {
                    final url =
                        Uri.parse('https://www.blueburn.in/projects/');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url,
                          mode: LaunchMode.externalApplication);
                    }
                  },
                ),
                ListBody(
                  children: <Widget>[
                    _infoTile('App name', _packageInfo.appName),
                    _infoTile('Package name', _packageInfo.packageName),
                    _infoTile('App version', _packageInfo.version),
                    _infoTile('Build number', _packageInfo.buildNumber),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
