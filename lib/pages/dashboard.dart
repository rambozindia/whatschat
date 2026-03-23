import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:numstatus/utils/constants.dart' show getBannerAdUnitId;
import 'package:numstatus/utils/status_directory_helper.dart';
import 'package:numstatus/utils/status_saver.dart';
import 'package:numstatus/utils/status_history.dart';
import 'package:numstatus/pages/photos.dart';
import 'package:numstatus/pages/videos.dart';
import 'package:numstatus/pages/status_history.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedApp = 'whatsapp';
  static final AdRequest request = AdRequest();

  BannerAd? _anchoredBanner;
  bool _loadingAnchoredBanner = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Cache statuses in background
    StatusHistory.cacheCurrentStatuses();
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

  @override
  void dispose() {
    _anchoredBanner?.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _bulkDownload() async {
    final isPhotos = _tabController.index == 0;

    final items = isPhotos
        ? getStatusImages(_selectedApp)
        : getStatusVideos(_selectedApp);

    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No ${isPhotos ? "photos" : "videos"} to download')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _BulkDownloadDialog(
        items: items,
        isPhotos: isPhotos,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_loadingAnchoredBanner) {
      _loadingAnchoredBanner = true;
      _createAnchoredBanner(context);
    }

    final availableApps = getAvailableApps();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDark ? Colors.grey[850] : Colors.deepOrange,
      child: DefaultTabController(
        length: 2,
        initialIndex: 0,
        child: Scaffold(
          backgroundColor: isDark ? Colors.grey[850] : Colors.deepOrange,
          appBar: AppBar(
            title: Text("Status Downloader"),
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
            elevation: 50.0,
            leading: IconButton(
              icon: Icon(Icons.download),
              tooltip: 'Menu Icon',
              onPressed: () {},
            ),
            systemOverlayStyle: SystemUiOverlayStyle.light,
            actions: [
              // Bulk download button
              IconButton(
                icon: Icon(Icons.download_for_offline),
                tooltip: 'Download All',
                onPressed: _bulkDownload,
              ),
              // History button
              IconButton(
                icon: Icon(Icons.history),
                tooltip: 'Status History',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => StatusHistoryScreen()),
                  );
                },
              ),
              // App selector dropdown
              if (availableApps.length > 1)
                PopupMenuButton<String>(
                  icon: Icon(Icons.swap_horiz),
                  tooltip: 'Switch App',
                  onSelected: (value) {
                    setState(() {
                      _selectedApp = value;
                    });
                  },
                  itemBuilder: (context) => availableApps
                      .map((app) => PopupMenuItem(
                            value: app,
                            child: Row(
                              children: [
                                if (app == _selectedApp)
                                  Icon(Icons.check, size: 18, color: Colors.deepOrange),
                                if (app != _selectedApp) SizedBox(width: 18),
                                SizedBox(width: 8),
                                Text(getAppLabel(app)),
                              ],
                            ),
                          ))
                      .toList(),
                ),
            ],
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
              Photos(appType: _selectedApp),
              VideoListView(appType: _selectedApp),
            ],
          ),
        ),
      ),
    );
  }
}

class _BulkDownloadDialog extends StatefulWidget {
  final List<String> items;
  final bool isPhotos;

  _BulkDownloadDialog({required this.items, required this.isPhotos});

  @override
  _BulkDownloadDialogState createState() => _BulkDownloadDialogState();
}

class _BulkDownloadDialogState extends State<_BulkDownloadDialog> {
  int _done = 0;
  bool _isComplete = false;

  @override
  void initState() {
    super.initState();
    _startDownload();
  }

  Future<void> _startDownload() async {
    if (widget.isPhotos) {
      await bulkSaveImages(widget.items, (done, total) {
        if (mounted) setState(() => _done = done);
      });
    } else {
      await bulkSaveVideos(widget.items, (done, total) {
        if (mounted) setState(() => _done = done);
      });
    }
    if (mounted) setState(() => _isComplete = true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!_isComplete) ...[
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Downloading $_done / ${widget.items.length}'),
          ] else ...[
            Icon(Icons.check_circle, color: Colors.green, size: 48),
            SizedBox(height: 16),
            Text('Downloaded $_done ${widget.isPhotos ? "photos" : "videos"}!',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ],
      ),
      actions: _isComplete
          ? [
              TextButton(
                child: Text('Close'),
                onPressed: () => Navigator.pop(context),
              )
            ]
          : null,
    );
  }
}
