# 憑證自動重新認證功能實現

## 概述
實現了用戶憑證持久化和自動重新認證機制，當API憑證過期時能夠自動使用保存的憑證進行重新登入。

## 主要功能

### 1. 憑證存儲
- **自動保存**：用戶手動登入或透過QR碼登入時，憑證自動保存至SharedPreferences
- **安全存儲**：已存儲的憑證用於後續自動重新認證
- **透明管理**：所有憑證管理邏輯由ApiService和DataProvider處理

### 2. 自動重新認證
**實現位置**：`lib/services/api_service.dart` - `fetchData()` 方法

流程：
1. 嘗試使用現有token進行資料請求
2. 若收到401/403錯誤（憑證過期），捕獲異常
3. 自動從SharedPreferences載入已保存的憑證
4. 清除過期token，重新登入獲取新token
5. 自動重試資料請求（現在使用新token）
6. 返回資料給用戶（無需用戶干預）

### 3. 用戶體驗改進
**實現位置**：`lib/providers/data_provider.dart` - `fetchData()` 方法

- 清晰的錯誤提示：區分「憑證過期自動重新登入」與其他錯誤
- 當憑證過期時，顯示：*「憑證已過期，已自動嘗試重新登入並重新獲取資料。若問題持續，請重新登入。」*

## 技術實現

### ApiService 修改

```dart
// fetchData() - 添加異常捕獲和自動重新認證
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
    // 憑證過期時自動重新認證
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

// _fetchConsumptionData() - 改進錯誤訊息
if (response.statusCode == 401 || response.statusCode == 403) {
  await _clearToken();
  throw Exception('憑證已過期: ${response.statusCode} ${response.reasonPhrase}');
}
```

### DataProvider 修改

```dart
// fetchData() - 改進錯誤處理
catch (e) {
  String errorMsg = e.toString();
  
  if (errorMsg.contains('憑證已過期')) {
    _error = '憑證已過期，已自動嘗試重新登入並重新獲取資料。若問題持續，請重新登入。';
  } else {
    _error = errorMsg;
  }
  // ... 其他錯誤處理
}
```

## 使用場景

### 場景 1：正常登入流程
1. 用戶輸入 ID, Password, Project ID
2. 系統登入並獲得token
3. **憑證自動保存**至SharedPreferences
4. 用戶選擇月份並獲取資料
5. 後續使用token進行資料請求

### 場景 2：憑證過期自動恢復
1. 用戶已登入，進行資料請求
2. API返回401/403（憑證已過期）
3. **系統自動偵測**過期狀態
4. **系統自動載入**已保存的憑證
5. **系統自動重新登入**獲取新token
6. **系統自動重試**資料請求
7. 用戶透明地獲得資料，無需手動干預

### 場景 3：用戶主動登出
1. 用戶點擊「重新登入」或「登出」按鈕
2. 清除token和緩存憑證
3. 返回登入表單

## 現有功能保留
- ✅ QR碼登入時的自動登入
- ✅ 手動登入表單
- ✅ 資料查詢功能
- ✅ 月份選擇器
- ✅ 搜尋和篩選功能
- ✅ 使用者登出

## 測試建議

1. **測試憑證保存**
   - 登入後檢查SharedPreferences中是否保存了憑證

2. **測試自動重新認證**（需要服務器配合）
   - 登入成功後，人為設置token過期
   - 再次請求資料，確認系統自動重新登入

3. **測試錯誤提示**
   - 在過期情況下查看錯誤訊息是否正確

4. **測試登出功能**
   - 確認登出後憑證和token都被清除

## 相關文件
- `lib/services/api_service.dart` - API服務邏輯
- `lib/providers/data_provider.dart` - 資料提供者邏輯
- `lib/models/api_credentials.dart` - 憑證模型
