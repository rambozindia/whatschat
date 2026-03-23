import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:numstatus/pages/photos.dart';
import 'package:numstatus/pages/videos.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  static final AdRequest request = AdRequest();

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
            title: Text("Status Downloader"),
            backgroundColor: Colors.deepOrange,
            elevation: 50.0,
            leading: IconButton(
              icon: Icon(Icons.download),
              tooltip: 'Menu Icon',
              onPressed: () {},
            ),
            systemOverlayStyle: SystemUiOverlayStyle.light,
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
