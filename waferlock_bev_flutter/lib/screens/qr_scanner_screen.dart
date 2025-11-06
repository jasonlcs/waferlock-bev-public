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
            const SnackBar(
              content: Text('QR 碼無效'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.red,
            ),
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
            const SnackBar(
              content: Text('QR 碼已過期，請重新產生'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.red,
            ),
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
          SnackBar(
            content: Text('解碼失敗: $e'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
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
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
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
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.orange.shade600,
                width: 3,
              ),
              borderRadius: BorderRadius.circular(12),
              shape: BoxShape.rectangle,
              color: Colors.transparent,
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.shade600.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            margin: const EdgeInsets.fromLTRB(40, 80, 40, 80),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                _isProcessing ? '處理中...' : '對準 QR 碼掃描',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.7),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
