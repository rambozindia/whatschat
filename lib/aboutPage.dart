import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info/package_info.dart';

import 'pages/about_us.dart';

class aboutPage extends StatefulWidget {
  aboutPage({Key? key}) : super(key: key);

  @override
  _aboutPageState createState() => _aboutPageState();
}

class _aboutPageState extends State<aboutPage> {
  final _menutextcolor = TextStyle(
    color: Colors.black,
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
  );
  final _iconcolor = new IconThemeData(
    color: Color(0xff757575),
  );

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
    return Container(
      color: Colors.deepOrange,
      child: Padding(
        padding: EdgeInsets.fromLTRB(10, 30, 10, 30),
        child: Card(
          elevation: 5,
          child: ClipPath(
            child: ListView(
              padding: EdgeInsets.all(0),
              children: <Widget>[
                UserAccountsDrawerHeader(
                  accountName: Text(
                    "Number to WhatsChat",
                    style: TextStyle(
                      fontSize: 20.0,
                    ),
                  ),
                  accountEmail: Text("Easily Download WhatsApp Status & chat"),
                  currentAccountPicture: Image.asset('images/avatar.png'),
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
                      new MaterialPageRoute(
                          builder: (context) => new AboutScreen()),
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
                    // you can modify message if you want.
                    Share.share(
                        "Hello, Good News\n\n*Download Anyone WhatsApp Status* \n\nDownload Your Contact's Status Photos\nDownload Your Contact's Video Status \n\n*Just Download this Application and You will be able to download other's Whatsapp photo and video Status* \n\n 👇👇👇👇👇 \nDownload Now\nhttps://play.google.com/store/apps/details?id=com.number.whatschat");
                  },
                ),
                ListTile(
                  leading: IconTheme(
                    data: _iconcolor,
                    child: Icon(Icons.rate_review),
                  ),
                  title: Text("Rate and Review", style: _menutextcolor),
                  onTap: () async {
                    // you can update this link with your app link
                    const url =
                        'https://play.google.com/store/apps/details?id=com.number.whatschat';
                    if (await canLaunch(url)) {
                      await launch(url);
                    } else {
                      throw 'Could not open App';
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
                    // add privacy policy url
                    const url = 'https://www.blueburn.in/projects/';
                    if (await canLaunch(url)) {
                      await launch(url);
                    } else {
                      throw 'Could not open App';
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
