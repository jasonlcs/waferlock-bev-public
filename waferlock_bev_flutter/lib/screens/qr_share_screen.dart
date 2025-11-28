import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:no_screenshot/no_screenshot.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/api_credentials.dart';
import '../services/qr_encryption_service.dart';

class QRShareScreen extends StatefulWidget {
  final ApiCredentials credentials;

  const QRShareScreen({
    super.key,
    required this.credentials,
  });

  @override
  State<QRShareScreen> createState() => _QRShareScreenState();
}

class _QRShareScreenState extends State<QRShareScreen> {
  final _noScreenshot = NoScreenshot.instance;
  late String _encryptedData;
  Timer? _timer;
  int _remainingSeconds = 300;
  
  /// Returns true if screenshot protection is supported (iOS/Android only)
  bool get _isScreenshotProtectionSupported {
    if (kIsWeb) return false;
    return Platform.isIOS || Platform.isAndroid;
  }

  @override
  void initState() {
    super.initState();
    if (_isScreenshotProtectionSupported) {
      _noScreenshot.screenshotOff();
    }
    _generateQRData();
    _startTimer();
  }

  void _generateQRData() {
    setState(() {
      _encryptedData = QREncryptionService.encryptCredentials(
        projectID: widget.credentials.projectID,
        id: widget.credentials.id,
        password: widget.credentials.password,
      );
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _remainingSeconds = 300;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _generateQRData();
        _remainingSeconds = 300;
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    if (_isScreenshotProtectionSupported) {
      _noScreenshot.screenshotOn();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = (_remainingSeconds / 60).floor().toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).floor().toString().padLeft(2, '0');

    return Scaffold(
      appBar: AppBar(
        title: const Text('分享 QR 碼'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Card(
              child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.qr_code_2, size: 48, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(height: 16),
                      Text(
                        '掃描此 QR 碼快速登入',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: QrImageView(
                          data: _encryptedData,
                          version: QrVersions.auto,
                          size: 250,
                          eyeStyle: QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '更新倒數: $minutes:$seconds',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.orange.shade700),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'QR 碼具有時效性，會定時自動更新。請勿分享給未經授權的人員。',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('關閉'),
                      ),
                    ],
                  ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
