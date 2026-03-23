import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:localstorage/localstorage.dart';
import 'package:url_launcher/url_launcher.dart';

class NumberList extends StatefulWidget {
  NumberList({Key? key}) : super(key: key);

  @override
  _MyNumberListState createState() => _MyNumberListState();
}

class _MyNumberListState extends State<NumberList> {
  bool initialized = false;
  var mobNumbers = [];

  _clearStorage() {
    localStorage.clear();
    setState(() {
      mobNumbers = [];
    });
  }

  _refreshStorage() {
    setState(() {
      var jsonData = localStorage.getItem('numbers');
      if (jsonData != null) {
        mobNumbers = json.decode(jsonData) ?? [];
      } else {
        mobNumbers = [];
      }
    });
  }

  _sendMessage(contactNumber) async {
    if (initialized) {
      final uri = Uri.parse(buildUrl(contactNumber, ""));
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  String buildUrl(String phone, String message) {
    if (Platform.isAndroid) {
      return "https://wa.me/$phone/?text=${Uri.encodeComponent(message)}";
    } else {
      return "https://api.whatsapp.com/send?phone=$phone&text=${Uri.encodeComponent(message)}";
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!initialized) {
      var jsonData = localStorage.getItem('numbers');
      if (jsonData != null) {
        var parsedJson = json.decode(jsonData) ?? [];
        mobNumbers.addAll(parsedJson);
      }
      initialized = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Recent Numbers"),
        actions: <Widget>[],
        backgroundColor: Colors.deepOrange,
        elevation: 50.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          tooltip: 'Menu Icon',
          onPressed: () => Navigator.of(context).pop(),
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
              child: Center(
                child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: EdgeInsets.all(1.0),
                    constraints: BoxConstraints.expand(),
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
                            itemCount: mobNumbers.length,
                            itemBuilder: (BuildContext context, int index) {
                              return GestureDetector(
                                  child: Container(
                                      padding: const EdgeInsets.fromLTRB(
                                          10, 0, 10, 0),
                                      height: 50,
                                      color: Colors.orange,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Align(
                                                alignment:
                                                    Alignment.centerLeft,
                                                child: Text(
                                                    mobNumbers[index]
                                                        ['mob'])),
                                          ),
                                          Align(
                                            alignment:
                                                Alignment.centerRight,
                                            child: Row(
                                              children: [
                                                Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: IconButton(
                                                    icon: Icon(Icons.send),
                                                    tooltip: 'Send Message',
                                                    onPressed: () {
                                                      launchUrl(
                                                          Uri.parse(buildUrl(
                                                              mobNumbers[
                                                                      index]
                                                                  ['mob'],
                                                              "")),
                                                          mode: LaunchMode
                                                              .externalApplication);
                                                    },
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: Icon(Icons.call),
                                                  tooltip: 'call',
                                                  onPressed: () {
                                                    launchUrl(Uri.parse(
                                                        'tel:+${mobNumbers[index]['mob']}'));
                                                  },
                                                ),
                                                IconButton(
                                                  icon: Icon(Icons.sms),
                                                  tooltip: 'Message',
                                                  onPressed: () {
                                                    launchUrl(Uri.parse(
                                                        'sms:+${mobNumbers[index]['mob']}'));
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )),
                                  onTap: () {
                                    _sendMessage(mobNumbers[index]['mob']);
                                  });
                            },
                            separatorBuilder:
                                (BuildContext context, int index) =>
                                    const Divider(),
                          ),
                        ),
                        ListTile(
                          title: Row(
                            children: <Widget>[
                              Expanded(
                                child: ElevatedButton.icon(
                                  icon: Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                    size: 20.0,
                                  ),
                                  label: Text('Clear'),
                                  onPressed: _clearStorage,
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepOrange,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 25, vertical: 10),
                                      textStyle: TextStyle(fontSize: 20)),
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton.icon(
                                  icon: Icon(
                                    Icons.refresh,
                                    color: Colors.white,
                                    size: 20.0,
                                  ),
                                  label: Text('Refresh'),
                                  onPressed: _refreshStorage,
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepOrange,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 25, vertical: 10),
                                      textStyle: TextStyle(fontSize: 20)),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    )),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
