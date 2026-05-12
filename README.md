# 📖 Quran App

A feature-rich Al-Quran & Islamic companion app built with Flutter. Designed with a modern dark UI, it provides a seamless experience for reading the Quran, tracking prayer times, and performing daily adhkar.

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| 📖 **Al-Quran** | Browse all 114 surahs, read by ayah with Arabic text, transliteration, and translation |
| 🔊 **Audio Recitation** | Stream ayah audio with playback controls |
| 🕌 **Prayer Times** | Auto-detect location and display accurate daily prayer schedules |
| 🧭 **Qibla Direction** | Compass-based qibla finder |
| 🔔 **Prayer Notifications** | Local notifications for each prayer time |
| 📿 **Dzikir** | Complete morning (*Pagi*) and evening (*Petang*) adhkar with Arabic, transliteration, translation, and hadith source |
| 🔍 **Search** | Search surahs by name or keyword |
| 📌 **Last Read** | Bookmarks the last read ayah for quick access |
| ⚙️ **Settings** | Theme and preference configuration |

---

## 🛠 Tech Stack

- **Framework:** Flutter (Dart)
- **State Management:** flutter_bloc
- **Dependency Injection:** get_it
- **Local Storage:** Hive
- **Networking:** Dio
- **Audio:** just_audio
- **Location:** geolocator, geocoding
- **Notifications:** flutter_local_notifications + timezone
- **Compass:** flutter_compass
- **Fonts:** Google Fonts, Scheherazade New, Lateef (Arabic)

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK `^3.10.4`
- Android device or emulator (iOS not configured)

### Setup

```bash
# Clone the repository
git clone https://github.com/royhandf/quran-app.git
cd quran-app

# Install dependencies
flutter pub get

# Create .env file
cp .env.example .env
# Fill in your API keys inside .env

# Run the app
flutter run
```

### Environment Variables

Create a `.env` file in the project root:

```env
QURAN_API_BASE_URL=https://your-api-url.com
PRAYER_API_BASE_URL=https://your-prayer-api.com
```

---

## 📁 Project Structure

```
lib/
├── app/                    # App-level config (theme, router)
├── core/
│   └── services/           # DzikirService, PrayerService, etc.
├── data/
│   └── models/             # Data models (Surah, Ayah, Dzikir, etc.)
└── presentation/
    └── screens/
        ├── home/           # Main navigation shell
        ├── quran/          # Quran reader screens
        ├── prayer/         # Prayer times screen
        ├── dzikir/         # Morning & evening adhkar
        ├── search/         # Search screen
        ├── last_read/      # Last read bookmark
        └── settings/       # App settings

assets/
├── data/
│   ├── dzikir_pagi.json    # 23 morning adhkar entries
│   └── dzikir_petang.json  # 24 evening adhkar entries
├── fonts/                  # ScheherazadeNew, Lateef (Arabic)
└── icon/                   # App launcher icon
```

---

## 📜 Adhkar Data

Both `dzikir_pagi.json` and `dzikir_petang.json` follow this schema:

```json
{
  "id": 1,
  "arabic": "...",
  "transliteration": "...",
  "translation": "...",
  "source": "HR. Muslim no. 2692",
  "count": 3
}
```

Sources are referenced from **Hisnul Muslim** and authenticated hadith collections (Bukhari, Muslim, Abu Daud, Tirmidzi, etc.).

---

## 📄 License

© 2025 royhandf. All Rights Reserved.

This application is proprietary software. The source code is made available for reference purposes only. Redistribution, modification, or commercial use of the source code without explicit written permission from the author is not permitted.
