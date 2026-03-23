import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:localstorage/localstorage.dart';
import 'package:url_launcher/url_launcher.dart';

import 'numberList.dart';

class numberToChat extends StatefulWidget {
  numberToChat({Key? key}) : super(key: key);

  @override
  _numberToChatState createState() => _numberToChatState();
}

const int maxFailedLoadAttempts = 3;

class _numberToChatState extends State<numberToChat> {
  final _formKey = GlobalKey<FormState>();
  final contactNumber = TextEditingController();
  final message = TextEditingController();
  int countrycd = 91;

  static final AdRequest request = AdRequest();

  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;

  BannerAd? _anchoredBanner;
  bool _loadingAnchoredBanner = false;

  @override
  void initState() {
    super.initState();
    _createInterstitialAd();
  }

  void _createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: getInterstitialAdUnitId(),
        request: request,
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
          },
          onAdFailedToLoad: (LoadAdError error) {
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            if (_numInterstitialLoadAttempts <= maxFailedLoadAttempts) {
              _createInterstitialAd();
            }
          },
        ));
  }

  void _showInterstitialAd() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_interstitialAd == null) {
      _sendMessage();
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        _sendMessage();
        ad.dispose();
        _createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        _sendMessage();
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
      return;
    }

    final BannerAd banner = BannerAd(
      size: size,
      request: request,
      adUnitId: getBannerAdUnitId(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          setState(() {
            _anchoredBanner = ad as BannerAd?;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
        },
      ),
    );
    return banner.load();
  }

  void _onCountryChange(CountryCode countryCode) {
    countrycd = int.parse(countryCode.toString());
  }

  _addItem(String mobileNumber) {
    setState(() {
      var jsonData = localStorage.getItem('numbers');
      List parsedJson = [];
      if (jsonData != null) {
        parsedJson = json.decode(jsonData) ?? [];
      }
      var newData = {'mob': mobileNumber};
      parsedJson.add(newData);
      localStorage.setItem('numbers', json.encode(parsedJson));
    });
  }

  _sendMessage() async {
    setState(() {
      _addItem(countrycd.toString() + contactNumber.text);
    });

    final uri = Uri.parse(
        buildUrl(countrycd.toString() + contactNumber.text, message.text));
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  covid_certificate() async {
    final uri = Uri.parse(buildUrl("919013151515", "Main Menu"));
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
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
    return Scaffold(
        appBar: AppBar(
          title: Text("Number Status Download"),
          actions: <Widget>[],
          backgroundColor: Colors.deepOrange,
          elevation: 50.0,
          leading: IconButton(
            icon: Icon(Icons.shield),
            tooltip: 'Menu Icon',
            onPressed: () {},
          ),
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
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
        child: ListView(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: Card(
                elevation: 5,
                child: ClipPath(
                  clipper: ShapeBorderClipper(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3))),
                  child: InkWell(
                      onTap: () {
                        covid_certificate();
                      },
                      child: Image(
                        image: AssetImage('images/banner.jpg'),
                      )),
                ),
              ),
            ),
            Padding(
                padding: EdgeInsets.fromLTRB(10, 10, 10, 30),
                child: Card(
                  elevation: 5,
                  child: ClipPath(
                    child: Form(
                      key: _formKey,
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Row(
                                children: <Widget>[
                                  CountryCodePicker(
                                    onChanged: _onCountryChange,
                                    initialSelection: 'IN',
                                    favorite: ['+91', 'IN'],
                                    showCountryOnly: false,
                                    showOnlyCountryWhenClosed: false,
                                    alignLeft: false,
                                  ),
                                  Expanded(
                                    child: TextFormField(
                                      controller: contactNumber,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        hintText:
                                            'Type number without country code',
                                      ),
                                      validator: (value) {
                                        if (value!.isEmpty ||
                                            value.length < 8) {
                                          return 'Please enter a valid number';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          new MaterialPageRoute(
                                              builder: (context) =>
                                                  new NumberList()),
                                        );
                                      },
                                      child: Icon(Icons.history, size: 30))
                                ],
                              ),
                              TextFormField(
                                controller: message,
                                maxLines: 5,
                                decoration: const InputDecoration(
                                  hintText: 'Enter the message (optional)',
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 10),
                                child: ElevatedButton(
                                  child: Text('Send Message'),
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      _showInterstitialAd();
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepOrange,
                                      textStyle: TextStyle(fontSize: 20),
                                      minimumSize: Size(double.infinity, 50)),
                                ),
                              ),
                              Align(
                                alignment: Alignment(0, 1.0),
                                child: Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Text("Made with \u2764\uFE0F in India")),
                              ),
                              Container(
                                height: 100,
                                child: ClipPath(
                                  child: Align(
                                    alignment: Alignment(0, 1.0),
                                    child: SafeArea(
                                      child: Stack(
                                        alignment:
                                            AlignmentDirectional.bottomCenter,
                                        children: <Widget>[
                                          if (_anchoredBanner != null)
                                            Container(
                                              width: _anchoredBanner!.size.width
                                                  .toDouble(),
                                              height: _anchoredBanner!
                                                  .size.height
                                                  .toDouble(),
                                              child: AdWidget(
                                                  ad: _anchoredBanner!),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
        ));
  }
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
  if (Platform.isIOS) {
    return 'ca-app-pub-5924361002999470/4345357040';
  } else if (Platform.isAndroid) {
    return 'ca-app-pub-5924361002999470/4345357040';
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
