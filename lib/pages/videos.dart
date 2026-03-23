import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:path_provider/path_provider.dart';
import 'package:numstatus/pages/video_play.dart';
import 'package:numstatus/utils/constants.dart' show getBannerAdUnitId;
import 'package:numstatus/utils/status_directory_helper.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class VideoListView extends StatefulWidget {
  final String appType;
  VideoListView({Key? key, this.appType = 'whatsapp'}) : super(key: key);

  @override
  VideoListViewState createState() => VideoListViewState();
}

class VideoListViewState extends State<VideoListView> {
  @override
  Widget build(BuildContext context) {
    if (!hasAnyStatusDirs(widget.appType)) {
      return Scaffold(
        body: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Padding(
            padding: EdgeInsets.fromLTRB(10, 30, 10, 30),
            child: Card(
              elevation: 5,
              child: Center(
                child: Text(
                  "No Status Found\nYour Friend's Status will be available here.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18.0),
                ),
              ),
            ),
          ),
        ),
      );
    }

    final videoList = getStatusVideos(widget.appType);
    if (videoList.isNotEmpty) {
      return Scaffold(
        body: VideoGrid(videoList: videoList),
      );
    } else {
      return Scaffold(
        body: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Padding(
            padding: EdgeInsets.fromLTRB(10, 30, 10, 30),
            child: Card(
              elevation: 5,
              child: Center(
                child: Text(
                  "Sorry, No Videos Found.",
                  style: TextStyle(fontSize: 18.0),
                ),
              ),
            ),
          ),
        ),
      );
    }
  }
}

class VideoGrid extends StatefulWidget {
  final List<String> videoList;

  const VideoGrid({Key? key, required this.videoList}) : super(key: key);

  @override
  _VideoGridState createState() => _VideoGridState();
}

class _VideoGridState extends State<VideoGrid> {
  BannerAd? _anchoredBanner;
  bool _loadingAnchoredBanner = false;

  _getImage2(videoPathUrl) async {
    final fileName = await VideoThumbnail.thumbnailFile(
      video: videoPathUrl,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.WEBP,
      maxWidth: 155,
      quality: 50,
    );
    return fileName;
  }

  static final AdRequest request = AdRequest();

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

  @override
  void dispose() {
    super.dispose();
    _anchoredBanner?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loadingAnchoredBanner) {
      _loadingAnchoredBanner = true;
      _createAnchoredBanner(context);
    }

    final videoList = widget.videoList;

    Widget _getAdContainer() {
      if (_anchoredBanner != null)
        return AdWidget(ad: _anchoredBanner!);
      else
        return Container();
    }

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Padding(
        padding: EdgeInsets.fromLTRB(10, 30, 10, 30),
        child: Card(
          elevation: 5,
          child: ClipPath(
            child: MasonryGridView.count(
              crossAxisSpacing: 3.0,
              mainAxisSpacing: 3.0,
              itemCount: videoList.length,
              physics: ScrollPhysics(),
              itemBuilder: (context, index) {
                if (index % 4 != 0 || index == 0)
                  return Container(
                    padding: EdgeInsets.all(10.0),
                    child: InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                PlayStatusVideo(videoList[index])),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight,
                            stops: [0.1, 0.3, 0.5, 0.7, 0.9],
                            colors: [
                              Color(0xffb7d8cf),
                              Color(0xffb7d8cf),
                              Color(0xffb7d8cf),
                              Color(0xffb7d8cf),
                              Color(0xffb7d8cf),
                            ],
                          ),
                          borderRadius:
                              BorderRadius.all(Radius.circular(8)),
                        ),
                        child: FutureBuilder(
                            future: _getImage2(videoList[index]),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                if (snapshot.hasData) {
                                  return Column(children: <Widget>[
                                    Hero(
                                      tag: videoList[index],
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    PlayStatusVideo(
                                                        videoList[index])),
                                          );
                                        },
                                        child: Image.file(
                                          File(snapshot.data.toString()),
                                          height: 155,
                                        ),
                                      ),
                                    ),
                                  ]);
                                } else {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                              } else {
                                return Hero(
                                  tag: videoList[index],
                                  child: Container(
                                    height: 170,
                                    child: Image.asset(
                                        "images/video_loader.gif"),
                                  ),
                                );
                              }
                            }),
                      ),
                    ),
                  );
                else
                  return _getAdContainer();
              },
              crossAxisCount: 2,
            ),
          ),
        ),
      ),
    );
  }
}
