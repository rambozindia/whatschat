import 'dart:io';

import 'package:flutter/material.dart';
import 'package:whatschat/pages/photos.dart';
import 'package:whatschat/pages/videos.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

const String testDevice = '23A44FB0C82D65578152895CA43B5854';
const int maxFailedLoadAttempts = 3;

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  static final AdRequest request = AdRequest(
    keywords: <String>['foo', 'bar'],
    contentUrl: 'http://foo.com/bar.html',
    nonPersonalizedAds: true,
  );

  BannerAd? _anchoredBanner;
  bool _loadingAnchoredBanner = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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

  @override
  void dispose() {
    _anchoredBanner?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.deepOrange,
      child: DefaultTabController(
        length: 2,
        initialIndex: 0,
        child: Scaffold(
          appBar: AppBar(
            title: Text("WhatsApp Status Downloader"),
            backgroundColor: Colors.deepOrange,
            elevation: 50.0,
            leading: IconButton(
              icon: Icon(Icons.download),
              tooltip: 'Menu Icon',
              onPressed: () {},
            ), //IconButton
            brightness: Brightness.dark,
            bottom: TabBar(
              controller: _tabController,
              tabs: [
                Tab(icon: Icon(Icons.photo)),
                Tab(icon: Icon(Icons.videocam)),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: <Widget>[
              Photos(),
              VideoListView(),
            ],
          ),
        ),
      ),
    );
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
