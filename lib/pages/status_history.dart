import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import 'package:numstatus/utils/status_history.dart';
import 'package:numstatus/pages/view_photo.dart';
import 'package:numstatus/pages/video_play.dart';

class StatusHistoryScreen extends StatefulWidget {
  @override
  _StatusHistoryScreenState createState() => _StatusHistoryScreenState();
}

class _StatusHistoryScreenState extends State<StatusHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Status History'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline),
            tooltip: 'Clear History',
            onPressed: () => _showClearDialog(),
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => setState(() {}),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.photo), text: 'Photos'),
            Tab(icon: Icon(Icons.videocam), text: 'Videos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _HistoryPhotosTab(),
          _HistoryVideosTab(),
        ],
      ),
    );
  }

  void _showClearDialog() async {
    final cacheSize = await StatusHistory.getCacheSizeBytes();
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear History'),
        content: Text(
            'Cache size: ${StatusHistory.formatBytes(cacheSize)}\n\nThis will delete all cached statuses.'),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text('Clear All'),
            onPressed: () async {
              await StatusHistory.clearCache();
              Navigator.pop(context);
              setState(() {});
            },
          ),
          TextButton(
            child: Text('Clear 30+ days'),
            onPressed: () async {
              await StatusHistory.clearOlderThan(30);
              Navigator.pop(context);
              setState(() {});
            },
          ),
        ],
      ),
    );
  }
}

class _HistoryPhotosTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: StatusHistory.getHistoryImages(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Center(child: CircularProgressIndicator());
        }
        final images = snapshot.data ?? [];
        if (images.isEmpty) {
          return Center(
            child: Text('No saved statuses yet.\nView statuses to cache them automatically.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16)),
          );
        }
        return MasonryGridView.count(
          padding: const EdgeInsets.all(8.0),
          crossAxisCount: 2,
          itemCount: images.length,
          mainAxisSpacing: 8.0,
          crossAxisSpacing: 8.0,
          itemBuilder: (context, index) {
            return Material(
              elevation: 8.0,
              borderRadius: BorderRadius.all(Radius.circular(8)),
              child: InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ViewPhotos(images[index])),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(File(images[index]), fit: BoxFit.cover),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _HistoryVideosTab extends StatelessWidget {
  Future<String?> _getThumbnail(String videoPath) async {
    return await VideoThumbnail.thumbnailFile(
      video: videoPath,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.WEBP,
      maxWidth: 155,
      quality: 50,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: StatusHistory.getHistoryVideos(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Center(child: CircularProgressIndicator());
        }
        final videos = snapshot.data ?? [];
        if (videos.isEmpty) {
          return Center(
            child: Text('No saved video statuses yet.\nView statuses to cache them automatically.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16)),
          );
        }
        return MasonryGridView.count(
          padding: const EdgeInsets.all(8.0),
          crossAxisCount: 2,
          itemCount: videos.length,
          mainAxisSpacing: 8.0,
          crossAxisSpacing: 8.0,
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              child: InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PlayStatusVideo(videos[index])),
                ),
                child: FutureBuilder<String?>(
                  future: _getThumbnail(videos[index]),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.done &&
                        snap.hasData) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.file(File(snap.data!), height: 155),
                            Icon(Icons.play_circle_outline,
                                size: 40, color: Colors.white),
                          ],
                        ),
                      );
                    }
                    return Container(
                      height: 155,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
