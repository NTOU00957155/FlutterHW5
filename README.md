---

☁️ InfoHub App
Flutter開發的資訊集成應用程式。組合天氣預報、電影信息和 Firebase 認證功能。

---

✨ 功能簡介
用戶登入 / 註冊
Firebase Email/Password
Google Sign-In
天氣 API
根據城市名查詢溫度與體感溫度
TMDB 電影 API
顯示最新的電影
搜尋功能 + 詳情頁

---

📦 安裝
確保已安裝 Flutter SDK
先清除 pubspec.lock (若有)

flutter pub get
flutter run

---

🏠 Firebase 設定
前往 Firebase Console 新增頁面
啟用 Authentication
加入 Email/Password 和 Google Sign-In 支援
下載 google-services.json (若為 Android) 置於 android/app/
確保 AndroidManifest 或 build.gradle 配置正確

---

🌬️ API 設定
天氣 API
API Key: 自 OpenWeather 註冊獲取
置於 main.dart 中 fetchWeather

const apiKey = 'YOUR_OPENWEATHER_API_KEY';
電影 API (TMDB)
API Key: 自 TMDB 註冊獲取
置於 main.dart 中 fetchMovies

const tmdbApiKey = 'YOUR_TMDB_API_KEY';

---

☑️ 本頁含有
Flutter (Material UI)
Firebase Auth
RESTful APIs (Weather & Movies)

---

🚀 未來計畫
保存喜好的電影到 Firebase Firestore
地點簽章功能
最近查詢紀錄
