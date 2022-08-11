import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';

class GamezopCct extends StatelessWidget {
  const GamezopCct({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new AppBar(
          title: Text("Explore Games"),
          actions: <Widget>[], //<Widget>[]
          backgroundColor: Colors.deepOrange,
          elevation: 50.0,
          leading: IconButton(
            icon: Icon(Icons.gamepad),
            tooltip: 'Menu Icon',
            onPressed: () {},
          ), //IconButton
          brightness: Brightness.dark,
        ), //AppBar
        body: Container(
            color: Colors.deepOrange,
            child: ListView(
              children: [
                Padding(
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 30),
                    child: Card(
                      elevation: 5,
                      child: ClipPath(
                        child: Center(
                          child: Card(
                            elevation: 5,
                            child: ClipPath(
                              clipper: ShapeBorderClipper(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(3))),
                              child: InkWell(
                                  onTap: () => _launchURL(context),
                                  child: Image(
                                    image: AssetImage(
                                        'images/gamezop_game_banner_vertical.jpg'),
                                  )),
                            ),
                          ),
                        ),
                        clipper: ShapeBorderClipper(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(3))),
                      ),
                    )),
              ],
            )));
  }

  Future<void> _launchURL(BuildContext context) async {
    final theme = Theme.of(context);
    try {
      await launch(
        'https://www.gamezop.com/?id=4868',
        customTabsOption: CustomTabsOption(
          toolbarColor: Colors.white,
          enableDefaultShare: false,
          enableUrlBarHiding: false,
          showPageTitle: false,
          animation: CustomTabsSystemAnimation.slideIn(),
          extraCustomTabs: const <String>[
            // ref. https://play.google.com/store/apps/details?id=org.mozilla.firefox
            'org.mozilla.firefox',
            // ref. https://play.google.com/store/apps/details?id=com.microsoft.emmx
            'com.microsoft.emmx',
          ],
        ),
        safariVCOption: SafariViewControllerOption(
          preferredBarTintColor: theme.primaryColor,
          preferredControlTintColor: Colors.white,
          barCollapsingEnabled: false,
          entersReaderIfAvailable: false,
          dismissButtonStyle: SafariViewControllerDismissButtonStyle.close,
        ),
      );
    } catch (e) {
      // An exception is thrown if browser app is not installed on Android device.
      debugPrint(e.toString());
    }
  }
}
