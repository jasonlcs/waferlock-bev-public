import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/api_credentials.dart';
import '../models/consumption_record.dart';

class ApiService {
  static const String defaultApiBase = 'https://liveamcore1.waferlock.com:10001';
  static const String apiBaseUrl = defaultApiBase;
  static const String _tokenKey = 'auth_token';
  static const String _credentialsKey = 'cached_credentials';
  
  String? _authToken;
  
  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString(_tokenKey);
  }
  
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    _authToken = token;
  }
  
  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    _authToken = null;
  }
  
  Future<void> saveCredentials(ApiCredentials credentials) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_credentialsKey, jsonEncode(credentials.toJson()));
  }
  
  Future<ApiCredentials?> loadCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final credentialsJson = prefs.getString(_credentialsKey);
    if (credentialsJson != null) {
      try {
        return ApiCredentials.fromJson(jsonDecode(credentialsJson));
      } catch (e) {
        return null;
      }
    }
    return null;
  }
  
  Future<void> clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_credentialsKey);
  }
  
  Future<List<ConsumptionRecord>> fetchData({
    required ApiCredentials credentials,
    required String month,
    String? existingToken,
  }) async {
    _authToken ??= existingToken;
    
    _authToken ??= await _login(credentials);
    
    try {
      return await _fetchConsumptionData(month);
    } catch (e) {
      // If token expired (401/403), attempt to re-authenticate with saved credentials
      if ((e.toString().contains('401') || e.toString().contains('403'))) {
        final savedCredentials = await loadCredentials();
        if (savedCredentials != null) {
          await _clearToken();
          _authToken = await _login(savedCredentials);
          return await _fetchConsumptionData(month);
        }
      }
      rethrow;
    }
  }
  
  Future<String> _login(ApiCredentials credentials) async {
    final loginUrl = '$apiBaseUrl/api/Auth/login';
    
    final response = await http.post(
      Uri.parse(loginUrl),
      headers: {
        'Content-Type': 'application/json-patch+json',
        'accept': 'text/plain',
      },
      body: jsonEncode(credentials.toJson()),
    );
    
    if (response.statusCode != 200) {
      throw Exception('登入失敗: ${response.statusCode} ${response.reasonPhrase}\n${response.body}');
    }
    
    String token = response.body.trim();
    
    try {
      final parsed = jsonDecode(token);
      if (parsed is Map) {
        token = parsed['token'] ?? 
                parsed['Token'] ?? 
                parsed['accessToken'] ?? 
                parsed['access_token'] ?? 
                parsed['data'] ?? 
                token;
      } else if (parsed is String) {
        token = parsed;
      }
    } catch (_) {
      // Keep original token
    }
    
    token = token.replaceAll(RegExp(r'^"+|"+$'), '');
    
    if (token.isEmpty) {
      throw Exception('登入服務未回傳授權資訊，請檢查憑證是否正確。');
    }
    
    await _saveToken(token);
    await saveCredentials(credentials);
    
    return token;
  }
  
  Future<List<ConsumptionRecord>> _fetchConsumptionData(String month) async {
    final dataUrl = '$apiBaseUrl/api/EventVendingMaching/range';
    
    final year = int.parse(month.substring(0, 4));
    final monthNum = int.parse(month.substring(5, 7));
    
    final startDate = DateTime(year, monthNum, 1);
    final endDate = DateTime(year, monthNum + 1, 0);
    
    final requestBody = {
      'startDate': startDate.toIso8601String().split('T')[0],
      'endDate': endDate.toIso8601String().split('T')[0],
      'eventCount': 2000,
    };
    
    final response = await http.post(
      Uri.parse(dataUrl),
      headers: {
        'Content-Type': 'application/json-patch+json',
        'accept': 'text/plain',
        'Authorization': 'Bearer $_authToken',
      },
      body: jsonEncode(requestBody),
    );
    
    if (response.statusCode != 200) {
      if (response.statusCode == 401 || response.statusCode == 403) {
        await _clearToken();
        throw Exception('憑證已過期: ${response.statusCode} ${response.reasonPhrase}');
      }
      throw Exception('取得資料失敗: ${response.statusCode} ${response.reasonPhrase}\n${response.body}');
    }
    
    final List<dynamic> apiData = jsonDecode(response.body);
    
    final records = apiData
        .map((json) {
          try {
            final record = ConsumptionRecord.fromJson(json);
            
            if (record.price <= 0) return null;
            
            final channelValue = json['channel'];
            if (channelValue != null && channelValue == 0) {
              return null;
            }
            
            return record;
          } catch (e) {
            // Skipping invalid record: $e
            return null;
          }
        })
        .whereType<ConsumptionRecord>()
        .toList();
    
    return records;
  }
  
  String? get authToken => _authToken;
  
  Future<void> clearAuth() async {
    await _clearToken();
    await clearCredentials();
  }
}
