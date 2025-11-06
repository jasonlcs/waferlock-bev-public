# Waferlock 販賣機消費分析系統 (Flutter)

## 專案總覽

此專案是使用 Flutter 框架開發的 Waferlock 自動販賣機消費分析系統。應用程式允許使用者透過 API 憑證登入，獲取特定月份的消費記錄，並以視覺化圖表和數據分析的形式呈現。

### 主要功能

-   **API 登入:** 使用專案 ID、使用者 ID 和密碼進行身分驗證。
-   **數據獲取:** 從後端 API 拉取指定月份的消費資料。
-   **數據分析:**
    -   計算總消費金額與次數。
    -   分析最熱門的飲品。
    -   統計最頻繁的消費時段。
    -   依使用者名稱或卡號搜尋個人消費記錄。
-   **視覺化圖表:**
    -   使用 `fl_chart` 套件繪製長條圖與圓餅圖。
-   **憑證管理:**
    -   使用 `shared_preferences` 在本機端安全地保存 API token 與登入憑證。
    -   透過 `qr_flutter` 產生 QR code 以分享登入憑證。
    -   使用 `mobile_scanner` 掃描 QR code 以快速登入。

### 核心技術

-   **框架:** Flutter
-   **狀態管理:** `provider`
-   **HTTP 客戶端:** `http`
-   **圖表:** `fl_chart`
-   **本地儲存:** `shared_preferences`
-   **QR Code:** `qr_flutter` (產生), `mobile_scanner` (掃描)
-   **加密:** `encrypt`

### 專案架構

-   **`main.dart`**: 應用程式的進入點，設定 `ChangeNotifierProvider` 以提供 `DataProvider`。
-   **`providers/data_provider.dart`**: 核心狀態管理類別，負責處理所有業務邏輯，包括 API 呼叫、數據處理、狀態更新與錯誤處理。
-   **`services/api_service.dart`**: 封裝所有與後端 API 的互動，包括登入、獲取資料，以及 token 和憑證的本地持久化。
-   **`screens/`**: 包含應用程式的主要畫面，如 `home_screen.dart`。
-   **`widgets/`**: 包含可重複使用的 UI 元件，如登入表單、使用者搜尋和結果顯示區塊。
-   **`models/`**: 定義應用程式中使用的資料模型，如 `ApiCredentials` 和 `ConsumptionRecord`。

## 建置與執行

### 1. 安裝依賴

在專案根目錄下執行：

```bash
flutter pub get
```

### 2. 執行應用程式

可根據目標平台選擇不同的指令：

-   **行動裝置 (iOS/Android):**
    ```bash
    flutter run
    ```
-   **網頁 (Chrome):**
    ```bash
    flutter run -d chrome
    ```
-   **桌面 (macOS):**
    ```bash
    flutter run -d macos
    ```

## 開發慣例

-   **狀態管理:** 統一使用 `provider` 套件進行狀態管理，主要邏輯集中在 `DataProvider`。
-   **API 隔離:** 所有網路請求都應透過 `ApiService` 進行，保持 UI 層的純淨。
-   **響應式設計:** UI 元件應考慮不同螢幕尺寸的適應性。
-   **錯誤處理:** `DataProvider` 中對 API 呼叫進行了 `try-catch` 處理，並將錯誤訊息顯示在 UI 上。
-   **程式碼風格:** 遵循 `flutter_lints` 提供的規則，確保程式碼品質與一致性。
