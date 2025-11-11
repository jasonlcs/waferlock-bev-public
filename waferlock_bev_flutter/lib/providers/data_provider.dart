import 'package:flutter/foundation.dart';
import '../models/consumption_record.dart';
import '../models/api_credentials.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class DataProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<ConsumptionRecord> _records = [];
  String _searchQuery = '';
  String? _error;
  String? _fileName;
  bool _isLoading = false;
  String _loadingMessage = '資料讀取中，請稍候...';
  ApiCredentials? _cachedCredentials;
  bool _initialized = false;
  
  List<ConsumptionRecord> get records => _records;
  String get searchQuery => _searchQuery;
  String? get error => _error;
  String? get fileName => _fileName;
  bool get isLoading => _isLoading;
  String get loadingMessage => _loadingMessage;
  bool get hasActiveToken => _apiService.authToken != null;
  ApiCredentials? get cachedCredentials => _cachedCredentials;
  
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    
    await _apiService.loadToken();
    _cachedCredentials = await _apiService.loadCredentials();
    notifyListeners();
    
    // Auto-login if credentials were loaded and it's from QR login
    if (_cachedCredentials != null && _cachedCredentials!.loginMethod == 'qr') {
      await Future.delayed(const Duration(milliseconds: 500));
      final now = DateTime.now();
      final currentMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';
      await fetchData(_cachedCredentials!, currentMonth);
    }
  }
  
  List<ConsumptionRecord> get filteredRecords {
    if (_searchQuery.isEmpty) return _records;
    final lowercasedQuery = _searchQuery.toLowerCase();
    return _records
        .where((record) =>
            record.userId.toLowerCase().contains(lowercasedQuery) ||
            record.userName.toLowerCase().contains(lowercasedQuery))
        .toList();
  }
  
  List<User> get allUsers {
    final userNames = <String>{};
    for (var record in _records) {
      if (record.userName.isNotEmpty) {
        userNames.add(record.userName);
      }
    }
    return userNames.map((name) => User(userId: name, userName: name)).toList()
      ..sort((a, b) => a.userName.compareTo(b.userName));
  }
  
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
  
  Future<void> fetchData(ApiCredentials credentials, String month) async {
    _isLoading = true;
    _error = null;
    _loadingMessage = hasActiveToken ? '沿用既有登入授權取得資料...' : '正在登入...';
    notifyListeners();
    
    try {
      final effectiveCredentials = hasActiveToken && _cachedCredentials != null 
          ? _cachedCredentials! 
          : credentials;
      
      final records = await _apiService.fetchData(
        credentials: effectiveCredentials,
        month: month,
        existingToken: _apiService.authToken,
      );
      
      if (records.isEmpty) {
        _error = '在指定月份內找不到任何消費記錄。';
      }
      
      _records = records;
      _fileName = '伺服器資料 ($month)';
      _searchQuery = '';
      _cachedCredentials = effectiveCredentials;
    } catch (e) {
      String errorMsg = e.toString();
      
      if (errorMsg.contains('憑證已過期')) {
        _error = '憑證已過期，已自動嘗試重新登入並重新獲取資料。若問題持續，請重新登入。';
      } else {
        _error = errorMsg;
      }
      
      _records = [];
      _fileName = null;
      if (errorMsg.contains('401') || errorMsg.contains('403')) {
        await _apiService.clearAuth();
        _cachedCredentials = null;
      }
    } finally {
      _isLoading = false;
      _loadingMessage = '資料讀取中，請稍候...';
      notifyListeners();
    }
  }
  
  void reset() {
    _records = [];
    _fileName = null;
    _error = null;
    _searchQuery = '';
    notifyListeners();
  }
  
  Future<void> logout() async {
    await _apiService.clearAuth();
    _cachedCredentials = null;
    _records = [];
    _fileName = null;
    _error = null;
    _searchQuery = '';
    notifyListeners();
  }
}
