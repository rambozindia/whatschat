import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:numstatus/pages/file_manager_widget.dart';

class GamezopCct extends StatelessWidget {
  const GamezopCct({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Explore Games"),
          actions: <Widget>[],
          backgroundColor: Colors.deepOrange,
          elevation: 50.0,
          leading: IconButton(
            icon: Icon(Icons.gamepad),
            tooltip: 'Menu Icon',
            onPressed: () {},
          ),
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
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
                              child: ElevatedButton(
                                child: Text('Open File Manager'),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    new MaterialPageRoute(
                                        builder: (context) =>
                                            new FileManagerWidget()),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.deepOrange,
                                    textStyle: TextStyle(fontSize: 20),
                                    minimumSize: Size(double.infinity, 50)),
                              ),
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
    try {
      await launchUrl(
        Uri.parse('https://www.gamezop.com/?id=4868'),
        customTabsOptions: CustomTabsOptions(
          colorSchemes: CustomTabsColorSchemes.defaults(
            toolbarColor: Colors.white,
          ),
          shareState: CustomTabsShareState.off,
          urlBarHidingEnabled: false,
          showTitle: false,
        ),
        safariVCOptions: SafariViewControllerOptions(
          preferredBarTintColor: Theme.of(context).primaryColor,
          preferredControlTintColor: Colors.white,
          barCollapsingEnabled: false,
          entersReaderIfAvailable: false,
          dismissButtonStyle: SafariViewControllerDismissButtonStyle.close,
        ),
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
