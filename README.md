# SmartSpot — Full Project (Frontend + Backend + Database)

This folder has everything: the Android app, the backend server, and the database setup.

```
SmartSpot/
├── frontend/     ← the Flutter app. THIS is what you open in Android Studio.
└── backend/      ← the Node.js server + SQLite database. Runs via Android Studio's Terminal tab.
```

## 1. Open it in Android Studio

1. Make sure Android Studio has the **Flutter** and **Dart** plugins installed
   (`Settings → Plugins → search "Flutter" → Install`, restart if prompted).
2. `File → Open` → select the **`frontend`** folder (not the top-level `SmartSpot` folder —
   Android Studio's Flutter support expects to open the Flutter project root directly).
3. Let it index, then click **Pub get** (or run `flutter pub get` in the Terminal tab at the
   bottom of the window) to download dependencies.
4. Pick a device/emulator from the device dropdown and hit **Run ▶**.

## 2. Start the backend + database

The Android app needs the backend running to log in, register, and sync data.

1. In Android Studio, open the **Terminal** tab (bottom of the window).
2. Run:
   ```bash
   cd ../backend
   npm install
   npm start
   ```
3. You should see `SmartSpot API listening on port 3000`. The SQLite database file
   (`backend/db/smartspot.db`) is created automatically on first run — no separate database
   install needed.

Leave this running in the terminal while you use the app.

## 3. Point the app at the backend

Already set up for the Android emulator by default. In `frontend/lib/services/api_service.dart`:

```dart
static const String baseUrl = 'http://10.0.2.2:3000/api';
```

- **Android emulator** (default): `10.0.2.2` correctly reaches your machine's `localhost` —
  no change needed.
- **Physical phone over USB/WiFi**: change this to your computer's LAN IP, e.g.
  `http://192.168.1.20:3000/api` (find it with `ipconfig` on Windows or `ifconfig`/`ip a` on
  Mac/Linux), and make sure the phone and computer are on the same network.

## Order to run things

1. Start the backend first (`backend` folder, `npm start`).
2. Then run the app from Android Studio (`frontend` folder, Run ▶).

If you skip step 1, the app still works for browsing (local SQLite keeps it usable offline),
but login/register/sync will fail until the backend is running.

## More detail

- `frontend/README.md` — Flutter app architecture, what's built vs. still stubbed
  (geofencing, notifications, etc.), and Play Store submission checklist.
- `backend/README.md` — API endpoint reference, production hardening checklist, and
  deployment steps for when you're ready to put the backend on a real server instead of
  your own machine.
