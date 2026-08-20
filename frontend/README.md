# SmartSpot (Flutter)

Rebuilt Flutter frontend for SmartSpot, wired to local SQLite (offline-first)
and the SmartSpot backend API for account sync.

## Why this is a rebuild, not an edit

The APK you provided is a compiled binary — Flutter apps are compiled ahead-of-time into
native code (`libapp.so`), so there was no editable Dart source inside it to modify directly.
What *was* recoverable from the compiled binary was the app's structure: package name
(`smartspot`), its screens, providers, and services. This project rebuilds that structure
from scratch as real, editable source code, styled to match what a location-reminder app like
this needs, ready for you (or me) to keep extending.

## Setup

```bash
flutter pub get
```

Then point the app at your backend. Edit `lib/services/api_service.dart`:

```dart
static const String baseUrl = 'http://10.0.2.2:3000/api'; // Android emulator -> localhost
```

- **Android emulator**: use `10.0.2.2` to reach your machine's `localhost`.
- **Physical device**: use your machine's LAN IP (e.g. `http://192.168.1.20:3000/api`), both
  devices on the same network, or deploy the backend and use its public URL.
- **Production**: use your deployed backend's HTTPS URL.

Run it:

```bash
flutter run
```

## Architecture

- **Local-first**: `DatabaseService` (sqflite) is the source of truth the UI reads from —
  the app works fully offline.
- **Sync**: `SyncService` pushes locally-dirty rows to the backend and pulls server state
  back down. Runs on login, app start, and pull-to-refresh on the home screen.
- **Auth**: JWT stored in `flutter_secure_storage` (encrypted keystore/keychain, not plain
  SharedPreferences — important since this holds an auth token).
- **Maps**: uses `flutter_map` (OpenStreetMap tiles) instead of Google Maps, so there's no
  Google Maps API key/billing setup required to get running. Swappable for
  `google_maps_flutter` later if you want Google's styling — that needs an API key and
  billing enabled in Google Cloud Console.

## What's implemented vs. stubbed

**Implemented**: splash → onboarding → login/register/forgot-password → home (active
reminders) → add reminder → reminder details (complete/archive/delete) → map (shows
reminder pins + user location) → favorites (add/remove) → insights (status breakdown chart)
→ settings → completed/archived lists → full local SQLite storage → full backend sync.

**Stubbed / needs your input to finish**:
- **Geofencing** (the actual "notify me when I arrive/leave" trigger): `location_service.dart`
  has a position stream, but real background geofencing that works when the app is killed
  needs a dedicated plugin (`geofence_service` or native `WorkManager`/`Region Monitoring`)
  — this is the single most important piece left, and it's genuinely fiddly to get right on
  both Android and iOS, so it deserves its own focused pass.
- **Push/local notifications**: no `flutter_local_notifications` wiring yet — needed to
  actually alert the user when a geofence trigger fires.
- **Picking a location on the map** for a new reminder (add_reminder_screen currently saves
  without lat/lng — tap-to-pick on the map screen needs to be connected).
- **Voice input** (`voice_parser_service.dart` was referenced in your original APK) —
  not rebuilt; tell me if you want speech-to-text reminder creation added.
- App icon, splash branding, and Play Store assets (screenshots, feature graphic,
  privacy policy page) — needed before Play Store submission, see below.

## Before submitting to Google Play

1. Fill in real app icons (`flutter_launcher_icons` package makes this easy).
2. Add a **privacy policy** — required by Play Store, especially since this app uses
   location data. Must disclose what you collect and why.
3. Request Android's `ACCESS_BACKGROUND_LOCATION` permission properly — Play Store review
   is strict about this; you'll need a clear in-app explanation screen before the
   permission prompt (add this screen before submitting).
4. Build a signed release bundle:
   ```bash
   flutter build appbundle --release
   ```
5. Set up a Play Console listing, screenshots, and content rating questionnaire.

I can help with any of these next — happy to build out geofencing + notifications next
since that's the core feature that makes the reminders actually useful.
