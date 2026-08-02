# Black Fury 🐉 — Smart Motorcycle Control System

Toothless / Night Fury themed Flutter app for monitoring and controlling a
smart motorcycle over Firebase Realtime Database.

## 1. Project setup

```bash
flutter create --org com.blackfury --project-name black_fury .
# (only needed if you're regenerating native android/ios folders;
#  this repo assumes those folders already exist from `flutter create`)
flutter pub get
```

## 2. Set the Android package name (only needed for local builds)

> Skip this section if you're building via GitHub Actions (see step 6b) —
> the workflow sets the package name automatically.

In `android/app/build.gradle`, set:

```gradle
android {
    namespace "com.blackfury.vehiclecontrol"
    defaultConfig {
        applicationId "com.blackfury.vehiclecontrol"
        ...
    }
}
```

And update `android/app/src/main/AndroidManifest.xml` `package` attribute
(or the Kotlin/Java source folder path) to match
`com.blackfury.vehiclecontrol`.

Required permissions in `AndroidManifest.xml` (inside `<manifest>`, above
`<application>`):

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

## 3. App icon (Toothless face)

A stylized Toothless-face icon (1024×1024 PNG — black rounded head, ear
fins, glowing slit-pupil green eyes on the `#0B0E14` background) is already
included at `assets/icon/toothless_icon.png`. Swap it for your own artwork
any time by replacing that file with another 1024×1024 PNG.

Generate the launcher icons from it:

```bash
flutter pub get
flutter pub run flutter_launcher_icons
```

This uses the `flutter_launcher_icons` config already declared in
`pubspec.yaml` (dark background `#0B0E14`, adaptive icon foreground =
the Toothless artwork).

## 4. Firebase Realtime Database

All Firebase config lives in `lib/config/app_config.dart`:

- Base URL: `https://black-fury-4bdc5-default-rtdb.firebaseio.com`
- REST auth key + endpoints for `/vehicle/data.json`, `/vehicle/is_thief.json`,
  `/vehicle/appControlRelay.json`

No Firebase SDK is used — all communication is plain REST via the `http`
package, matching your existing backend/hardware contract.

**⚠️ Security note:** a REST `auth` key embedded in a mobile client is
extractable from the compiled APK. Before shipping to real users, lock
down your Realtime Database **Security Rules** so this key alone can't be
used to arbitrarily unlock someone else's bike, and consider rotating the
key if it's ever been pushed to a public git repo.

## 5. Run in debug

```bash
flutter run
```

## 6. Build the release APK

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

For a smaller multi-ABI split build:

```bash
flutter build apk --release --split-per-abi
```

## 6b. Build the APK via GitHub (no local Flutter install needed)

This repo includes `.github/workflows/build-apk.yml`, which builds the
release APK automatically on GitHub's servers.

1. Push this project to a new GitHub repository.
2. Go to the repo's **Actions** tab → the "Build Black Fury APK" workflow
   runs automatically on every push to `main` (or click **Run workflow**
   to trigger it manually).
3. Wait for the run to finish (a few minutes) — a green check means success.
4. Open the finished run → scroll down to **Artifacts** → download
   `black-fury-apk`. Unzip it to get `app-release.apk`.
5. Transfer that APK to an Android phone and install it (enable
   "Install unknown apps" for your file manager/browser first).

The workflow scaffolds the `android/` platform folder, sets the package
name to `com.blackfury.vehiclecontrol`, generates the Toothless launcher
icon, and runs `flutter build apk --release` — all on GitHub's infrastructure.

## Project structure

```
lib/
  config/app_config.dart          # Firebase URLs, auth key, tunables
  theme/app_theme.dart            # Night Fury color system + ThemeData
  models/vehicle_data.dart        # fuel/lat/lng/trip parsing
  services/firebase_service.dart  # polling, relay PUT, thief flag GET/clear
  screens/splash_screen.dart      # Toothless eye-opening animation
  screens/dashboard_screen.dart   # main dashboard, wires streams to UI
  widgets/toothless_eyes_painter.dart
  widgets/glass_card.dart
  widgets/status_badge.dart
  widgets/ignition_toggle.dart
  widgets/fuel_gauge.dart
  widgets/trip_metrics_grid.dart
  widgets/gps_tracker_card.dart
  widgets/thief_alert_dialog.dart
```

## Feature notes

- **Polling:** `FirebaseService.startPolling()` runs a `Timer.periodic`
  every 3 seconds (configurable in `AppConfig.pollInterval`), fetching
  both `/vehicle/data.json` and `/vehicle/is_thief.json` in parallel.
- **Thief alert:** when `is_thief == 1`, an un-dismissible (`PopScope(canPop:
  false)`, `barrierDismissible: false`) flashing red dialog appears. The
  user must tap "Acknowledge & Secure Vehicle", which calls the service to
  reset the flag to `0` on the backend.
- **Relay control:** the ignition switch sends a `PUT` of `1` (lock) or `0`
  (unlock) to `appControlRelay.json`. UI shows a spinner while in flight and
  only flips state locally after a `200` response.
- **Fuel/range:** circular gauge color shifts crimson → cyan → green as
  fuel rises; estimated range uses `AppConfig.tankCapacityLiters` and
  `AppConfig.kmPerLiter` — adjust these to your bike's real specs.
- **Maps:** "TRACK BIKE ON GOOGLE MAPS" opens
  `https://www.google.com/maps/search/?api=1&query=$lat,$lng` via
  `url_launcher` with `LaunchMode.externalApplication`.
- **Persistent Toothless background:** `widgets/dragon_background.dart`
  paints a faint dragon-scale texture plus a low-opacity Toothless head/ear
  silhouette watermark behind every screen. Both the splash screen and the
  dashboard wrap their content in `DragonBackground`, so the theme is
  consistent app-wide, not just on the splash. On the splash screen the
  silhouette opacity is tied to the eye-opening animation, so the dragon's
  head visually "emerges" from the dark alongside its eyes.
