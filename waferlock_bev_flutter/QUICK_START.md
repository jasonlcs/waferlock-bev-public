# 🚀 快速開始指南

## 前置需求

### 安裝 Flutter

#### macOS
```bash
# 使用 Homebrew
brew install flutter

# 或下載官方安裝包
# https://docs.flutter.dev/get-started/install/macos
```

#### Windows
下載並安裝: https://docs.flutter.dev/get-started/install/windows

#### Linux
下載並安裝: https://docs.flutter.dev/get-started/install/linux

### 驗證安裝
```bash
flutter doctor
```

---

## 步驟 1: 安裝依賴

```bash
cd waferlock_bev_flutter
flutter pub get
```

---

## 步驟 2: 選擇執行平台

### 🌐 在 Web 瀏覽器執行 (最簡單)

```bash
flutter run -d chrome
```

或使用 Edge:
```bash
flutter run -d edge
```

---

### 📱 在 iOS 模擬器執行 (僅限 macOS)

1. 開啟 Xcode 並安裝 iOS Simulator
2. 啟動模擬器:
```bash
open -a Simulator
```

3. 執行應用:
```bash
flutter run -d ios
```

---

### 🤖 在 Android 模擬器執行

1. 安裝 Android Studio 和 Android SDK
2. 建立 AVD (Android Virtual Device)
3. 啟動模擬器
4. 執行應用:
```bash
flutter run -d android
```

---

### 💻 在桌面執行

#### macOS
```bash
flutter run -d macos
```

#### Windows
```bash
flutter run -d windows
```

#### Linux
```bash
flutter run -d linux
```

---

## 步驟 3: 使用應用程式

### 登入流程

1. 開啟應用後，會看到「開始分析」畫面
2. 填寫 API 憑證:
   - **Project ID**: WFLK_CTSP (預設值)
   - **ID**: 您的登入 ID
   - **Password**: 您的密碼
3. 選擇查詢月份
4. 點擊「取得資料」按鈕

### 查詢消費記錄

1. 登入成功後，資料會自動載入
2. 在搜尋框輸入使用者名稱或 ID
3. 或從下拉選單選擇使用者
4. 查看個人消費分析和圖表

---

## 常見問題

### Q1: Flutter Doctor 顯示錯誤
```bash
# 執行診斷
flutter doctor -v

# 根據提示安裝缺少的工具
```

### Q2: 找不到可用裝置
```bash
# 查看可用裝置
flutter devices

# 如果是 Web，確認已啟用
flutter config --enable-web

# 如果是桌面，確認已啟用
flutter config --enable-macos-desktop
flutter config --enable-windows-desktop
flutter config --enable-linux-desktop
```

### Q3: 建置錯誤
```bash
# 清理快取
flutter clean

# 重新取得依賴
flutter pub get

# 再次執行
flutter run
```

### Q4: API 連線失敗
- 確認網路連線正常
- 確認 API 伺服器 (https://liveamcore1.waferlock.com:10001) 可訪問
- 確認憑證正確

### Q5: CORS 錯誤 (僅 Web)
這是正常的，因為瀏覽器安全政策。解決方案:
1. 使用 Chrome 的開發模式 (已在 web/index.html 配置)
2. 或使用行動/桌面版本 (不受 CORS 限制)

---

## 開發模式熱重載

應用執行後，修改程式碼會自動熱重載:

```bash
# 在終端機按下:
r  - 熱重載
R  - 完全重啟
q  - 退出
```

---

## 建置生產版本

### Android APK
```bash
flutter build apk --release
# 輸出: build/app/outputs/flutter-apk/app-release.apk
```

### iOS IPA (需要 macOS + Xcode)
```bash
flutter build ios --release
# 需要在 Xcode 中簽名和匯出
```

### Web
```bash
flutter build web --release
# 輸出: build/web/
```

### macOS App
```bash
flutter build macos --release
# 輸出: build/macos/Build/Products/Release/
```

---

## 效能模式

### Debug 模式 (開發用)
```bash
flutter run
```

### Release 模式 (測試用)
```bash
flutter run --release
```

### Profile 模式 (效能分析)
```bash
flutter run --profile
```

---

## VS Code 使用者

1. 安裝 Flutter 擴充套件
2. 按 F5 開始除錯
3. 選擇目標裝置
4. 享受熱重載和除錯功能

---

## Android Studio 使用者

1. 開啟專案資料夾
2. 等待 Gradle 同步完成
3. 選擇目標裝置
4. 點擊執行按鈕 (▶️)

---

## 專案目錄說明

```
waferlock_bev_flutter/
├── lib/              # 主要程式碼
├── android/          # Android 平台設定
├── ios/              # iOS 平台設定
├── web/              # Web 平台設定
├── macos/            # macOS 平台設定
├── windows/          # Windows 平台設定
├── linux/            # Linux 平台設定
├── pubspec.yaml      # 依賴設定
└── README.md         # 專案說明
```

---

## 下一步

- 📖 閱讀 [README.md](README.md) 了解專案架構
- 📊 查看 [IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md) 了解實作細節
- 🔄 查看 [PROJECT_COMPARISON.md](PROJECT_COMPARISON.md) 了解與 React 版本的差異

---

## 需要幫助?

- Flutter 官方文件: https://docs.flutter.dev
- Flutter 中文網: https://flutter.cn
- Flutter Cookbook: https://docs.flutter.dev/cookbook

---

**祝您開發愉快! 🎉**
