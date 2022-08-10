import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:whatschat/pages/video_play.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

final Directory _videoDir =
    new Directory('/storage/emulated/0/WhatsApp/Media/.Statuses');

final Directory _videoDir2 = new Directory(
    '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/.Statuses');

List<IMageClass> _list = [];

BannerAd? _anchoredBanner;
bool _loadingAnchoredBanner = false;

final AdRequest request = AdRequest(
  keywords: <String>['foo', 'bar'],
  contentUrl: 'http://foo.com/bar.html',
  nonPersonalizedAds: true,
);

class VideoListView extends StatefulWidget {
  @override
  VideoListViewState createState() {
    return new VideoListViewState();
  }
}

class VideoListViewState extends State<VideoListView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!Directory("${_videoDir.path}").existsSync() &&
        !Directory("${_videoDir2.path}").existsSync()) {
      return Scaffold(
        body: Container(
          color: Colors.deepOrange,
          child: Padding(
            padding: EdgeInsets.fromLTRB(10, 30, 10, 30),
            child: Card(
              elevation: 5,
              child: ClipPath(
                child: Center(
                  child: Text(
                    "Install WhatsApp\nYour Friend's Status will be available here.",
                    style: TextStyle(fontSize: 18.0),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      if (Directory("${_videoDir2.path}").existsSync()) {
        return Scaffold(
          body: VideoGrid(directory: _videoDir2),
        );
      } else {
        return Scaffold(
          body: VideoGrid(directory: _videoDir),
        );
      }
    }
  }
}

class VideoGrid extends StatefulWidget {
  final Directory directory;

  const VideoGrid({Key? key, required this.directory}) : super(key: key);

  @override
  _VideoGridState createState() => _VideoGridState();
}

class _VideoGridState extends State<VideoGrid> {
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
        // onAdOpened: (Ad ad) => print('$BannerAd onAdOpened.'),
        // onAdClosed: (Ad ad) => print('$BannerAd onAdClosed.'),
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

    var videoList = widget.directory
        .listSync()
        .map((item) => item.path)
        .where((item) => item.endsWith(".mp4"))
        .toList(growable: false);

    void _getData() {
      for (int i = 0; i < videoList.length; i++) {
        var image = IMageClass();

        if (i != 0) {
          if (i % 4 == 0) {
            image.type = "GoogleAd";
          } else {
            image.type = "";
            image.images = videoList[i];
          }
          _list.add(image);
        } else {
          image.type = "";
          image.images = videoList[i];
          _list.add(image);
        }
      }
    }

    _getData();

    Widget _getAdContainer() {
      if (_anchoredBanner != null)
        return AdWidget(ad: _anchoredBanner!);
      else
        return Container();
    }

    if (videoList != null) {
      if (videoList.length > 0) {
        return Container(
          color: Colors.deepOrange,
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
                    if (_list[index].type != "GoogleAd")
                      return Container(
                        padding: EdgeInsets.all(10.0),
                        child: InkWell(
                          onTap: () => Navigator.push(
                            context,
                            new MaterialPageRoute(
                                builder: (context) =>
                                    new PlayStatusVideo(videoList[index])),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                // Where the linear gradient begins and ends
                                begin: Alignment.bottomLeft,
                                end: Alignment.topRight,
                                // Add one stop for each color. Stops should increase from 0 to 1
                                stops: [0.1, 0.3, 0.5, 0.7, 0.9],
                                colors: [
                                  // Colors are easy thanks to Flutter's Colors class.
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
                                                new MaterialPageRoute(
                                                    builder: (context) =>
                                                        new PlayStatusVideo(
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
                            //new cod
                          ),
                        ),
                      );
                    else
                      return _getAdContainer();
                  },
                  crossAxisCount: 2,
                  // staggeredTileBuilder: (int index) {
                  //   if (_list[index].type != "GoogleAd")
                  //     return StaggeredTile.count(1, 1);
                  //   else
                  //     return StaggeredTile.count(2, 1);
                  //   // return StaggeredTile.count(1, 1);
                  // },
                ),
              ),
            ),
          ),
        );
      } else {
        return Scaffold(
          body: Container(
            color: Colors.deepOrange,
            child: Padding(
              padding: EdgeInsets.fromLTRB(10, 30, 10, 30),
              child: Card(
                elevation: 5,
                child: ClipPath(
                  child: Center(
                    child: Text(
                      "Sorry, No Videos Found.",
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }
    } else {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
  }
}

class IMageClass {
  late String images;
  late String type;
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
    return 'ca-app-pub-5924361002999470/4345357040';
  }
  return "";
}
