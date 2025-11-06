import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;

class QREncryptionService {
  static const String _fixedCode = 'ry3uojAvnp';

  static String _getEncryptionKey() {
    final DateTime now = DateTime.now();
    final String dateString = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final String keyString = _fixedCode + dateString;
    return keyString.padRight(32, '0').substring(0, 32);
  }

  static String encryptCredentials({
    required String projectID,
    required String id,
    required String password,
  }) {
    final String plaintext = '$projectID|$id|$password|${DateTime.now().millisecondsSinceEpoch}';
    final String keyString = _getEncryptionKey();
    
    final key = encrypt.Key.fromUtf8(keyString);
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    final encrypted = encrypter.encrypt(plaintext, iv: iv);
    final ivHex = iv.base64;
    final encryptedHex = encrypted.base64;
    
    return '$ivHex:$encryptedHex';
  }

  static Map<String, dynamic>? decryptCredentials(String encryptedData) {
    try {
      final parts = encryptedData.split(':');
      if (parts.length != 2) return null;

      final ivBase64 = parts[0];
      final encryptedBase64 = parts[1];

      final String keyString = _getEncryptionKey();
      final key = encrypt.Key.fromUtf8(keyString);
      final iv = encrypt.IV.fromBase64(ivBase64);
      final encrypter = encrypt.Encrypter(encrypt.AES(key));

      final decrypted = encrypter.decrypt64(encryptedBase64, iv: iv);
      final credentials = decrypted.split('|');

      if (credentials.length != 4) return null;

      return {
        'projectID': credentials[0],
        'id': credentials[1],
        'password': credentials[2],
        'timestamp': int.tryParse(credentials[3]) ?? 0,
      };
    } catch (e) {
      return null;
    }
  }
}
