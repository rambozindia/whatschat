import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatefulWidget {
  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  @override
  void initState() {
    super.initState();
  }

  _launchURL() async {
    final url = Uri.parse('https://blueburn.in');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("About us"),
        backgroundColor: Colors.deepOrange,
        elevation: 50.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          tooltip: 'Menu Icon',
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: Container(
        color: Colors.deepOrange,
        child: Padding(
          padding: EdgeInsets.fromLTRB(10, 30, 10, 30),
          child: Card(
            elevation: 5,
            child: ClipPath(
              child: ListView(children: <Widget>[
                Container(
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("About Us",
                            style: TextStyle(
                              fontSize: 24.0,
                              color: Colors.white,
                            )),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(20.0),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                            "Number Status Download"
                            "\n\nNumber Status Download app lets you send messages to any numbers not saved in your contacts.\n- How it works?\n1. Enter a number to which you are going to send message.\n2. Type your text message and tap on send button.\n3. This will take you to the chat window created with the given number.",
                            style: TextStyle(
                              fontSize: 18.0,
                              color: Colors.indigo,
                            )),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 20.0),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                MaterialButton(
                                  onPressed: () {
                                    _launchURL();
                                  },
                                  padding: EdgeInsets.all(20.0),
                                  child: Text("Read More",
                                      style: TextStyle(
                                        fontSize: 24.0,
                                        color: Colors.white,
                                      )),
                                  color: Colors.deepOrange,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
