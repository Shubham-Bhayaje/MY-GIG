<div align="center">

# 🗺️ MY-GIG — HyperLocal Gig Map

### A Map-Based Micro-Job Marketplace

[![Flutter](https://img.shields.io/badge/Flutter-3.10+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.10+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Firestore%20%7C%20Auth-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-blue)]()

> **Discover and post hyperlocal gigs on an interactive map.** MY-GIG connects workers and job posters in real-time within a sleek, premium dark-mode interface powered by OpenStreetMap and Firebase.

---

</div>

## 📸 Screenshots

| Onboarding | Map View (Worker) | Job Detail | Profile |
|:---:|:---:|:---:|:---:|
| *Animated onboarding flow* | *Live map with price-pill markers* | *Detailed job info & accept* | *Wallet, ratings & skills* |

---

## ✨ Features

### 🔐 Authentication
- **Email & Password** sign-up / sign-in with Firebase Auth
- **Phone OTP** verification with auto-retrieval (Android)
- **Password Reset** via email
- **Persistent Sessions** — auto-login with `AuthGate` on app restart

### 🗺️ Interactive Map
- **OpenStreetMap** integration via `flutter_map` (no API key required)
- **Real-time gig markers** with price-pill overlays on the map
- **Radius filtering** — 1 km, 5 km, 10 km, or All India
- **Category-colored markers** for instant visual identification
- **Toggle** between Map View and List View

### 📝 Job Management
- **Post a Gig** — title, description, pay rate, duration, category, location, and tags
- **12 Job Categories** — Teaching, Labour, Delivery, Cleaning, Tech, Babysitting, Electrical, Plumbing, Cooking, Driving, Gardening, Other
- **Job Statuses** — Posted → Accepted → In Progress → Completed / Cancelled
- **Accept / Release** gigs with smart conflict detection (time overlap & max active gig limits)
- **Job Detail Screen** with poster info, distance, ratings, and one-tap accept

### 👤 Dual Role System
- **Worker Mode** — browse, filter, and accept nearby gigs
- **Poster Mode** — create gigs, track posted jobs, view analytics
- Seamless **role toggle** from the navigation bar

### 💰 Wallet & Transactions
- **In-app wallet** with real-time balance tracking
- **Atomic Firestore transactions** for job completion payouts and withdrawals
- **Payment notifications** on every credit/debit

### ⭐ Ratings & Verification
- **Rolling average** rating system with review count
- **Auto-verification** badge after 3+ completed gigs
- **Selfie verification** screen for identity confirmation

### 🔔 Notifications
- **In-app notification center** with unread badge
- Event-driven alerts for: job accepted, gig released, payment received, new review

### 🎨 Premium Dark UI
- **Matte-black** design system (`#0D0D0D` base)
- **Cyan accent** (`#00D1B2`) for interactive elements
- **Inter** font via Google Fonts with a refined typography hierarchy
- Smooth **micro-animations** via `flutter_animate`
- Elevated card surfaces with subtle dividers (no heavy glassmorphism)

---

## 🏗️ Architecture

The project follows a **feature-first** structure with clean separation of concerns:

```
Provider (State Management)
    ↕
Services (Auth + Database)
    ↕
Firestore (Cloud Backend)
```

**State Management:** `Provider` + `ChangeNotifier`
**Backend:** Firebase (Auth, Firestore, Storage)
**Maps:** OpenStreetMap via `flutter_map` + `latlong2`

---

## 📁 Project Structure

```
HyperLocal Gig/
│
├── lib/
│   ├── main.dart                          # App entry point, Firebase init, AuthGate
│   │
│   ├── core/
│   │   └── theme/
│   │       └── app_theme.dart             # AppColors, AppTheme (dark theme config)
│   │
│   ├── models/
│   │   ├── job_model.dart                 # GigJob, JobCategory, JobStatus, JobType enums
│   │   └── user_model.dart                # UserProfile, UserRole enum
│   │
│   ├── providers/
│   │   └── app_state.dart                 # Central state: auth, jobs, filters, wallet, notifications
│   │
│   ├── services/
│   │   ├── auth_service.dart              # Firebase Auth (email, phone OTP, password reset)
│   │   └── database_service.dart          # Firestore CRUD for users & jobs
│   │
│   ├── screens/
│   │   ├── onboarding_screen.dart         # Animated onboarding carousel
│   │   ├── login_screen.dart              # Email/phone login & registration
│   │   ├── main_shell.dart                # Bottom nav shell (role-aware navigation)
│   │   ├── home_screen.dart               # Map view + list view with filters
│   │   ├── post_job_screen.dart           # Create a new gig form
│   │   ├── job_detail_screen.dart         # Full job info + accept/release actions
│   │   ├── activity_screen.dart           # Accepted & posted gigs tracker
│   │   ├── notifications_screen.dart      # In-app notification center
│   │   ├── profile_screen.dart            # User profile, wallet, skills, settings
│   │   └── selfie_verification_screen.dart# Identity verification via camera
│   │
│   ├── widgets/
│   │   ├── glass_card.dart                # Elevated card container widget
│   │   ├── job_card.dart                  # Gig card for list view
│   │   ├── category_chip.dart             # Filterable category chip
│   │   └── user_avatar.dart               # Avatar with fallback initials
│   │
│   └── data/
│       └── mock_data.dart                 # Sample/seed data for development
│
├── assets/
│   └── images/                            # App images & icons
│
├── android/                               # Android platform config
├── ios/                                   # iOS platform config
├── web/                                   # Web platform config
├── windows/                               # Windows platform config
│
├── firestore.rules                        # Firestore security rules
├── pubspec.yaml                           # Dependencies & assets
├── analysis_options.yaml                  # Dart linter rules
└── README.md                              # You are here!
```

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| **Framework** | Flutter 3.10+ / Dart 3.10+ |
| **State Management** | Provider + ChangeNotifier |
| **Authentication** | Firebase Auth (Email, Phone OTP) |
| **Database** | Cloud Firestore (real-time streams) |
| **Storage** | Firebase Storage (avatars) |
| **Maps** | flutter_map + OpenStreetMap (free, no API key) |
| **Geocoding** | geolocator + geocoding |
| **Animations** | flutter_animate |
| **Typography** | Google Fonts (Inter) |
| **UI Extras** | shimmer, cached_network_image, flutter_rating_bar |

---

## ⚡ Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** `>=3.10.4` — [Install Flutter](https://docs.flutter.dev/get-started/install)
- **Dart SDK** `>=3.10.4` (bundled with Flutter)
- **Firebase CLI** — [Install Firebase CLI](https://firebase.google.com/docs/cli)
- **Android Studio** or **VS Code** with Flutter/Dart plugins
- A **Firebase project** with Firestore, Auth, and Storage enabled
- **Git** for version control

---

## 🚀 Setup & Installation

### 1. Clone the Repository

```bash
git clone https://github.com/Shubham-Bhayaje/MY-GIG.git
cd MY-GIG
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Firebase Configuration

This project uses Firebase for authentication, database, and storage. You need to configure it for your own Firebase project:

#### Option A: Using FlutterFire CLI (Recommended)

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase (follow the interactive prompts)
flutterfire configure
```

#### Option B: Manual Configuration

1. Go to [Firebase Console](https://console.firebase.google.com/) and create a new project (or use an existing one).

2. **Android:**
   - Register your Android app with package name from `android/app/build.gradle`
   - Download `google-services.json` and place it in `android/app/`

3. **iOS:**
   - Register your iOS app with the bundle ID from Xcode
   - Download `GoogleService-Info.plist` and place it in `ios/Runner/`

4. **Web:**
   - Register a web app and copy the Firebase config into `web/index.html` or use `DefaultFirebaseOptions`

### 4. Enable Firebase Services

In your Firebase Console, enable:

- ✅ **Authentication** — Email/Password and Phone sign-in providers
- ✅ **Cloud Firestore** — Create a database (start in test mode or deploy the included rules)
- ✅ **Firebase Storage** — Enable for avatar uploads

### 5. Deploy Firestore Security Rules

```bash
firebase deploy --only firestore:rules
```

Or manually copy the contents of `firestore.rules` into your Firebase Console → Firestore → Rules.

### 6. Run the App

```bash
# List available devices
flutter devices

# Run on a connected device or emulator
flutter run

# Run on Chrome (web)
flutter run -d chrome

# Run on a specific device
flutter run -d <device-id>
```

---

## 🔒 Firestore Security Rules

The included `firestore.rules` enforce:

| Rule | Description |
|---|---|
| **User Profiles** | Users can only write to their own `/users/{uid}` document |
| **Accepted Jobs** | Users can only access their own `/users/{uid}/accepted_jobs/` subcollection |
| **Job Creation** | Any authenticated user can create a job (with server-side validation: `payRate > 0`, non-empty `title`, valid `status`) |
| **Job Updates** | Only the original poster can update or delete their own jobs |
| **Read Access** | All authenticated users can read users and jobs |

---

## 📱 Supported Platforms

| Platform | Status |
|---|---|
| 🤖 Android | ✅ Fully Supported |
| 🍎 iOS | ✅ Fully Supported |
| 🌐 Web (Chrome) | ✅ Supported |
| 🪟 Windows | ⚠️ Experimental |

---

## 🧪 Running Tests

```bash
# Run all unit & widget tests
flutter test

# Run with coverage
flutter test --coverage
```

---

## 📦 Build for Production

```bash
# Android APK
flutter build apk --release

# Android App Bundle (for Play Store)
flutter build appbundle --release

# iOS (requires macOS + Xcode)
flutter build ios --release

# Web
flutter build web --release
```

---

## 🤝 Contributing

Contributions are welcome! Here's how to get started:

1. **Fork** the repository
2. **Create** a feature branch: `git checkout -b feature/amazing-feature`
3. **Commit** your changes: `git commit -m "Add amazing feature"`
4. **Push** to the branch: `git push origin feature/amazing-feature`
5. **Open** a Pull Request

### Code Style
- Follow [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Run `flutter analyze` before submitting PRs
- Maintain the existing dark theme design system

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Author

**Shubham Bhayaje**

GitHub: [@Shubham-Bhayaje](https://github.com/Shubham-Bhayaje)

---

<div align="center">

**⭐ Star this repo if you find it useful!**

Built with ❤️ using Flutter & Firebase

</div>
