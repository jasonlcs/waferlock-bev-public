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
  late MobileScannerController controller;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController();
  }

  @override
  void dispose() {
    controller.dispose();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('掃描 QR 碼'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
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
              child: Stack(
                children: [
                    // Corner markers could go here but simple border is fine
                ],
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
