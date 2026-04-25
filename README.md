# Urban FitLog 🏃‍♂️

> A Connected Environments fitness tracker built with Flutter for CASA0015 – Mobile Systems and Interactions, UCL.

Urban FitLog bridges **outdoor fitness** with **real-world environmental data**, helping urban runners make smarter decisions about when, where, and how to exercise based on live GPS tracking, air quality, and weather conditions.

---

## 🌍 Connected Environments Theme

Urban FitLog addresses the question:
**"How does the urban environment affect the quality and safety of outdoor exercise?"**

The app integrates real-time environmental sensing with physical activity tracking to give runners a complete picture of their workout context — not just *how far* they ran, but *what conditions* they ran in.

---

## ✨ Key Features

### 🏋️ Strength Training (`力量训练`)
- Log exercises, sets, weight, and reps from a bilingual exercise database (50+ exercises)
- Rest timer with animated clock face
- Workout templates for reuse
- Calorie burn calculation using Mifflin-St Jeor BMR formula
- YouTube tutorial integration for each exercise

### 🏃 Aerobic Running (`有氧跑步`)
- **Real-time GPS tracking** with live route map (OpenStreetMap via CARTO tiles)
- **Air Quality Index (AQI)** fetched from AQICN API — shown before and during runs
- **Weather data** (temperature, humidity, wind) from OpenWeatherMap API
- **Run readiness assessment** based on AQI level
- **Accelerometer-based cadence** (steps per minute) via sensors_plus
- **Pedometer step counting** via pedometer package
- Distance, pace, duration, calories burned tracked in real time
- Run history saved locally with route snapshot

### 📅 Calendar (`日历`)
- Monthly calendar view with training volume and run distance badges per day
- Tap any day to view full strength training log and run sessions
- Monthly statistics (total sets, volume, run distance, rest days)

### ⚙️ Settings (`设置`)
- Body data (height, weight, age, gender) for accurate calorie calculations
- OpenWeatherMap and AQICN API key management
- Language toggle (中文 / English)
- Light / Dark theme toggle with system persistence

---

## 📡 Onboard Sensors Used

| Sensor | Package | Data Collected |
|--------|---------|----------------|
| GPS | `geolocator` | Real-time position, route tracking, distance |
| Accelerometer | `sensors_plus` | Movement magnitude → cadence (steps/min) |
| Pedometer | `pedometer` | Cumulative step count |

---

## ☁️ External Cloud APIs

| API | Provider | Data |
|-----|----------|------|
| Weather | [OpenWeatherMap](https://openweathermap.org/api) | Temperature, humidity, wind speed, description |
| Air Quality | [AQICN](https://aqicn.org/api/) | Real-time AQI index + category |
| Map Tiles | [CARTO](https://carto.com/) via flutter_map | OpenStreetMap base tiles |

API keys are stored in `SharedPreferences` and configurable in-app via Settings.

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.x (Dart) |
| Map | flutter_map 7.x + latlong2 |
| HTTP | http package |
| Storage | shared_preferences |
| Sensors | geolocator, sensors_plus, pedometer |
| Platform | iOS (primary), Android compatible |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK ≥ 3.10
- Xcode (for iOS) or Android Studio (for Android)
- OpenWeatherMap API key (free at openweathermap.org)
- AQICN token (free at aqicn.org/data-platform/token/)

### Run the App

```bash
git clone https://github.com/EthanHXY/flutter_application_1.git
cd flutter_application_1
flutter pub get
flutter run --release
```

### Configure API Keys
Open the app → Settings → API 设置
Enter your OpenWeatherMap Key and AQICN Token.

---

## 📁 Project Structure

```
lib/
└── main.dart              # Single-file architecture (~5100 lines)
    ├── S (class)          # Bilingual string management (zh/en)
    ├── MyApp              # MaterialApp with light/dark ThemeData
    ├── SplashScreen       # Animated 2s launch screen
    ├── TrainingPage       # Strength training UI + logic
    ├── AerobicPage        # GPS running + environment sensing
    ├── CalendarPage       # Monthly history calendar
    ├── SettingsPage       # BMR, API keys, language, theme
    └── Data models        # WorkoutExercise, RunSession, RunEnvironmentData
```

---

## 🎯 Key Design Decisions

- **`_runActive` flag pattern** — prevents iOS main thread freeze by never cancelling native sensor streams (GPS, accelerometer, pedometer) in button handlers; only `dispose()` calls `.cancel()`
- **`IndexedStack` for running view** — keeps `FlutterMap` alive across idle/running state transitions, avoiding NSURLSession tile-cancellation freeze on iOS
- **`getCurrentPosition()` + `distanceFilter: 0`** — captures GPS position immediately on run start without waiting for movement
- **Calorie formula** — MET × body weight (kg) × duration (hours); MET = 8.0 for running, 3.5 for strength training

---

## 📸 Screenshots & Demo

See [`/docs/screenshots/`](docs/screenshots/) for app screenshots.

Demo video: *(add link here after recording)*

---

## 🌐 Landing Page

[View the Urban FitLog landing page](https://EthanHXY.github.io/flutter_application_1)

---

## 👤 Author

**Ethan Han** — MSc Connected Environments, UCL CASA
Module: CASA0015 – Mobile Systems and Interactions
GitHub: [@EthanHXY](https://github.com/EthanHXY)
