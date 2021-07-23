import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:open_whatsapp/open_whatsapp.dart';

import 'package:localstorage/localstorage.dart';
import 'package:url_launcher/url_launcher.dart';

class NumberList extends StatefulWidget {
  NumberList({Key? key}) : super(key: key);

  @override
  _MyNumberListState createState() => new _MyNumberListState();
}

class _MyNumberListState extends State<NumberList> {
  final LocalStorage storage = new LocalStorage('todo_app.json');
  bool initialized = false;
  var mobNumbers = [];

  _clearStorage() async {
    await storage.clear();

    setState(() {
      mobNumbers = storage.getItem('numbers') ?? [];
    });
  }

  _refreshStorage() async {
    setState(() {
      mobNumbers = json.decode(storage.getItem('numbers')) ?? [];
    });
  }

  _sendMessage(contactNumber) {
    if (initialized) FlutterOpenWhatsapp.sendSingleMessage(contactNumber, "");
  }

  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: Text("Recent Numbers"),
        actions: <Widget>[], //<Widget>[]
        backgroundColor: Colors.deepOrange,
        elevation: 50.0,
        leading: IconButton(
          icon: Icon(Icons.shield),
          tooltip: 'Menu Icon',
          onPressed: () {},
        ), //IconButton
        brightness: Brightness.dark,
      ), //AppBar
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
                          child: FutureBuilder(
                            future: storage.ready,
                            builder:
                                (BuildContext context, AsyncSnapshot snapshot) {
                              if (snapshot.data == null) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              if (!initialized) {
                                var jsonData =
                                    storage.getItem('numbers').toString();
                                var parsedJson = json.decode(jsonData) ?? [];
                                print(parsedJson);
                                mobNumbers.addAll(parsedJson);
                                initialized = true;
                              }
                              return ListView.separated(
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
                                                        icon: Icon(Icons.call),
                                                        tooltip: 'call',
                                                        onPressed: () {
                                                          launch('tel:+' +
                                                              mobNumbers[index]
                                                                  ['mob']);
                                                        },
                                                      ),
                                                    ),
                                                    IconButton(
                                                      icon: Icon(Icons.send),
                                                      tooltip: 'Whatsapp',
                                                      onPressed: () {
                                                        _sendMessage(
                                                            mobNumbers[index]
                                                                ['mob']);
                                                        print("object========");
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          )),
                                      onTap: () {
                                        _sendMessage(mobNumbers[index]['mob']);
                                        print("object========");
                                      });
                                },
                                separatorBuilder:
                                    (BuildContext context, int index) =>
                                        const Divider(),
                              );
                            },
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
                                    size: 24.0,
                                  ),
                                  label: Text('Clear'),
                                  onPressed: _clearStorage,
                                  style: ElevatedButton.styleFrom(
                                      primary: Colors.deepOrange,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 30, vertical: 10),
                                      textStyle: TextStyle(fontSize: 20)),
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton.icon(
                                  icon: Icon(
                                    Icons.refresh,
                                    color: Colors.white,
                                    size: 24.0,
                                  ),
                                  label: Text('Refresh'),
                                  onPressed: _refreshStorage,
                                  style: ElevatedButton.styleFrom(
                                      primary: Colors.deepOrange,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 30, vertical: 10),
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
