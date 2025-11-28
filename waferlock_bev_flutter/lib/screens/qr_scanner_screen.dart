import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../models/api_credentials.dart';
import '../providers/data_provider.dart';
import '../services/qr_encryption_service.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController? controller;
  bool _isProcessing = false;
  
  /// Returns true if QR scanning is supported on this platform (iOS/Android only)
  bool get _isScannerSupported {
    if (kIsWeb) return false;
    return Platform.isIOS || Platform.isAndroid;
  }

  @override
  void initState() {
    super.initState();
    if (_isScannerSupported) {
      controller = MobileScannerController();
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _handleQRCode(String data) async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      final decryptedData = QREncryptionService.decryptCredentials(data);
      
      if (decryptedData == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('QR 碼無效'), backgroundColor: Colors.red),
          );
        }
        _isProcessing = false;
        return;
      }

      final timestamp = decryptedData['timestamp'] as int;
      final now = DateTime.now().millisecondsSinceEpoch;
      const fiveMinutesInMillis = 5 * 60 * 1000;

      if (now - timestamp > fiveMinutesInMillis) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('QR 碼已過期，請重新產生'), backgroundColor: Colors.red),
          );
        }
        _isProcessing = false;
        return;
      }

      final apiCredentials = ApiCredentials(
        projectID: decryptedData['projectID']! as String,
        id: decryptedData['id']! as String,
        password: decryptedData['password']! as String,
        loginMethod: 'qr',
      );

      if (mounted) {
        final dataProvider = context.read<DataProvider>();
        final now = DateTime.now();
        final currentMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';
        
        Navigator.pop(context);
        await dataProvider.fetchData(apiCredentials, currentMonth);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('解碼失敗: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      _isProcessing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show unsupported message on non-mobile platforms
    if (!_isScannerSupported) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('掃描 QR 碼'),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.qr_code_scanner,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 24),
                Text(
                  'QR 碼掃描功能僅支援 iOS 和 Android 平台',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  '請使用手機或平板開啟此應用程式進行掃描',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('返回'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('掃描 QR 碼'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller!,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  _handleQRCode(barcode.rawValue!);
                  break;
                }
              }
            },
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  _isProcessing ? '處理中...' : '將 QR 碼置於框內',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
