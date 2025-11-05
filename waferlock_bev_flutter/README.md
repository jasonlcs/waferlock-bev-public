# Waferlock 販賣機消費分析系統 (Flutter 版本)

這是使用 Flutter 框架重新實作的 Waferlock 自動販賣機消費分析系統。

## 功能特色

- 🔐 API 憑證登入系統
- 📊 即時數據分析與視覺化
- 👥 使用者消費記錄查詢
- 📈 圖表展示（長條圖、圓餅圖）
- 🏆 熱門飲料與時段分析
- 📱 跨平台支援（iOS、Android、Web、Desktop）

## 系統需求

- Flutter SDK >= 3.9.2
- Dart SDK >= 3.9.2

## 安裝與執行

### 1. 安裝依賴套件

```bash
flutter pub get
```

### 2. 執行應用程式

#### 在手機/模擬器上執行
```bash
flutter run
```

#### 在網頁上執行
```bash
flutter run -d chrome
```

#### 在桌面上執行 (macOS)
```bash
flutter run -d macos
```

## 專案結構

```
lib/
├── main.dart                          # 應用程式進入點
├── models/                            # 資料模型
│   ├── consumption_record.dart        # 消費記錄模型
│   ├── api_credentials.dart           # API 憑證模型
│   └── user.dart                      # 使用者模型
├── services/                          # 服務層
│   └── api_service.dart               # API 服務
├── providers/                         # 狀態管理
│   └── data_provider.dart             # 資料提供者
├── screens/                           # 畫面
│   └── home_screen.dart               # 主畫面
└── widgets/                           # 元件
    ├── file_upload_widget.dart        # 檔案上傳/API 登入元件
    ├── user_search_widget.dart        # 使用者搜尋元件
    └── results_display_widget.dart    # 結果顯示元件
```

## 使用的套件

- **provider** - 狀態管理
- **http** - HTTP 請求
- **fl_chart** - 圖表視覺化
- **intl** - 國際化與日期格式化
- **shared_preferences** - 本地儲存

## API 配置

預設 API 端點: `https://liveamcore1.waferlock.com:10001`

### 登入端點
- URL: `/api/Auth/login`
- Method: POST
- Body: 
```json
{
  "projectID": "WFLK_CTSP",
  "id": "your_id",
  "password": "your_password"
}
```

### 資料查詢端點
- URL: `/api/EventVendingMaching/range`
- Method: POST
- Headers: `Authorization: Bearer {token}`
- Body:
```json
{
  "startDate": "2024-01-01",
  "endDate": "2024-01-31",
  "eventCount": 2000
}
```

## 建置生產版本

### Android APK
```bash
flutter build apk --release
```

### iOS IPA
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

### macOS App
```bash
flutter build macos --release
```

## 開發注意事項

- 使用 Provider 進行狀態管理
- 遵循 Flutter 命名規範
- 採用 Material Design 3 設計語言
- 所有 API 呼叫都經過錯誤處理
- 支援響應式設計

## 授權

本專案為 Waferlock 內部使用系統。

## 版本歷史

- **v1.0.0** - 初始版本
  - 實作基本 API 登入功能
  - 實作消費記錄查詢與展示
  - 實作資料視覺化圖表
  - 實作熱門分析功能
