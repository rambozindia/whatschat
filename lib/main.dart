import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_open_whatsapp/flutter_open_whatsapp.dart';
import 'package:admob_flutter/admob_flutter.dart';
import 'package:country_code_picker/country_code_picker.dart';

void main() {
  Admob.initialize(getAppId());
  runApp(AdExampleApp());
}

class AdExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Number to WhatsChat',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        buttonTheme: ButtonThemeData(
          textTheme: ButtonTextTheme.primary,
          buttonColor: Colors.blue,
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            "Number to WhatsChat",
          ),
        ),
        body: AdsPage(),
      ),
    );
  }
}

class AdsPage extends StatefulWidget {
  @override
  AdsPageState createState() => AdsPageState();
}

//const String testDevice = 'd99973b5-b12d-407f-b1ec-cadd8f9c041e'; // OnePlus 6T
const String testDevice = '62204e47-0a2c-4df6-b3e0-89e1aac39cdb';

class AdsPageState extends State<AdsPage> {
  /// All widget ads are stored in this variable. When a button is pressed, its
  /// respective ad widget is set to this variable and the view is rebuilt using
  /// setState().
  final _formKey = GlobalKey<FormState>();
  final contactNumber = TextEditingController();
  final message = TextEditingController();
  bool _isInterstitialAdLoaded = false;
  int countrycd = 91;

  AdmobInterstitial interstitialAd;

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

    _showBannerAd();
    _showNativeBannerAd();
    _loadInterstitialAd();
  }

  void _loadInterstitialAd() {
    interstitialAd = AdmobInterstitial(
      adUnitId: getInterstitialAdUnitId(),
      listener: (AdmobAdEvent event, Map<String, dynamic> args) {
        if (event == AdmobAdEvent.closed) interstitialAd.load();
        handleEvent(event, args, 'Interstitial');
      },
    );

    interstitialAd.load();
  }

  void handleEvent(
      AdmobAdEvent event, Map<String, dynamic> args, String adType) {
    switch (event) {
      case AdmobAdEvent.loaded:
        print('New Admob $adType Ad loaded!');
        _isInterstitialAdLoaded = true;
        break;
      case AdmobAdEvent.opened:
        print('Admob $adType Ad opened!');
        break;
      case AdmobAdEvent.closed:
        print('Admob $adType Ad closed!');
        _sendMessage();
        break;
      case AdmobAdEvent.failedToLoad:
        print('Admob $adType failed to load. :(');
        _isInterstitialAdLoaded = false;
        break;
      default:
        print(event);
    }
  }

  void _onCountryChange(CountryCode countryCode) {
    countrycd = int.parse(countryCode.toString());
    print(countrycd);
  }

  _sendMessage() {
    FlutterOpenWhatsapp.sendSingleMessage(
        countrycd.toString() + contactNumber.text, message.text);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Flexible(
          child: Align(
            alignment: Alignment(0, -1.0),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: _getMain(),
            ),
          ),
          fit: FlexFit.tight,
          flex: 4,
        ),
        // Column(children: <Widget>[
        //   _nativeAd(),
        //   // _nativeBannerAd(),
        //   _nativeAd(),
        // ],),
        Flexible(
          child: Align(
            alignment: Alignment(0, 1.0),
            child: _currentAd,
          ),
          fit: FlexFit.tight,
          flex: 1,
        )
      ],
    );
  }

  @override
  void dispose() {
    interstitialAd.dispose();
    super.dispose();
  }

  Widget _getMain() {
    return Form(
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
                    if (value.isEmpty || value.length < 10) {
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
          Align(
            alignment: Alignment(0, 1.0),
            child: _currentAd2,
          ),
          RaisedButton(
            onPressed: () {
              if (_formKey.currentState.validate()) {
                _showInterstitialAd();
              }
            },
            child: Text('Message on WhatsApp'),
            color: Colors.lightBlue,
            textColor: Colors.white,
            padding: EdgeInsets.fromLTRB(9, 9, 9, 9),
            splashColor: Colors.grey,
          ),
          Align(
            alignment: Alignment(0, 1.0),
            child: Text("Made love with India"),
          ),
        ]),
      ),
    );
  }

  _showInterstitialAd() {
    if (_isInterstitialAdLoaded == true)
      interstitialAd.show();
    else {
      _sendMessage();
      print("Interstial Ad not yet loaded!");
    }
  }

  _showBannerAd() {
    setState(() {
      _currentAd2 = AdmobBanner(
        adUnitId: getBannerAdUnitId(),
        adSize: AdmobBannerSize.BANNER,
        listener: (AdmobAdEvent event, Map<String, dynamic> args) {
          print("ADS ------------------");
          print(args);
        },
      );
    });
  }

  _showNativeBannerAd() {
    setState(() {
      _currentAd = AdmobBanner(
        adUnitId: getNativedUnitId(),
        adSize: AdmobBannerSize.SMART_BANNER,
        listener: (AdmobAdEvent event, Map<String, dynamic> args) {
          print("ADS ------------------");
          print(args);
        },
      );
    });
  }

  // _showNativeAd() {
  //   setState(() {
  //     _currentAd = _nativeAd();
  //   });
  // }

  // Widget _nativeAd() {
  //   return FacebookNativeAd(
  //     placementId: "1815765095104804_3708593532488608",
  //     adType: NativeAdType.NATIVE_AD,
  //     width: double.infinity,
  //     height: 300,
  //     backgroundColor: Colors.blue,
  //     titleColor: Colors.white,
  //     descriptionColor: Colors.white,
  //     buttonColor: Colors.deepPurple,
  //     buttonTitleColor: Colors.white,
  //     buttonBorderColor: Colors.white,
  //     listener: (result, value) {
  //       print("Native Ad: $result --> $value");
  //     }
  //   );
  // }

}

String getAppId() {
  if (Platform.isIOS) {
    return 'ca-app-pub-5924361002999470~6378678384';
  } else if (Platform.isAndroid) {
    return 'ca-app-pub-5924361002999470~6378678384';
  }
  return null;
}

String getBannerAdUnitId() {
  if (Platform.isIOS) {
    return 'ca-app-pub-5924361002999470/2628163306';
  } else if (Platform.isAndroid) {
    return 'ca-app-pub-5924361002999470/2628163306';
  }
  return null;
}

String getNativedUnitId() {
  //'ca-app-pub-5924361002999470/4345357040'  on admob for native
  if (Platform.isIOS) {
    return 'ca-app-pub-5924361002999470/4345357040';
  } else if (Platform.isAndroid) {
    return 'ca-app-pub-5924361002999470/2628163306';
  }
  return null;
}

String getInterstitialAdUnitId() {
  if (Platform.isIOS) {
    return 'ca-app-pub-5924361002999470/4978515543';
  } else if (Platform.isAndroid) {
    return 'ca-app-pub-5924361002999470/4978515543';
  }
  return null;
}
