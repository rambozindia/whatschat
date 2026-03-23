import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

import 'package:numstatus/main.dart';

class MyNavigationDrawer extends StatelessWidget {
  final _menutextcolor = TextStyle(
    color: Colors.black,
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
  );
  final _iconcolor = new IconThemeData(
    color: Color(0xff757575),
  );

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textStyle = isDark
        ? _menutextcolor.copyWith(color: Colors.white)
        : _menutextcolor;
    final appState = MyApp.of(context);

    return ListView(
      padding: EdgeInsets.all(0),
      children: <Widget>[
        UserAccountsDrawerHeader(
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : Colors.deepOrange,
          ),
          accountName: Text(
            "Welcome to Status Downloader",
            style: TextStyle(
              fontSize: 20.0,
              color: Colors.white,
            ),
          ),
          accountEmail: Text("Easily Download Status",
              style: TextStyle(color: Colors.white70)),
          currentAccountPicture: Image.asset('images/avatar.png'),
        ),
        ListTile(
          leading: IconTheme(
            data: _iconcolor,
            child: Icon(Icons.photo_library),
          ),
          title: Text("Photo Status", style: textStyle),
          onTap: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushNamed("/photos");
          },
        ),
        ListTile(
          leading: IconTheme(
            data: _iconcolor,
            child: Icon(Icons.video_library),
          ),
          title: Text("Video Status", style: textStyle),
          onTap: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushNamed("/videos");
          },
        ),
        // Dark Mode Toggle
        SwitchListTile(
          secondary: IconTheme(
            data: _iconcolor,
            child: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
          ),
          title: Text("Dark Mode", style: textStyle),
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
          title: Text("About Us", style: textStyle),
          onTap: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushNamed("/aboutus");
          },
        ),
        ListTile(
          leading: IconTheme(
            data: _iconcolor,
            child: Icon(Icons.share),
          ),
          title: Text("Share with Friends", style: textStyle),
          onTap: () {
            Share.share(
              "Hello, Good News\n\n*Download Anyone's Status* \n\nDownload Your Contact's Status Photos\nDownload Your Contact's Video Status \n\n*Just Download this Application and You will be able to download other's photo and video Status* \n\n \u{1F447}\u{1F447}\u{1F447}\u{1F447}\u{1F447} \nDownload Now\nhttp://bit.ly/status-download",
            );
          },
        ),
        ListTile(
          leading: IconTheme(
            data: _iconcolor,
            child: Icon(Icons.rate_review),
          ),
          title: Text("Rate and Review", style: textStyle),
          onTap: () async {
            Navigator.of(context).pop();
            final url = Uri.parse(
                'https://play.google.com/store/apps/details?id=com.blueburn.numstatus');
            if (await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            }
          },
        ),
        ListTile(
          leading: IconTheme(
            data: _iconcolor,
            child: Icon(Icons.security),
          ),
          title: Text("Privacy Policy", style: textStyle),
          onTap: () async {
            Navigator.of(context).pop();
            final url = Uri.parse('https://blueburn.in');
            if (await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            }
          },
        ),
      ],
    );
  }
}
