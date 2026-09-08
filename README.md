# 🚗 Car App (تطبيق إدارة وحجز الرحلات)

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.10+-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Architecture](https://img.shields.io/badge/Architecture-Clean%20Architecture-blueviolet?style=for-the-badge)
![State Management](https://img.shields.io/badge/State%20Management-BLoC%20%2F%20Cubit-red?style=for-the-badge)
![Firebase](https://img.shields.io/badge/Firebase-Core%20%7C%20Firestore%20%7C%20FCM-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Google Maps](https://img.shields.io/badge/Google%20Maps-Places%20%26%20Tracking-4285F4?style=for-the-badge&logo=googlemaps&logoColor=white)

**منصة متكاملة لحجز الرحلات الخاصة والتشاركية (Carpooling) وإدارتها في الوقت الفعلي بين الركاب والسائقين.**

[المميزات](#-المميزات-الرئيسية) • [البنية المعمارية](#-البنية-المعمارية-architecture) • [هيكل المشروع](#-هيكل-المشروع-project-structure) • [التثبيت والتشغيل](#-التثبيت-والتشغيل) • [إعداد البيئة](#-إعداد-متغيرات-البيئة-env) • [معايير الكود](#-معايير-البرمجة-coding-guidelines)

</div>

---

## 📖 جدول المحتويات
1. [نبذة عن المشروع](#-نبذة-عن-المشروع)
2. [المميزات الرئيسية](#-المميزات-الرئيسية)
   - [واجهة وتجربة الراكب (Passenger)](#1-واجهة-الراكب-passenger)
   - [واجهة وتجربة السائق (Driver)](#2-واجهة-السائق-driver)
   - [الميزات المشتركة والخدمات المساندة](#3-الميزات-المشتركة-والأنظمة-المساندة)
3. [البنية المعمارية والتقنيات المستخدمة](#-البنية-المعمارية-architecture)
4. [هيكل المشروع (Project Structure)](#-هيكل-المشروع-project-structure)
5. [التثبيت والتشغيل](#-التثبيت-والتشغيل)
6. [إعداد متغيرات البيئة (.env)](#-إعداد-متغيرات-البيئة-env)
7. [معايير البرمجة وإرشادات الكود (Coding Guidelines)](#-معايير-البرمجة-coding-guidelines)
8. [الواجهات البرمجية (API Endpoints Overview)](#-الواجهات-البرمجية-api-overview)

---

## 🌟 نبذة عن المشروع

**Car App** هو تطبيق هاتف متقدم متعدد المنصات (Flutter) يربط بين **الركاب** و**السائقين**، حيث يتيح طلب الرحلات بأسلوبين:
- **الرحلات الخاصة (Private Trips):** رحلة مباشرة من نقطة الانطلاق إلى نقطة الوصول مع إمكانية تقديم وتفاوض عروض الأسعار (Bidding / Offers) في الوقت الفعلي.
- **الرحلات التشاركية (Shared Trips / Carpooling):** إمكانية مشاركة مسار الرحلة بين أكثر من راكب لتقليل التكلفة واستهلاك الوقود.
- **الرحلات المجدولة (Scheduled Trips):** حجز رحلات مستقبلية في وقت وتاريخ محددين مسبقاً.

يعتمد التطبيق على معمارية برمجية صارمة (**Clean Architecture**) بنظام طبقات مفصول تماماً لتسهيل التوسع والاختبار والصيانة، مع إدارة حالة باستخدام **BLoC / Cubit** ومزامنة فورية عبر **Firebase** وخرائط **Google Maps**.

---

## ✨ المميزات الرئيسية

### 1. واجهة الراكب (Passenger)
* **طلب رحلة خاصة (Private Ride):** تحديد نقطة الانطلاق والوصول على الخريطة عبر البحث أو نظام تحديد المواقع (GPS).
* **نظام عروض الأسعار (Driver Bidding System):** استقبال عروض أسعار تنافسية من السائقين القريبين واختيار العرض الأنسب بناءً على السعر، تقييم السائق، ونوع السيارة.
* **الرحلات المشتركة (Carpooling):** البحث عن الرحلات المشتركة المتاحة بالقرب من الموقع والانضمام إليها، أو طلب رحلة مشتركة جديدة.
* **التتبع المباشر (Live Tracking):** مشاهدة موقع السائق على الخريطة لحظياً وتحديث المسار والمسافة والوقت المتوقع للوصول (ETA).
* **إدارة الرحلات الجارية والسابقة:** استعراض سجل الرحلات المكتملة وتفاصيل الرحلة الحالية.
* **الأماكن المحفوظة (Saved Locations):** حفظ العناوين المتكررة (مثل المنزل، العمل) لسرعة الاختيار بنقرة واحدة.
* **تقييم السائق (Ratings & Reviews):** تقييم تجربة الرحلة وإضافة ملاحظات فور انتهاء المشوار.

### 2. واجهة السائق (Driver)
* **تصفح الطلبات القريبة (Nearby Trips):** استعراض خريطة وقائمة بطلبات الركاب المتاحة في المنطقة.
* **تقديم عروض الأسعار (Make Offers):** إرسال عروض أسعار مخصصة للركاب وتحديث حالة العرض.
* **إدارة مسار الرحلة (Turn-by-Turn Navigation):** تتبع مسار الرحلة على الخريطة مع تحديد نقاط الركوب والنزول.
* **دورة حياة الرحلة (Trip Lifecycle):**
  * إشعار الوصول إلى نقطة الالتقاء (Driver Arrived).
  * بدء الرحلة (Start Trip).
  * إدارة ركوب الركاب في الرحلات التشاركية (Passenger In-Car Status).
  * إنهاء الرحلة بنجاح (End Trip).
* **توثيق حساب السائق (Driver KYC & Documents):**
  * رفع مستندات الهوية الوطنية (National ID).
  * رفع شهادة خلو السوابق (Criminal Record).
  * رفع رخصة القيادة ورخصة المركبة (Vehicle & Driving License).
  * متابعة حالة المراجعة والموافقة على الحساب.
* **لوحة الإحصائيات والأرباح (Driver Dashboard):** عرض إجمالي الرحلات المنجزة، التقييم العام، ومجموع الأرباح.

### 3. الميزات المشتركة والأنظمة المساندة
* **محادثة فورية مباشرة (Real-Time Chat):** نظام محادثة مدمج مدعوم بـ Cloud Firestore للتواصل الفوري بين الراكب والسائق، مع تضمين بيانات الرحلة في رأس المحادثة وتنبيهات تأكيد العروض.
* **نظام إشعارات ذكي (Push Notifications & Deep Linking):**
  * إشعارات Firebase Cloud Messaging (FCM) تعمل في الخلفية وأثناء فتح التطبيق.
  * لافتات تنبيهية تفاعلية داخل التطبيق (In-App Notification Banners).
  * توجيه ذكي مباشر (Deep Linking) ينقل المستخدم فور النقر على الإشعار إلى شاشة الرحلة أو المحادثة المعنية.
* **ويجت الشاشة الرئيسية (Home Screen Widget):** دعم ويجت أندرويد عبر حزمة `home_widget` للاطلاع السريع على حالة الرحلة بنقرة واحدة.
* **نظام الأمان والتحقق:**
  * تسجيل الدخول عبر رقم الهاتف وكلمة المرور.
  * كود التحقق (OTP Verification) وإمكانية إعادة إرسال الكود واستعادة كلمة المرور.
  * تخزين آمن لبيانات الاعتماد والرموز (Tokens) عبر `FlutterSecureStorage`.
* **دعم اللغتين العربية والإنجليزية (Full Localization):**
  * دعم كامل للغة العربية (RTL) والإنجليزية (LTR).
  * التبديل السريع بين اللغات من داخل الإعدادات مع الحفظ التلقائي لاختيار المستخدم.

---

## 🏗 البنية المعمارية (Architecture)

تم بناء المشروع بالاعتماد على **Clean Architecture** مع تقسيم واضح للمسؤوليات (Separation of Concerns):

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

### حزمة التقنيات (Tech Stack):
| المجال | التقنية المستخدمة | الوصف |
|---|---|---|
| **Framework** | Flutter 3.10+ / Dart 3.0+ | تطوير تطبيق عالي الأداء لكافة المنصات |
| **State Management** | `flutter_bloc` / `bloc` | إدارة حالة تفاعلية ومستقرة عبر Cubits |
| **Navigation & Routing**| `go_router` | نظام توجيه تصريحي (Declarative Routing) يدعم الـ Deep Links |
| **Networking** | `dio` | عميل HTTP قوي يدعم الـ Interceptors والتعامل المركزي مع الأخطاء |
| **Realtime & Cloud** | `firebase_core`, `cloud_firestore`, `firebase_messaging` | قواعد بيانات الوقت الفعلي، المحادثات، والإشعارات الفورية |
| **Maps & Geo** | `google_maps_flutter`, `geolocator`, `geocoding` | عرض الخرائط، تتبع الموقع، وحساب المسارات |
| **Local Storage** | `flutter_secure_storage`, `shared_preferences`, `hive` | تخزين آمن لـ JWT Tokens والبيانات المحلية والإعدادات |
| **Dependency Injection**| `get_it` | حقن التبعيات كـ Singletons وFactories عبر حاوية مركزية |
| **Internationalization**| `flutter_localizations`, `intl` | تعريب كامل للنصوص بتنسيقات ARB |
| **App Widget** | `home_widget` | ودجة شاشة البداية لنظام Android |

---

## 📁 هيكل المشروع (Project Structure)

```text
lib/
├── core/                         # العناصر المشتركة والأساسية للتطبيق
│   ├── data/                     # نماذج البيانات العامة
│   ├── di/                       # حقن التبعيات (injection_container.dart)
│   ├── error/                    # التعامل مع الأخطاء والاستثناءات (Failures & Exceptions)
│   ├── formatters/               # أدوات تنسيق النصوص والتواريخ
│   ├── network/                  # عميل الشبكة (ApiClient, ApiEndpoints, Interceptors)
│   ├── resources/                # الموارد العامة (Strings, Assets, Styles)
│   ├── router/                   # التوجيه المركزي (AppRouter, AppRoutes)
│   ├── services/                 # خدمات النظام (Location, HomeWidget, Routing)
│   ├── storage/                  # وحدات التخزين المحلية والآمنة (LocalStorage, SecureStorage)
│   ├── theme/                    # الألوان والسمات الموحدة (AppColors, AppTheme)
│   ├── usecases/                 # الواجهة المعيارية للـ UseCase
│   ├── utils/                    # دوال ومساعدات برمجية (BlocObserver, FCMService)
│   └── widgets/                  # المكونات والـ Widgets المشتركة على مستوى التطبيق
│
├── features/                     # ميزات التطبيق (Features Modularity)
│   ├── auth/                     # المصادقة، تسجيل الدخول، إنشاء الحساب، التحقق OTP
│   ├── chat/                     # المحادثة المباشرة بين الراكب والسائق
│   ├── driver_documents/         # رفع وتوثيق مستندات السائق (KYC)
│   ├── home/                     # الشاشات الرئيسية والقوائم للراكب والسائق
│   ├── legal/                    # الشروط والأحكام وسياسة الخصوصية
│   ├── map/                      # خدمات الخرائط، المسارات، والـ Geocoding
│   ├── notifications/            # شاشة وإدارة سجل الإشعارات
│   ├── onboarding/               # شاشات الترحيب والتعريف بالتطبيق
│   ├── ratings/                  # نظام التقييمات والمراجعات
│   ├── settings/                 # إعدادات الحساب، اللغة، والأماكن المحفوظة
│   └── trips/                    # إدارة الرحلات (الخاصة، المشتركة، المجدولة، والتتبع)
│       ├── data/                 # مصادر البيانات والمستودعات ونماذج الـ Trips
│       ├── domain/               # الـ Entities وحالات الاستخدام (UseCases)
│       └── presentation/         # واجهات المستخدم والـ Cubits للراكب والسائق
│
├── generated/                    # الملفات المولدة آلياً للترجمة (intl)
├── l10n/                         # ملفات اللغات (intl_ar.arb, intl_en.arb)
├── firebase_options.dart         # إعدادات منصات Firebase
└── main.dart                     # نقطة انطلاق التطبيق وإعداد الخدمات
```

---

## 🚀 التثبيت والتشغيل

### المتطلبات الأساسية (Prerequisites):
- [Flutter SDK](https://docs.flutter.dev/get-started/install) الإصدار `3.10.0` أو أحدث.
- [Dart SDK](https://dart.dev/get-dart) الإصدار `3.0.0` أو أحدث.
- [Android Studio](https://developer.android.com/studio) أو [VS Code](https://code.visualstudio.com/) مع إضافات Flutter & Dart.
- هاتف فعلي أو محاكي (Emulator) يحتوي على خدمات Google Play لتشغيل الخرائط.

### خطوات الإعداد:

1. **استنساخ المستودع (Clone Repository):**
   ```bash
   git clone <REPOSITORY_URL>
   cd car_app
   ```

2. **تثبيت التبعيات (Install Dependencies):**
   ```bash
   flutter pub get
   ```

3. **إعداد متغيرات البيئة (.env):**
   قم بنسخ ملف النموذج `.env.example` إلى `.env`:
   ```bash
   cp .env.example .env
   ```
   ثم افتح ملف `.env` وضع مفتاح Google Maps API الخاص بك:
   ```env
   GOOGLE_MAPS_API_KEY=YOUR_ACTUAL_GOOGLE_MAPS_API_KEY
   ```

4. **توليد ملفات الترجمة (إذا لزم الأمر):**
   ```bash
   flutter pub run intl_utils:generate
   ```

5. **تشغيل التطبيق في وضع التطوير (Run App):**
   ```bash
   flutter run
   ```

---

## ⚙️ إعداد متغيرات البيئة (.env)

يستخدم التطبيق حزمة `flutter_dotenv` لإدارة المفاتيح الحساسة بأمان بعيداً عن الكود المصدري.

يحتوي ملف `.env` على المتغيرات التالية:

| المتغير | الوصف | إلزامي؟ |
|---|---|:---:|
| `GOOGLE_MAPS_API_KEY` | مفتاح Google Cloud الخاص بـ (Maps SDK, Places API, Directions API) | ✅ نعم |

> ⚠️ **تنبيه هام:** لا تقم برفع ملف `.env` إلى مستودعات Git العامة. تأكد دائماً من وجوده داخل ملف `.gitignore`.

---

## 📐 معايير البرمجة (Coding Guidelines)

المشروع ملتزم بمعايير برمجية صارمة ومحددة في دليل التطوير [`CODING_GUIDELINES.md`](CODING_GUIDELINES.md):

1. **إدارة الحالة (BLoC / Cubit فقط):**
   - يُمنع استخدام `setState` قطعياً.
   - بناء الشاشات يعتمد على `StatelessWidget` وتُدار الحالة عبر `BlocBuilder` أو `BlocConsumer`.
2. **فصل المكونات وإعادة الاستخدام (Clean Widget Extraction):**
   - تقسيم الواجهات الطويلة إلى كلاسات ويدجت مستقلة (`Extract as Widget`).
   - تجنب استخدام دوال مساعدة تعيد ويدجت (مثل `Widget _buildRow()`).
   - حفظ الودجات المخصصة لكل ميزة داخل مجلد `widgets/` الخاص بها، والودجات العامة داخل `core/widgets/`.
3. **عدم كتابة نصوص ثابتة (Strict Localization):**
   - يُمنع وضع نصوص صلبة (Hardcoded Strings) في الواجهة. يتم استدعاء جميع النصوص من نظام التوطين: `S.of(context).key`.
4. **التوجيه التصريحي (Declarative Navigation):**
   - الاعتماد حصرياً على `GoRouter` عبر `context.go()` أو `context.push()` وتفادي `Navigator.push`.
5. **السمات والألوان المركزية (Centralized Theming):**
   - استخدام الألوان والأنماط المعرفة في `AppColors` و`Theme.of(context)` بدلاً من الألوان المباشرة `Colors.red` أو `Color(...)`.

---

## 🔌 الواجهات البرمجية (API Overview)

يتم تنظيم جميع المسارات ونقاط النهاية عبر الكلاس المركزي [`ApiEndpoints`](lib/core/network/api_endpoints.dart):

* **المصادقة (Auth):**
  * `api/login` & `api/register`
  * `api/chack-code-user-ajax` (التحقق من كود الـ OTP)
  * `api/reset-password-request-ajax` (استعادة كلمة المرور)
* **الرحلات (Trips):**
  * `api/trips/nearme` (الرحلات المتاحة في النطاق الجغرافي)
  * `api/trips/create` (إنشاء رحلة جديدة خاصة أو مشتركة)
  * `api/trips/changeStatus/{id}` (تحديث حالة الرحلة)
* **العروض (Offers):**
  * `api/offers/store` (تقديم عرض سعر من السائق)
  * `api/offers/{trip_id}` (استعراض عروض السائقين للرحلة)
  * `api/update-offer-status/{id}` (قبول أو رفض العرض)
* **مستندات السائق (Driver KYC):**
  * `api/driver/documents` (رفع وفحص حالة المستندات)
* **التقييمات والإشعارات (Ratings & Notifications):**
  * `api/ratings/store`
  * `api/get-notification`
  * `api/update-device-token` (تسجيل رمز الـ FCM)

---

## 📦 إنشاء نسخ الإنتاج (Release Builds)

### بناء حزمة أندرويد (APK):
```bash
flutter build apk --release
```

### بناء حزمة متجر جوجل بلاي (App Bundle):
```bash
flutter build appbundle --release
```

---

## 👥 المساهمة والتطوير (Contributing)

1. أنشئ فرعاً جديداً لميزتك: `git checkout -b feature/your-feature-name`
2. التزم بمعايير الكود الموضحة أعلاه وتأكد من فحص الأخطاء: `flutter analyze`
3. قم بعمل Commit لتغييراتك: `git commit -m "feat: add your feature description"`
4. ادفع الفرع: `git push origin feature/your-feature-name`
5. افتح طلب دمج (Pull Request).

---

<div align="center">
  <sub>صنع بإتقان عبر فريق تطوير التطبيق • Car App © 2026</sub>
</div>
