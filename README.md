# 🚗 Wasslni (Ride Booking & Management App)

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.10+-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Architecture](https://img.shields.io/badge/Architecture-Clean%20Architecture-blueviolet?style=for-the-badge)
![State Management](https://img.shields.io/badge/State%20Management-BLoC%20%2F%20Cubit-red?style=for-the-badge)
![Firebase](https://img.shields.io/badge/Firebase-Core%20%7C%20Firestore%20%7C%20FCM-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Google Maps](https://img.shields.io/badge/Google%20Maps-Places%20%26%20Tracking-4285F4?style=for-the-badge&logo=googlemaps&logoColor=white)

**A complete platform for booking and managing private and shared (carpooling) trips in real time between passengers and drivers.**

[Features](#-key-features) • [Architecture](#-architecture) • [Project Structure](#-project-structure) • [Installation & Setup](#-installation--setup) • [Environment Setup](#-environment-variables-env) • [Coding Guidelines](#-coding-guidelines)

</div>

---

## 📖 Table of Contents
1. [About the Project](#-about-the-project)
2. [Key Features](#-key-features)
   - [Passenger Experience](#1-passenger-experience)
   - [Driver Experience](#2-driver-experience)
   - [Shared Features & Supporting Systems](#3-shared-features--supporting-systems)
3. [Architecture & Tech Stack](#-architecture)
4. [Project Structure](#-project-structure)
5. [Installation & Setup](#-installation--setup)
6. [Environment Variables (.env)](#-environment-variables-env)
7. [Coding Guidelines](#-coding-guidelines)
8. [API Endpoints Overview](#-api-endpoints-overview)

---

## 🌟 About the Project

**Wasslni** is an advanced, cross-platform mobile application (Flutter) that connects **passengers** with **drivers**, offering two ways to request a ride:
- **Private Trips:** A direct ride from pickup to drop-off, with the ability to submit and negotiate price offers (bidding) in real time.
- **Shared Trips / Carpooling:** Passengers can share a trip route with other riders to reduce cost and fuel consumption.
- **Scheduled Trips:** Book future rides for a specific date and time in advance.

The app is built on a strict **Clean Architecture**, with fully separated layers to make it easy to scale, test, and maintain. State is managed with **BLoC / Cubit**, with real-time sync powered by **Firebase** and **Google Maps**.

---

## ✨ Key Features

### 1. Passenger Experience
* **Request a Private Ride:** Set pickup and drop-off points on the map via search or GPS.
* **Driver Bidding System:** Receive competitive price offers from nearby drivers and pick the best offer based on price, driver rating, and vehicle type.
* **Carpooling:** Search for available shared trips nearby and join one, or request a new shared trip.
* **Live Tracking:** Watch the driver's location on the map in real time, with live updates to route, distance, and estimated time of arrival (ETA).
* **Manage Current & Past Trips:** Browse completed trip history and view current trip details.
* **Saved Locations:** Save frequently used addresses (e.g. Home, Work) for one-tap selection.
* **Driver Ratings & Reviews:** Rate the trip experience and leave feedback right after the ride ends.

### 2. Driver Experience
* **Browse Nearby Trips:** View a map and list of available passenger requests in the area.
* **Make Offers:** Send custom price offers to passengers and update offer status.
* **Turn-by-Turn Navigation:** Track the trip route on the map, with defined pickup and drop-off points.
* **Trip Lifecycle:**
  * Notify arrival at the meeting point (Driver Arrived).
  * Start Trip.
  * Manage passenger boarding status on shared trips (Passenger In-Car Status).
  * Successfully End Trip.
* **Driver KYC & Documents:**
  * Upload National ID documents.
  * Upload criminal record clearance certificate.
  * Upload driving license and vehicle license.
  * Track review and account approval status.
* **Driver Dashboard:** View total completed trips, overall rating, and total earnings.

### 3. Shared Features & Supporting Systems
* **Real-Time Chat:** Built-in chat system powered by Cloud Firestore for instant communication between passenger and driver, including trip details in the chat header and offer-confirmation alerts.
* **Smart Notifications (Push Notifications & Deep Linking):**
  * Firebase Cloud Messaging (FCM) notifications that work in the background and while the app is open.
  * Interactive in-app notification banners.
  * Smart deep linking that takes the user straight to the relevant trip or chat screen when a notification is tapped.
* **Home Screen Widget:** Android widget support via the `home_widget` package for a quick, one-tap view of trip status.
* **Security & Verification System:**
  * Login via phone number and password.
  * OTP verification with code resend and password recovery options.
  * Secure storage of credentials and tokens via `FlutterSecureStorage`.
* **Full Arabic & English Localization:**
  * Full support for Arabic (RTL) and English (LTR).
  * Quick language switching from within settings, with the user's choice saved automatically.

---

## 🏗 Architecture

The project is built on **Clean Architecture** with a clear separation of concerns:

```
┌─────────────────────────────────────────────────────────┐
│                   Presentation Layer                    │
│      StatelessWidgets • BLoC / Cubit • GoRouter         │
└────────────────────────────┬────────────────────────────┘
                             │ calls
                             ▼
┌─────────────────────────────────────────────────────────┐
│                      Domain Layer                       │
│           Entities • UseCases • Repositories (Contracts)│
└────────────────────────────┬────────────────────────────┘
                             │ implemented by
                             ▼
┌─────────────────────────────────────────────────────────┐
│                       Data Layer                        │
│      Models • Repositories (Impl) • Remote/Local DS     │
└─────────────────────────────────────────────────────────┘
```

### Tech Stack:
| Area | Technology | Description |
|---|---|---|
| **Framework** | Flutter 3.10+ / Dart 3.0+ | High-performance cross-platform app development |
| **State Management** | `flutter_bloc` / `bloc` | Reactive, stable state management via Cubits |
| **Navigation & Routing**| `go_router` | Declarative routing system with Deep Link support |
| **Networking** | `dio` | Powerful HTTP client with interceptors and centralized error handling |
| **Realtime & Cloud** | `firebase_core`, `cloud_firestore`, `firebase_messaging` | Real-time database, chat, and instant notifications |
| **Maps & Geo** | `google_maps_flutter`, `geolocator`, `geocoding` | Map display, location tracking, and route calculation |
| **Local Storage** | `flutter_secure_storage`, `shared_preferences`, `hive` | Secure storage for JWT tokens, local data, and settings |
| **Dependency Injection**| `get_it` | Dependency injection as Singletons and Factories via a central container |
| **Internationalization**| `flutter_localizations`, `intl` | Full text localization using ARB formats |
| **App Widget** | `home_widget` | Home screen widget for Android |

---

## 📁 Project Structure

```text
lib/
├── core/                         # Shared, core building blocks of the app
│   ├── data/                     # General-purpose data models
│   ├── di/                       # Dependency injection (injection_container.dart)
│   ├── error/                    # Error handling (Failures & Exceptions)
│   ├── formatters/               # Text and date formatting utilities
│   ├── network/                  # Network client (ApiClient, ApiEndpoints, Interceptors)
│   ├── resources/                # Shared resources (Strings, Assets, Styles)
│   ├── router/                   # Centralized routing (AppRouter, AppRoutes)
│   ├── services/                 # System services (Location, HomeWidget, Routing)
│   ├── storage/                  # Local and secure storage modules (LocalStorage, SecureStorage)
│   ├── theme/                    # Unified colors and themes (AppColors, AppTheme)
│   ├── usecases/                 # Standard UseCase interface
│   ├── utils/                    # Helper functions and utilities (BlocObserver, FCMService)
│   └── widgets/                  # App-wide shared components and widgets
│
├── features/                     # App features (feature modularity)
│   ├── auth/                     # Authentication, login, signup, OTP verification
│   ├── chat/                     # Real-time chat between passenger and driver
│   ├── driver_documents/         # Driver document upload and verification (KYC)
│   ├── home/                     # Home screens and menus for passenger and driver
│   ├── legal/                    # Terms & conditions and privacy policy
│   ├── map/                      # Map services, routing, and geocoding
│   ├── notifications/            # Notification history screen and management
│   ├── onboarding/               # Welcome and app-introduction screens
│   ├── ratings/                  # Ratings and reviews system
│   ├── settings/                 # Account settings, language, and saved locations
│   └── trips/                    # Trip management (private, shared, scheduled, and tracking)
│       ├── data/                 # Data sources, repositories, and trip models
│       ├── domain/               # Entities and use cases
│       └── presentation/         # UI screens and Cubits for passenger and driver
│
├── generated/                    # Auto-generated translation files (intl)
├── l10n/                         # Language files (intl_ar.arb, intl_en.arb)
├── firebase_options.dart         # Firebase platform configuration
└── main.dart                     # App entry point and service setup
```

---




<div align="center">
  <sub>Crafted with care by the app development team • Wasslni © 2026</sub>
</div>
