import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:path_provider/path_provider.dart';
import 'package:numstatus/pages/video_play.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

final Directory _videoDir =
    Directory('/storage/emulated/0/WhatsApp/Media/.Statuses');

final Directory _videoDir2 = Directory(
    '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/.Statuses');

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
    if (!Directory(_videoDir.path).existsSync() &&
        !Directory(_videoDir2.path).existsSync()) {
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
                    "No Status Found\nYour Friend's Status will be available here.",
                    style: TextStyle(fontSize: 18.0),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      if (Directory(_videoDir2.path).existsSync()) {
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
  List<IMageClass> _list = [];
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

    _list = [];
    for (int i = 0; i < videoList.length; i++) {
      var image = IMageClass();
      if (i != 0 && i % 4 == 0) {
        image.type = "GoogleAd";
      } else {
        image.type = "";
        image.images = videoList[i];
      }
      _list.add(image);
    }

    Widget _getAdContainer() {
      if (_anchoredBanner != null)
        return AdWidget(ad: _anchoredBanner!);
      else
        return Container();
    }

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
                  if (index < _list.length && _list[index].type != "GoogleAd")
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
  if (Platform.isIOS) {
    return 'ca-app-pub-5924361002999470/4345357040';
  } else if (Platform.isAndroid) {
    return 'ca-app-pub-5924361002999470/4345357040';
  }
  return "";
}
