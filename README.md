# 💪 Duolingo-Style Fitness App

A gamified fitness tracking mobile application inspired by Duolingo’s reward-based model. Built using **Flutter**, integrated with **Firebase** for backend services and **RapidAPI** for real-time exercise data and animations. Users can sign in, complete exercises of varying difficulty, earn points, and track their progress.

---

## 🚀 Features

- 🔐 **Firebase Authentication** (Google Sign-In)
- 🧠 **Gamification Model** (Beginner, Intermediate, Advanced workout tiers with points)
- 📈 **Progress Tracking** using sleek charts
- 🎯 **Targeted Workouts** with GIF previews powered by RapidAPI
- 🎉 **Reward System** (Points, Confetti animations, Motivational feedback)
- 📊 **Data Storage** with Firebase Firestore and Realtime Database
- 📸 **Image Upload** for exercise personalization
- 🌐 **Responsive UI** with custom animations (Lottie, Confetti, Haptic Feedback)

---

## 🛠️ Tech Stack

| Technology     | Description                         |
|----------------|-------------------------------------|
| Flutter        | Frontend mobile app framework       |
| Firebase       | Auth, Firestore, Realtime DB        |
| RapidAPI       | Exercise data (name, target muscle, GIFs) |
| Provider / Services | State and logic management         |
| Haptic Feedback| Immersive user interaction          |
| fl_chart       | Progress visualization              |

---

## 📦 Dependencies (from `pubspec.yaml`)

```yaml
firebase_core, firebase_auth, cloud_firestore, firebase_database
google_sign_in, fluttertoast, flutter_haptic_feedback
cached_network_image, lottie, intl, fl_chart
image_picker, sleek_circular_slider, shared_preferences
confetti, google_fonts, cupertino_icons, http
```

---

## 🔧 Getting Started

### Prerequisites

- Flutter SDK (>= 3.7.0)
- Firebase project with configured `google-services.json` / `firebase_options.dart`
- RapidAPI key (for exercise data)

### Installation

```bash
git clone https://github.com/your-username/exercise_app.git
cd exercise_app
flutter pub get
flutter run
```

### Firebase Setup

1. Add your `firebase_options.dart` (already scaffolded in `/controller/firebaseServices`)
2. Enable **Email/Password** and **Google** sign-in methods in Firebase console
3. Set up Firestore and Realtime DB with basic security rules

---

## 📁 Folder Structure (Highlights)

```
lib/
├── boundary/                # UI screens (login, dashboard, exercise screen, etc.)
├── controller/             # Firebase services, API calls, logic
│   ├── firebaseServices/
│   └── exerciseServices/
├── model/                  # Data models (e.g. Exercise)
├── main.dart               # App entry point
assets/
└── google.png              # Google Sign-In icon
```

---

## 🎯 Point System Logic

Each exercise tier awards:
- 🟢 Beginner: +50 points
- 🟡 Intermediate: +100 points
- 🔴 Advanced: +150 points

Displayed in an overlay in the dashboard.

---

## 📸 Screenshots (Add these later)
<!--
- Login Page
- Exercise Selection
- Progress Chart
- Confetti Reward Popup
-->

---

## 📬 Feedback & Contributions

Have ideas or bugs to report? Open an [issue](https://github.com/JoelTQX/exercise_app/issues) or start a [discussion](https://github.com/JoelTQX/exercise_app/discussions).

---

## 📜 License

This project is licensed under the NTU License.
