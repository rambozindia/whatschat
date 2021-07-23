import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_whatsapp/open_whatsapp.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:localstorage/localstorage.dart';

class numberToChat extends StatefulWidget {
  numberToChat({Key? key}) : super(key: key);

  @override
  _numberToChatState createState() => _numberToChatState();
}

const String testDevice = '62204e47-0a2c-4df6-b3e0-89e1aac39cdb';
const int maxFailedLoadAttempts = 3;

class _numberToChatState extends State<numberToChat> {
  final _formKey = GlobalKey<FormState>();
  final contactNumber = TextEditingController();
  final message = TextEditingController();
  final LocalStorage storage = new LocalStorage('todo_app.json');

  bool _isInterstitialAdLoaded = false;
  int countrycd = 91;
  static final AdRequest request = AdRequest(
    keywords: <String>['foo', 'bar'],
    contentUrl: 'http://foo.com/bar.html',
    nonPersonalizedAds: true,
  );

  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;

  BannerAd? _anchoredBanner;
  bool _loadingAnchoredBanner = false;

  Widget _currentAd = SizedBox(
    width: 0.0,
    height: 0.0,
  );
  Widget _currentAd2 = SizedBox(
    width: 0.0,
    height: 0.0,
  );

  @override
  void initState() {
    super.initState();

    _createInterstitialAd();

    // _loadInterstitialAd();
  }

  void _createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: InterstitialAd.testAdUnitId,
        request: request,
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            print('$ad loaded');
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error.');
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            if (_numInterstitialLoadAttempts <= maxFailedLoadAttempts) {
              _createInterstitialAd();
            }
          },
        ));
  }

  void _showInterstitialAd() {
    if (_interstitialAd == null) {
      _sendMessage();
      print('Warning: attempt to show interstitial before loaded.');
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        _sendMessage();
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        // _sendMessage();
        ad.dispose();
        _createInterstitialAd();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }

  Future<void> _createAnchoredBanner(BuildContext context) async {
    final AnchoredAdaptiveBannerAdSize? size =
        await AdSize.getAnchoredAdaptiveBannerAdSize(
      Orientation.portrait,
      MediaQuery.of(context).size.width.truncate(),
    );

    if (size == null) {
      print('Unable to get height of anchored banner.');
      return;
    }

    final BannerAd banner = BannerAd(
      size: size,
      request: request,
      adUnitId: getBannerAdUnitId(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          print('$BannerAd loaded.');
          setState(() {
            _anchoredBanner = ad as BannerAd?;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('$BannerAd failedToLoad: $error');
          ad.dispose();
        },
        onAdOpened: (Ad ad) => print('$BannerAd onAdOpened.'),
        onAdClosed: (Ad ad) => print('$BannerAd onAdClosed.'),
      ),
    );
    return banner.load();
  }

  void _onCountryChange(CountryCode countryCode) {
    countrycd = int.parse(countryCode.toString());
    print(countrycd);
  }

  _addItem(String mobileNumber) {
    setState(() {
      var jsonData = storage.getItem('numbers').toString();
      var parsedJson = json.decode(jsonData) ?? [];
      var newData = {'mob': mobileNumber};
      parsedJson.add(newData);
      storage.setItem('numbers', json.encode(parsedJson).toString());
      print("================================");
      print(storage.getItem('numbers'));
    });
  }

  _sendMessage() {
    _addItem(countrycd.toString() + contactNumber.text);
    FlutterOpenWhatsapp.sendSingleMessage(
        countrycd.toString() + contactNumber.text, message.text);

    print(countrycd.toString() +
        contactNumber.text +
        message.text +
        "========-----");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Number to WhatsChat"),
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
        body: _getMain());
  }

  @override
  void dispose() {
    super.dispose();
    _interstitialAd?.dispose();
    _anchoredBanner?.dispose();
  }

  Widget _getMain() {
    if (!_loadingAnchoredBanner) {
      _loadingAnchoredBanner = true;
      _createAnchoredBanner(context);
    }
    return Container(
      color: Colors.deepOrange,
      child: Padding(
        padding: EdgeInsets.fromLTRB(10, 30, 10, 30),
        child: Card(
          elevation: 5,
          child: ClipPath(
            child: Form(
              key: _formKey,
              child: Center(
                child: ListView(padding: EdgeInsets.all(10), children: <Widget>[
                  Row(
                    children: <Widget>[
                      CountryCodePicker(
                        onChanged: _onCountryChange,
                        // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                        initialSelection: 'IN',
                        favorite: ['+91', 'IN'],
                        // optional. Shows only country name and flag
                        showCountryOnly: false,
                        // optional. Shows only country name and flag when popup is closed.
                        showOnlyCountryWhenClosed: false,
                        // optional. aligns the flag and the Text left
                        alignLeft: false,
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: contactNumber,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: 'Type number without country code',
                          ),
                          validator: (value) {
                            if (value != "" || value!.length < 8) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  TextFormField(
                    controller: message,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      hintText: 'Enter the message (optional)',
                    ),
                  ),
                  ElevatedButton(
                    child: Text('Message on WhatsApp'),
                    onPressed: () {
                      _showInterstitialAd();
                    },
                    style: ElevatedButton.styleFrom(
                        primary: Colors.deepOrange,
                        padding:
                            EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                        textStyle: TextStyle(fontSize: 20)),
                  ),
                  Align(
                    alignment: Alignment(0, 1.0),
                    child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text("Made with ❤️ in India")),
                  ),
                  // Align(
                  //   alignment: Alignment(0, 1.0),
                  //   child: SafeArea(
                  //     child: Stack(
                  //       alignment: AlignmentDirectional.bottomCenter,
                  //       children: <Widget>[
                  //         if (_anchoredBanner != null)
                  //           Container(
                  //             color: Colors.green,
                  //             width: _anchoredBanner!.size.width.toDouble(),
                  //             height: _anchoredBanner!.size.height.toDouble(),
                  //             child: AdWidget(ad: _anchoredBanner!),
                  //           ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                ]),
              ),
            ),
            clipper: ShapeBorderClipper(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3))),
          ),
        ),
      ),
    );
  }
}

String getAppId() {
  if (Platform.isIOS) {
    return 'ca-app-pub-5924361002999470~6378678384';
  } else if (Platform.isAndroid) {
    return 'ca-app-pub-5924361002999470~6378678384';
  }
  return "";
}

String getBannerAdUnitId() {
  if (Platform.isIOS) {
    return 'ca-app-pub-5924361002999470/2628163306';
  } else if (Platform.isAndroid) {
    return 'ca-app-pub-5924361002999470/2628163306';
  }
  return "";
}

String getNativedUnitId() {
  //'ca-app-pub-5924361002999470/4345357040'  on admob for native
  if (Platform.isIOS) {
    return 'ca-app-pub-5924361002999470/4345357040';
  } else if (Platform.isAndroid) {
    return 'ca-app-pub-5924361002999470/2628163306';
  }
  return "";
}

String getInterstitialAdUnitId() {
  if (Platform.isIOS) {
    return 'ca-app-pub-5924361002999470/4978515543';
  } else if (Platform.isAndroid) {
    return 'ca-app-pub-5924361002999470/4978515543';
  }
  return "";
}
