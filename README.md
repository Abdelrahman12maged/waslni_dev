<div align="center">

  # 🚗 Waslni — Smart Ride-Hailing & Carpooling Platform

  **A production-ready, high-performance Flutter mobile application for real-time ride-hailing, carpooling, and intelligent GPS driver navigation.**

  [![Flutter Version](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white&style=for-the-badge)](https://flutter.dev)
  [![Dart Version](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white&style=for-the-badge)](https://dart.dev)
  [![Architecture](https://img.shields.io/badge/Architecture-Clean%20Architecture-4CAF50?style=for-the-badge)](https://blog.cleancoder.com/)
  [![State Management](https://img.shields.io/badge/State%20Management-BLoC%20%2F%20Cubit-blueviolet?style=for-the-badge)](https://bloclibrary.dev/)
  [![Firebase](https://img.shields.io/badge/Firebase-Firestore%20%7C%20FCM-FFCA28?logo=firebase&logoColor=black&style=for-the-badge)](https://firebase.google.com/)
  [![Google Maps](https://img.shields.io/badge/Maps-Google%20Maps%20%26%20OSRM-4285F4?logo=googlemaps&logoColor=white&style=for-the-badge)](https://cloud.google.com/maps-platform)
  [![Platforms](https://img.shields.io/badge/Platforms-Android%20%7C%20iOS-brightgreen?style=for-the-badge)](#)
  [![License](https://img.shields.io/badge/License-MIT-orange?style=for-the-badge)](LICENSE)

  [English](#-english) • [العربية](#-عربي) • [Key Features](#-key-features) • [Screenshots](#-screenshots) • [Architecture](#-architecture--design-patterns) • [Tech Stack](#-tech-stack) • [Getting Started](#-getting-started)

</div>

---

## 📖 Overview

**Waslni** is an enterprise-grade, full-featured transportation application built with Flutter. It connects passengers and drivers through two flexible trip models:

1. **Private Trips (On-Demand / Taxi)** — Direct door-to-door rides with a dynamic bidding system where drivers submit competing price offers.
2. **Shared Trips (Carpooling)** — Cost-effective group rides where drivers or passengers create routes and passengers book individual seats.

The application features **Google Maps-style 3D turn-by-turn navigation**, sub-second GPS live location streaming via **Cloud Firestore**, real-time **in-app chat**, and intelligent **geofencing**.

---

## 📱 Screenshots

### 1. Onboarding & Verification

<table>
<tr>
<td align="center" width="220">
<img width="220" alt="Onboarding welcome" src="https://github.com/user-attachments/assets/57808445-b713-4e3b-9ec0-6f1ec0700af0" /><br/>
<sub><b>Welcome</b></sub>
</td>
<td align="center" width="220">
<img width="220" alt="Document verification" src="https://github.com/user-attachments/assets/37b18169-3261-48ac-a21c-d2bb2a194e1e" /><br/>
<sub><b>Document Verification</b></sub>
</td>
<td align="center" width="220">
<img width="220" alt="Home page" src="https://github.com/user-attachments/assets/06944b02-43c2-4d12-8a5c-2210d17d17a3" /><br/>
<sub><b>Home Page</b></sub>
</td>
</tr>
</table>

### 2. Booking a Ride

<table>
<tr>
<td align="center" width="220">
<img width="220" alt="Select destination" src="https://github.com/user-attachments/assets/3ca9d24c-ce65-40d1-aaf0-d37a2e97f739" /><br/>
<sub><b>Select Destination</b></sub>
</td>
<td align="center" width="220">
<img width="220" alt="Trip request pending" src="https://github.com/user-attachments/assets/690ebc6f-3add-4ea9-8309-1854c21356c6" /><br/>
<sub><b>Request Pending</b></sub>
</td>
<td align="center" width="220">
<img width="220" alt="Trip pricing offer" src="https://github.com/user-attachments/assets/3217c3a2-f683-4767-b8a1-94116511e4e8" /><br/>
<sub><b>Fare Offer</b></sub>
</td>
<td align="center" width="220">
<img width="220" alt="Driver offer received" src="https://github.com/user-attachments/assets/79d00a76-4b04-4d7b-a5cb-971cc9bb49be" /><br/>
<sub><b>Accept Offer</b></sub>
</td>
</tr>
</table>

### 3. Live Trip Tracking

<table>
<tr>
<td align="center" width="220">
<img width="220" alt="Driver en route" src="https://github.com/user-attachments/assets/97ff4d06-c1a7-4ccb-985a-cbe68902fbb6" /><br/>
<sub><b>Driver En Route</b></sub>
</td>
<td align="center" width="220">
<img width="220" alt="Driver approaching" src="https://github.com/user-attachments/assets/2d43c2c8-0e9c-4fd4-b525-12826b87b25c" /><br/>
<sub><b>Driver Approaching</b></sub>
</td>
<td align="center" width="220">
<img width="220" alt="Driver arrived" src="https://github.com/user-attachments/assets/9337b79a-5d6e-49e4-8491-aafcb152ea80" /><br/>
<sub><b>Driver Arrived</b></sub>
</td>
<td align="center" width="220">
<img width="220" alt="Trip in progress" src="https://github.com/user-attachments/assets/d90298c6-214c-48ee-bb10-e812ec4be49d" /><br/>
<sub><b>Trip In Progress</b></sub>
</td>
</tr>
</table>

### 4. Post-Trip

<table>
<tr>
<td align="center" width="220">
<img width="220" alt="Trip rating" src="https://github.com/user-attachments/assets/a821f74a-216b-439a-9d98-5041913b7e7c" /><br/>
<sub><b>Rate the Trip</b></sub>
</td>
<td align="center" width="220">
<img width="220" alt="My trips history" src="https://github.com/user-attachments/assets/570aa43d-862f-4974-8ffc-109bdcb2fb70" /><br/>
<sub><b>Trip History</b></sub>
</td>
</tr>
</table>

### 5. Communication & Account

<table>
<tr>
<td align="center" width="220">
<img width="220" alt="Chat with driver" src="https://github.com/user-attachments/assets/add6d3b4-32ae-40a6-90f5-2e7669a3f879" /><br/>
<sub><b>Chat with Driver</b></sub>
</td>
<td align="center" width="220">
<img width="220" alt="Driver ratings and reviews" src="https://github.com/user-attachments/assets/01fbf997-0b75-4ff3-b7b6-c62c9e4b6790" /><br/>
<sub><b>Driver Ratings</b></sub>
</td>
<td align="center" width="220">
<img width="220" alt="Notifications" src="https://github.com/user-attachments/assets/3cadc66b-a04e-4e3c-a4b2-348ee87445df" /><br/>
<sub><b>Notifications</b></sub>
</td>
<td align="center" width="220">
<img width="220" alt="Settings" src="https://github.com/user-attachments/assets/2c0adbc7-1434-485b-9ed7-48e9f255c8a3" /><br/>
<sub><b>Settings</b></sub>
</td>
</tr>
</table>

### 6. Driver App

<table>
<tr>
<td align="center" width="220">
<img width="220" alt="Driver app dashboard" src="https://github.com/user-attachments/assets/614e7d73-528d-4a16-9302-c7456d240398" /><br/>
<sub><b>Driver Dashboard</b></sub>
</td>
</tr>
</table>

---

## ✨ Key Features

### 👤 Passenger Experience
- **Instant & Scheduled Bookings**: Request an immediate ride or schedule a trip for a future date and time.
- **Dynamic Bidding & Offers**: Receive multiple offers from nearby drivers, view driver ratings, vehicle details, and accept the best price.
- **Carpooling / Seat Sharing**: Search and book available seats on shared routes with gender-preference filters and transparent per-seat pricing.
- **Live Ride Tracking**: Track driver approach in real-time with continuous distance remaining and accurate Estimated Time of Arrival (ETA).
- **Saved Locations**: Bookmark frequent destinations (Home, Work, Favorites) for one-tap trip creation.

### 🚘 Driver Experience
- **Nearby Trip Radar**: Real-time broadcast radar displaying active ride requests and passenger pickups nearby.
- **Custom Price Bidding**: Propose competitive pricing within system-defined minimum and maximum fare boundaries.
- **Turn-by-Turn Navigation Camera**:
  - **3D Navigation Perspective**: Automatic 45° tilt with camera rotation matching the vehicle's heading (`bearing`).
  - **Zero-Lag Polyline Trimming**: Instant in-memory clipping (0ms) of traversed roads as the driver advances.
  - **Ultra-Fast Rerouting**: Automatic off-route detection (>45m) with road recalculation in **under 250ms**.
  - **Interactive Free-Roam**: Pan and zoom freely to inspect the route; automatically recenters after 8 seconds of inactivity.
- **Document & Vehicle Verification**: Driver onboarding flow supporting driver's license, vehicle registration, and identity verification.

### 📡 Real-Time & Communications
- **Sub-Second GPS Broadcasting**: Low-latency vehicle telemetry streamed through Firebase Cloud Firestore.
- **Real-Time In-App Chat**:
  - Direct 1-on-1 trip chat between passenger and driver.
  - Multi-passenger group chat for shared carpool trips with live unread badge counters.
- **FCM Push Notifications**: Deep-linked push notifications for ride requests, price offers, trip acceptance, cancellations, and driver arrival.
- **Automated Geofencing**: 200-meter proximity validation verifying driver arrival before enabling boarding state transitions.

### 🛡️ Safety, Rating & Resilience
- **Two-Way Rating System**: Interactive 5-star ratings and reviews for both drivers and passengers.
- **Offline Connectivity Banner**: Real-time network listener alerting users when cellular connection drops.
- **Dual Routing Fallback**: Primary Google Directions API paired with an ultra-fast OSRM circuit breaker ensuring 100% map availability.
- **Full Internationalization (i18n)**: Native support for Arabic (RTL) and English (LTR) with seamless in-app locale switching.

---

## 🏗 Architecture & Design Patterns

The project is structured according to **Clean Architecture** principles combined with the **BLoC (Business Logic Component)** pattern, ensuring separation of concerns, testability, and maintainability.

```mermaid
graph TD
    UI[Presentation Layer: Widgets & Pages] <--> BLoC[State Management: Cubits / BLoC]
    BLoC <--> UseCases[Domain Layer: Use Cases & Entities]
    UseCases <--> Repos[Domain Layer: Repository Interfaces]
    Repos <--> RepoImpl[Data Layer: Repository Implementations]
    RepoImpl <--> Remote[Remote Data Sources: REST API & Firebase]
    RepoImpl <--> Local[Local Data Sources: Hive & SecureStorage]
```

### Layer Responsibilities
- **`core/`**: Cross-cutting infrastructure, dependency injection, theme tokens, custom widgets, network clients, route definitions, and security validators.
- **`features/*/presentation/`**: Screen layouts, reusable UI components, and state management via **Cubit**.
- **`features/*/domain/`**: Pure business rules, entities, and repository contracts (zero framework dependencies).
- **`features/*/data/`**: Data models (with JSON serialization), API endpoints, remote data sources (Dio / Firestore), and local storage caching.

---

## 📂 Directory Structure

```text
lib/
├── core/
│   ├── data/             # Shared data models & pagination
│   ├── di/               # Service locator (GetIt) dependency injection
│   ├── error/            # Failure types & exception handling
│   ├── network/          # Dio client, interceptors & API endpoints
│   ├── router/           # GoRouter configuration & deep link handlers
│   ├── services/         # GPS tracking, FCM, RemoteConfig & Geofencing
│   ├── storage/          # Hive, SharedPreferences & SecureStorage
│   ├── theme/            # Color palettes, typography & map styling
│   └── widgets/          # Shared components, banners & dialogs
├── features/
│   ├── auth/             # Login, signup (Driver & Passenger), OTP verification
│   ├── chat/             # 1-on-1 & shared group trip chat (Firestore)
│   ├── driver_documents/ # Document upload & verification
│   ├── home/             # Passenger & Driver home dashboards
│   ├── legal/            # Privacy policy & terms of service
│   ├── map/              # Dual routing engine (Google + OSRM) & geocoding
│   ├── notifications/    # In-app notifications & history
│   ├── onboarding/       # Walkthrough screens & language selection
│   ├── ratings/          # Rating dialogs, pending & submitted reviews
│   ├── settings/         # Profile management & saved locations
│   └── trips/            # Private & shared trip workflows (Passenger & Driver)
├── generated/            # Flutter Intl code-generated classes
├── l10n/                 # Localization ARB files (Arabic & English)
├── firebase_options.dart # Firebase platform configuration
└── main.dart             # Application entry point & global providers
```

---

## 🛠 Tech Stack

| Category | Technology / Package | Description |
| :--- | :--- | :--- |
| **Framework** | [Flutter 3.x](https://flutter.dev) | Cross-platform UI toolkit |
| **Language** | [Dart 3.x](https://dart.dev) | Strongly-typed, null-safe language |
| **State Management** | [`flutter_bloc`](https://pub.dev/packages/flutter_bloc) | Predictable, reactive state management |
| **Routing** | [`go_router`](https://pub.dev/packages/go_router) | Declarative routing with deep linking |
| **Dependency Injection**| [`get_it`](https://pub.dev/packages/get_it) | Fast service locator pattern |
| **Maps & Navigation** | [`google_maps_flutter`](https://pub.dev/packages/google_maps_flutter) | High-performance interactive Google Maps |
| **Location Engine** | [`geolocator`](https://pub.dev/packages/geolocator) & [`geocoding`](https://pub.dev/packages/geocoding) | GPS coordinates & reverse address lookup |
| **Networking** | [`dio`](https://pub.dev/packages/dio) | HTTP client with interceptors & token refresh |
| **Cloud & Realtime** | [`cloud_firestore`](https://pub.dev/packages/cloud_firestore) | Sub-second driver location sync & live chat |
| **Push Notifications** | [`firebase_messaging`](https://pub.dev/packages/firebase_messaging) | Remote alerts with foreground heads-up banners |
| **Local Storage** | [`hive_flutter`](https://pub.dev/packages/hive_flutter) | High-performance NoSQL local key-value store |
| **Secure Storage** | [`flutter_secure_storage`](https://pub.dev/packages/flutter_secure_storage) | Keychain / Keystore encrypted auth tokens |
| **Internationalization**| [`flutter_localizations`](https://api.flutter.dev/flutter/flutter_localizations/flutter_localizations-library.html) | Arabic (RTL) & English (LTR) |

---

## 📄 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

<div align="center">
  <sub>Developed with ❤️ using Flutter & Dart.</sub>
</div>
