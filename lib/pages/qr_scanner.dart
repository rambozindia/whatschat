import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerScreen extends StatefulWidget {
  @override
  _QrScannerScreenState createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  bool _hasScanned = false;

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    final value = barcode.rawValue!;
    final phone = _extractPhoneNumber(value);

    if (phone != null) {
      _hasScanned = true;
      Navigator.pop(context, phone);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No phone number found in QR code')),
      );
    }
  }

  String? _extractPhoneNumber(String value) {
    // Check for wa.me links
    final waRegex = RegExp(r'wa\.me/(\+?\d+)');
    final waMatch = waRegex.firstMatch(value);
    if (waMatch != null) return waMatch.group(1);

    // Check for api.whatsapp.com links
    final apiRegex = RegExp(r'phone=(\+?\d+)');
    final apiMatch = apiRegex.firstMatch(value);
    if (apiMatch != null) return apiMatch.group(1);

    // Check for plain phone number
    final cleaned = value.replaceAll(RegExp(r'[\s\-()]'), '');
    final phoneRegex = RegExp(r'^\+?\d{7,15}$');
    if (phoneRegex.hasMatch(cleaned)) return cleaned;

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan QR Code'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: _onDetect,
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Point camera at a QR code with a phone number',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  shadows: [Shadow(blurRadius: 8, color: Colors.black)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
