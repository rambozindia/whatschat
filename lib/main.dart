import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:localstorage/localstorage.dart';
import 'package:numstatus/pages/gamezop_cct.dart';
import 'package:numstatus/utils/theme.dart';

import 'numbertochat.dart';
import 'statusStartup.dart';
import 'aboutPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await initLocalStorage();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();

  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();
}

class _MyAppState extends State<MyApp> {
  final ThemeNotifier _themeNotifier = ThemeNotifier();

  @override
  void initState() {
    super.initState();
    _themeNotifier.addListener(() {
      setState(() {});
    });
  }

  ThemeNotifier get themeNotifier => _themeNotifier;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Number Status Download',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _themeNotifier.themeMode,
      home: MyHomePage(title: 'Number Status Download'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _page = 0;
  GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.grey[850]! : Colors.deepOrange;

    return Scaffold(
        bottomNavigationBar: CurvedNavigationBar(
          key: _bottomNavigationKey,
          index: 0,
          height: 60.0,
          items: <Widget>[
            Icon(Icons.add, size: 30),
            Icon(Icons.collections, size: 30),
            Icon(Icons.gamepad, size: 30),
            Icon(Icons.perm_identity, size: 30),
          ],
          color: isDark ? Colors.grey[800]! : Colors.white,
          buttonBackgroundColor: isDark ? Colors.grey[800]! : Colors.white,
          backgroundColor: bgColor,
          animationCurve: Curves.easeInOut,
          animationDuration: Duration(milliseconds: 300),
          onTap: (index) {
            setState(() {
              _page = index;
            });
          },
          letIndexChange: (index) => true,
        ),
        body: IndexedStack(
          index: _page,
          children: <Widget>[
            numberToChat(),
            statusStartup(),
            GamezopCct(),
            aboutPage(),
          ],
        ));
  }
}
