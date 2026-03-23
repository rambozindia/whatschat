import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

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
    return ListView(
      padding: EdgeInsets.all(0),
      children: <Widget>[
        UserAccountsDrawerHeader(
          accountName: Text(
            "Welcome to Status Downloader",
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
          accountEmail: Text("Easily Download Status"),
          currentAccountPicture: Image.asset('images/avatar.png'),
        ),
        ListTile(
          leading: IconTheme(
            data: _iconcolor,
            child: Icon(Icons.photo_library),
          ),
          title: Text("Photo Status", style: _menutextcolor),
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
          title: Text("Video Status", style: _menutextcolor),
          onTap: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushNamed("/videos");
          },
        ),
        ListTile(
          leading: IconTheme(
            data: _iconcolor,
            child: Icon(Icons.info),
          ),
          title: Text("About Us", style: _menutextcolor),
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
          title: Text("Share with Friends", style: _menutextcolor),
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
          title: Text("Rate and Review", style: _menutextcolor),
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
          title: Text("Privacy Policy", style: _menutextcolor),
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
