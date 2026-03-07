# 🏜️ Territory Run

> **Claim the world by running.** A GPS fitness game where players claim real-world territory by running outdoors.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore-FFCA28?logo=firebase)](https://firebase.google.com)
[![Google Maps](https://img.shields.io/badge/Google%20Maps-Integrated-4285F4?logo=googlemaps)](https://developers.google.com/maps)

---

## 🎮 What is Territory Run?

Territory Run turns your daily runs into a competitive game. Every path you run becomes **your territory** — visible on a real-time map. Other runners can challenge and claim your turf, making every run count.

### Key Features
- 🗺️ **Interactive Google Maps** — Full map with custom styling, territory overlays, and real-time markers
- 🏃 **Real-time Runner Tracking** — See nearby active runners on the map
- 🚩 **Territory Ownership** — Claim paths by running them, defend your turf
- 🔥 **Heatmap Overlay** — Visualize running activity hotspots
- 🏆 **Leaderboard** — Compete with runners in your area
- 📊 **Stats Dashboard** — Track your streaks, stamina, and progress
- 🌐 **Offline-First** — Run without internet, sync when you're back online
- 🔐 **Firebase Auth** — Email/password + Google Sign-In

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| **Framework** | Flutter (Dart) |
| **Auth** | Firebase Authentication |
| **Database** | Cloud Firestore |
| **Maps** | Google Maps Flutter |
| **State** | Provider |
| **Storage** | Hive (offline-first) |
| **GPS** | Geolocator |

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.x+)
- [Firebase Project](https://console.firebase.google.com)
- [Google Maps API Key](https://console.cloud.google.com)

### Setup

```bash
# 1. Clone the repository
git clone https://github.com/Kumailameen-cyber/territory-run-.git
cd territory-run-

# 2. Install dependencies
flutter pub get

# 3. Run the app
flutter run -d chrome    # Web
flutter run              # Mobile
```

### Firebase Configuration
1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Enable **Email/Password** and **Google Sign-In** authentication
3. Add your `firebase_options.dart` config file
4. Enable **Cloud Firestore** database

### Google Maps Setup
1. Enable **Maps JavaScript API** in [Google Cloud Console](https://console.cloud.google.com/apis/library/maps-backend.googleapis.com)
2. Add your API key to `web/index.html`

---

## 📁 Project Structure

```
lib/
├── core/
│   └── theme/          # App colors, typography, theme
├── models/             # Data models (User, Territory, Run)
├── providers/          # State management (Auth, Map, Run)
├── screens/
│   ├── auth/           # Login & Signup
│   ├── map/            # Main map dashboard
│   ├── running/        # Active run screen
│   ├── leaderboard/    # Rankings
│   └── profile/        # User profile
├── services/           # Firebase, GPS, Storage, Sync
├── widgets/            # Reusable UI components
├── app.dart            # App root with providers
└── main.dart           # Entry point
```

---

## 🗺️ Roadmap

- [x] Firebase Authentication (Email + Google)
- [x] Google Maps Integration
- [x] Real-time Runner Tracking
- [x] Territory Visualization
- [x] Interactive Search & Filter UI
- [ ] GPS Run Recording
- [ ] Territory Claiming Logic
- [ ] Leaderboard Backend
- [ ] Push Notifications
- [ ] Anti-Cheat System
- [ ] Profile & Stats Dashboard
- [ ] Dark Mode

---

## 🤝 Contributing

Contributions are welcome! Feel free to open issues or submit pull requests.

---

## 📄 License

This project is licensed under the MIT License.

---

<p align="center">
  Built with ❤️ and 🏃 by <a href="https://github.com/Kumailameen-cyber">Kumail Ameen</a>
</p>
