import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:localstorage/localstorage.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:numstatus/utils/constants.dart';
import 'package:numstatus/pages/qr_scanner.dart';
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
  String? _clipboardNumber;
  String _selectedCountryName = 'India';

  static final AdRequest request = AdRequest();

  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;

  BannerAd? _anchoredBanner;
  bool _loadingAnchoredBanner = false;

  @override
  void initState() {
    super.initState();
    _createInterstitialAd();
    _checkClipboard();
  }

  Future<void> _checkClipboard() async {
    try {
      final clipData = await Clipboard.getData(Clipboard.kTextPlain);
      if (clipData?.text != null) {
        final text = clipData!.text!.trim();
        final cleaned = text.replaceAll(RegExp(r'[\s\-()]'), '');
        final phoneRegex = RegExp(r'^\+?\d{7,15}$');
        if (phoneRegex.hasMatch(cleaned)) {
          setState(() {
            _clipboardNumber = cleaned;
          });
        }
      }
    } catch (_) {}
  }

  void _useClipboardNumber() {
    if (_clipboardNumber != null) {
      String number = _clipboardNumber!;
      if (number.startsWith('+')) {
        number = number.substring(1);
      }
      // Try to extract country code (assume first 2-3 digits could be country code)
      contactNumber.text = number.length > 10
          ? number.substring(number.length - 10)
          : number;
      setState(() {
        _clipboardNumber = null;
      });
    }
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

    if (size == null) return;

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
    _selectedCountryName = countryCode.name ?? '';
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

  Future<void> _openQrScanner() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => QrScannerScreen()),
    );
    if (result != null && mounted) {
      String number = result;
      if (number.startsWith('+')) {
        number = number.substring(1);
      }
      contactNumber.text =
          number.length > 10 ? number.substring(number.length - 10) : number;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.grey[850]! : Colors.deepOrange;

    return Scaffold(
        appBar: AppBar(
          title: Text("Number Status Download"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.qr_code_scanner),
              tooltip: 'Scan QR Code',
              onPressed: _openQrScanner,
            ),
          ],
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          elevation: 50.0,
          leading: IconButton(
            icon: Icon(Icons.shield),
            tooltip: 'Menu Icon',
            onPressed: () {},
          ),
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        body: _getMain(bgColor));
  }

  @override
  void dispose() {
    super.dispose();
    _interstitialAd?.dispose();
    _anchoredBanner?.dispose();
  }

  Widget _getMain(Color bgColor) {
    if (!_loadingAnchoredBanner) {
      _loadingAnchoredBanner = true;
      _createAnchoredBanner(context);
    }
    return Container(
        color: bgColor,
        child: ListView(
          children: [
            // Clipboard detection banner
            if (_clipboardNumber != null)
              Padding(
                padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: Card(
                  color: Colors.green[50],
                  child: ListTile(
                    leading: Icon(Icons.content_paste, color: Colors.green),
                    title: Text('Phone number detected'),
                    subtitle: Text(_clipboardNumber!),
                    trailing: ElevatedButton(
                      child: Text('Use'),
                      onPressed: _useClipboardNumber,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green),
                    ),
                  ),
                ),
              ),
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
                                      onChanged: (value) {
                                        setState(() {});
                                      },
                                    ),
                                  ),
                                  InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  NumberList()),
                                        );
                                      },
                                      child: Icon(Icons.history, size: 30)),
                                  SizedBox(width: 8),
                                  InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  NumberList(showFavoritesOnly: true)),
                                        );
                                      },
                                      child: Icon(Icons.star, size: 30, color: Colors.amber)),
                                ],
                              ),
                              // Number info display
                              if (contactNumber.text.length >= 8)
                                Padding(
                                  padding: EdgeInsets.only(top: 4),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      '$_selectedCountryName (+$countrycd) ${contactNumber.text}',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600]),
                                    ),
                                  ),
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
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      _showInterstitialAd();
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepOrange,
                                      textStyle: TextStyle(fontSize: 20),
                                      minimumSize: Size(double.infinity, 50)),
                                  child: Text('Send Message'),
                                ),
                              ),
                              Align(
                                alignment: Alignment(0, 1.0),
                                child: Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Text(
                                        "Made with \u2764\uFE0F in India")),
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
