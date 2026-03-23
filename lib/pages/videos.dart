import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:numstatus/models/status_file.dart';
import 'package:numstatus/pages/video_play.dart';
import 'package:numstatus/services/saf_directory_service.dart';
import 'package:numstatus/utils/constants.dart' show getBannerAdUnitId;
import 'package:numstatus/utils/status_directory_helper.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.grey[850] : Colors.deepOrange;

    return FutureBuilder<List<StatusFile>>(
      future: getStatusVideos(widget.appType),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            body: Container(
              color: bgColor,
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final videoList = snapshot.data ?? [];

        if (videoList.isEmpty) {
          return Scaffold(
            body: Container(
              color: bgColor,
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

        return Scaffold(
          body: VideoGrid(videoList: videoList),
        );
      },
    );
  }
}

class VideoGrid extends StatefulWidget {
  final List<StatusFile> videoList;

  const VideoGrid({Key? key, required this.videoList}) : super(key: key);

  @override
  _VideoGridState createState() => _VideoGridState();
}

class _VideoGridState extends State<VideoGrid> {
  BannerAd? _anchoredBanner;
  bool _loadingAnchoredBanner = false;

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

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.grey[850] : Colors.deepOrange;

    return Container(
      color: bgColor,
      child: Padding(
        padding: EdgeInsets.fromLTRB(10, 30, 10, 30),
        child: Card(
          elevation: 5,
          child: ClipPath(
            child: MasonryGridView.count(
              crossAxisSpacing: 3.0,
              mainAxisSpacing: 3.0,
              itemCount: widget.videoList.length,
              physics: ScrollPhysics(),
              itemBuilder: (context, index) {
                if (index % 4 != 0 || index == 0) {
                  return _VideoThumbnail(
                    statusFile: widget.videoList[index],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              PlayStatusVideo(widget.videoList[index])),
                    ),
                  );
                } else {
                  if (_anchoredBanner != null)
                    return AdWidget(ad: _anchoredBanner!);
                  else
                    return Container();
                }
              },
              crossAxisCount: 2,
            ),
          ),
        ),
      ),
    );
  }
}

class _VideoThumbnail extends StatefulWidget {
  final StatusFile statusFile;
  final VoidCallback onTap;

  _VideoThumbnail({required this.statusFile, required this.onTap});

  @override
  _VideoThumbnailState createState() => _VideoThumbnailState();
}

class _VideoThumbnailState extends State<_VideoThumbnail> {
  File? _thumbFile;

  @override
  void initState() {
    super.initState();
    _loadThumbnail();
  }

  Future<void> _loadThumbnail() async {
    final thumb = await SafDirectoryService.getThumbnailFile(
        widget.statusFile,
        width: 300,
        height: 300);
    if (mounted && thumb != null) {
      setState(() => _thumbFile = thumb);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: InkWell(
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xffb7d8cf),
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          child: _thumbFile != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.file(_thumbFile!, height: 155, fit: BoxFit.cover),
                      Icon(Icons.play_circle_outline,
                          size: 40, color: Colors.white),
                    ],
                  ),
                )
              : Container(
                  height: 155,
                  child: Center(
                    child: Image.asset("images/video_loader.gif"),
                  ),
                ),
        ),
      ),
    );
  }
}
