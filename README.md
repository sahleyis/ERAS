# 🚨 ERAS — Emergency Response Alert System

> A Flutter + Firebase mobile application connecting medical emergencies with nearby trained volunteer first responders in Nigeria.

---

## 🏗 Architecture

```
ERAS uses Clean Architecture with Riverpod state management:

┌─────────────────────────────────────────────┐
│                  UI Layer                    │
│   Screens, Widgets, Animations              │
├─────────────────────────────────────────────┤
│              State Layer                     │
│   Riverpod Providers & Notifiers            │
├─────────────────────────────────────────────┤
│             Service Layer                    │
│   Auth, Firestore, Location, FCM,           │
│   ProximityService, ChatService             │
├─────────────────────────────────────────────┤
│              Data Layer                      │
│   Models (User, Emergency, Chat)            │
├─────────────────────────────────────────────┤
│            Infrastructure                    │
│   Firebase (Auth, Firestore, FCM)           │
│   Google Maps API, GeoFlutterFire           │
│   Cloud Functions (Node.js/TypeScript)      │
└─────────────────────────────────────────────┘
```

## 🎯 Core Features

### 1. Dual-User Interface
- **Victim Mode** — Giant 160dp pulsing SOS button, 2-tap emergency trigger
- **Responder Mode** — Active/inactive toggle, incoming alert cards, turn-by-turn navigation

### 2. Expanding Search Algorithm
```
500m → 1km → 2km → 5km
 30s    30s    30s    30s
```
Progressively expands search radius every 30 seconds until a responder accepts. Runs both client-side (Flutter) and server-side (Cloud Functions) for reliability.

### 3. Real-Time Infrastructure
- **Google Maps** — Dark-styled maps with route polylines and real-time positioning
- **FCM** — Critical push notifications that bypass Do Not Disturb
- **Real-time Chat** — Firestore-backed messaging with read receipts

### 4. Medical Profile Integration
- Blood type, allergies, chronic conditions, emergency contacts
- Encrypted at rest, visible to responders only during active emergencies
- Enforced by Firestore Security Rules

### 5. Verification Badge System
- Three states: Pending (gray), Verified (blue shield), Rejected (red)
- Medical credential verification by admin

---

## 📁 Project Structure

```
ERAs/
├── pubspec.yaml                    # Dependencies
├── lib/
│   ├── main.dart                   # App entry point
│   ├── app.dart                    # MaterialApp + routes
│   ├── config/
│   │   ├── theme.dart              # Panic-proof design system
│   │   ├── constants.dart          # Search radii, enums, config
│   │   └── routes.dart             # Named routes
│   ├── models/
│   │   ├── user_model.dart         # User + MedicalProfile + ResponderProfile
│   │   ├── emergency_model.dart    # Emergency event model
│   │   └── chat_message_model.dart # Chat messages
│   ├── services/
│   │   ├── auth_service.dart       # Firebase Auth (email + phone OTP)
│   │   ├── firestore_service.dart  # CRUD for all collections
│   │   ├── location_service.dart   # GPS tracking + geocoding
│   │   ├── notification_service.dart # FCM + local notifications
│   │   ├── proximity_service.dart  # ⭐ Expanding search algorithm
│   │   └── chat_service.dart       # Real-time messaging
│   ├── providers/
│   │   ├── auth_provider.dart      # Auth state + user model
│   │   ├── emergency_provider.dart # SOS trigger + search state
│   │   ├── location_provider.dart  # Position streams
│   │   └── responder_provider.dart # Active toggle + alert handling
│   ├── screens/
│   │   ├── auth/                   # Login + Register
│   │   ├── victim/                 # SOS Home, Type Select, Waiting, Match
│   │   ├── responder/              # Dashboard, Alert Detail, Navigation
│   │   ├── profile/                # Medical + Responder profiles
│   │   └── chat/                   # Emergency chat
│   └── widgets/
│       ├── sos_button.dart         # ⭐ Giant pulsing SOS button
│       ├── emergency_type_card.dart
│       ├── alert_card.dart         # Incoming alert with accept/decline
│       ├── responder_card.dart
│       ├── verification_badge.dart # 3-state credential badge
│       ├── pulse_animation.dart    # Radar + pulse animations
│       └── map_view.dart           # Dark-styled Google Map
├── cloud_functions/
│   ├── index.ts                    # Entry point
│   ├── proximity_search.ts        # ⭐ Server-side expanding search
│   └── send_notification.ts       # FCM dispatch + match notification
├── firebase/
│   ├── firestore.rules             # Security rules
│   └── firestore.indexes.json     # Composite indexes
└── assets/
    ├── icons/
    ├── images/
    └── sounds/
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.16+
- Firebase CLI
- Google Maps API key (Maps SDK, Directions API, Geocoding API)
- Node.js 18+ (for Cloud Functions)

### Setup

1. **Clone & install dependencies:**
   ```bash
   cd ERAs
   flutter pub get
   ```

2. **Configure Firebase:**
   ```bash
   firebase login
   flutterfire configure
   ```
   This generates `firebase_options.dart` — update `main.dart` to use it.

3. **Set Google Maps API key:**
   - **Android:** `android/app/src/main/AndroidManifest.xml`
     ```xml
     <meta-data android:name="com.google.android.geo.API_KEY"
                android:value="YOUR_API_KEY"/>
     ```
   - **iOS:** `ios/Runner/AppDelegate.swift`
     ```swift
     GMSServices.provideAPIKey("YOUR_API_KEY")
     ```

4. **Deploy Firestore rules & indexes:**
   ```bash
   firebase deploy --only firestore
   ```

5. **Deploy Cloud Functions:**
   ```bash
   cd cloud_functions
   npm install
   firebase deploy --only functions
   ```

6. **Run:**
   ```bash
   flutter run
   ```

---

## 🔐 Security

- Firestore Security Rules enforce per-user access
- Medical profiles only readable by assigned responders during active emergencies
- FCM tokens stored per-device, not shared
- Sensitive data encrypted via `flutter_secure_storage`

---

## 📱 UI Design Principles (Panic-Proof)

| Principle | Implementation |
|-----------|---------------|
| Large touch targets | SOS button: 160dp, all buttons ≥ 48dp |
| High contrast | Dark background (#0D0D0D), vivid red/blue |
| Minimal steps | 2 taps: SOS → select type → alert sent |
| Clear feedback | Pulse animations, radar sweep, status text |
| Accessibility | Semantic labels, haptic feedback |

---

## 🇳🇬 Nigeria-Specific Features

- Nigerian emergency numbers (112, NEMA, 199)
- Phone OTP authentication (+234 prefix)
- Lagos default map center
- Offline-capable with Firestore persistence

---

