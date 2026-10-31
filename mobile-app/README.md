# AgroMaster Mobile

The Flutter companion to the AgroMaster web app: the same farm records,
built for a phone in the field. It talks to the same Spring Boot API and
uses the same account.

## What it does

- **Sign in** with email and password or Google. Sign-up uses the same three steps as the web: email, a 6-digit code, then your details.
- **Dashboard**: revenue, expenses, net profit and active crops; a revenue vs expenses chart per crop; weather for your town; due and upcoming reminders, each with one-tap "mark done".
- **Crops**: filter by status; add and edit crops; change status in one tap; per-crop profit, AI insight and tabs for expenses, harvests and reminders, all editable.
- **AI advisor**: a chat that sends your crop list as context automatically.
- **Crop doctor**: the centre camera button checks a photo of a sick leaf; each crop keeps its history in a Health tab.
- **Weather alerts**: tasks the forecast puts at risk, with one-tap rescheduling.
- **Works offline**: screens show what was last loaded, and expenses and harvests saved with no signal are sent once it returns.
- **Push notifications** (optional): the daily reminder digest on the phone; tapping it opens the crop.
- **Settings**: theme (follows the web choice), reminder emails, change password, sign out, and delete account.

## Architecture

```
lib/
├── core/                  # shared by every feature
│   ├── api/               # AuthInterceptor, ApiException, request helpers
│   ├── session/           # SessionController: who is signed in
│   ├── storage/           # TokenStore (Keystore/Keychain via secure storage)
│   ├── router/            # go_router, redirects driven by the session
│   ├── theme/ format/ widgets/ json/
│   └── providers.dart     # Dio clients, storage
├── features/<feature>/
│   ├── data/              # freezed models + a repository per API area
│   └── presentation/      # screens and widgets
└── l10n/app_en.arb        # every user-facing string
```

| Concern | Choice |
|---|---|
| State | Riverpod (`FutureProvider` per resource, invalidated after writes) |
| Navigation | go_router `StatefulShellRoute`: each tab keeps its own stack |
| HTTP | Dio with a queued auth interceptor |
| Models | freezed + json_serializable (generated files are committed) |
| Tokens | flutter_secure_storage, never SharedPreferences |
| Charts | fl_chart |
| Strings | gen-l10n ARB files, English now; Sinhala and Tamil planned |

### Engineering notes

| Decision | Reasoning |
|---|---|
| **One refresh for many 401s** | Refresh tokens are single-use, and the server treats a second use as theft and revokes the session. When the access token expires, every in-flight request fails together. A `QueuedInterceptor` handles them one at a time: the first refreshes, and the rest see the newer token and just retry |
| **Retries bypass the queued interceptor** | Retrying through the same queued interceptor deadlocks if the retry also fails, because its error waits behind the one waiting for it |
| **Network errors keep the session** | Only a 401/403 from `/auth/refresh` ends the session. A dropped connection in a paddy field is not proof the session is over |
| **Tokens read before the first frame** | `main()` checks secure storage first, so a signed-in farmer opens straight onto the dashboard with no login-screen flash |
| **Farm-local times, no zones** | The API stores reminder times as Sri Lanka local time without an offset. The app parses and sends them as local time; converting through UTC would move a 7 AM reminder by 5½ hours |
| **Strings in ARB from day one** | Every label is in `app_en.arb`, so adding Sinhala and Tamil is new files, not a rewrite |
| **Offline reads in one interceptor** | Every successful GET is saved; a GET that gets no reply is answered from that copy and the app shows an offline banner. No screen has offline-specific code. A real error from the server (404, 403) is never hidden behind a cached answer |
| **Offline writes are idempotent** | A new expense or harvest carries a UUID made on the phone. Saved offline, it waits in a persistent outbox and is sent in order when the network, or the app, comes back. The server keeps one row per (crop, UUID), so a resend after a lost reply cannot duplicate it |
| **Firebase from build settings** | Firebase is initialised from `--dart-define` values, not a committed google-services.json, so the repo carries no project config and builds without one (push simply off) |
| **Photos upright before upload** | Photos are shrunk with flutter_image_compress, which rotates the pixels; image_picker's own resizing keeps an EXIF rotation tag the server strips, which turned portrait photos sideways |

## Running it

Prerequisites: Flutter 3.41+, an Android emulator or device, and the backend
running (`docker compose up -d` at the repo root).

```bash
cd mobile-app
flutter pub get
flutter run                     # emulator → local backend at 10.0.2.2:8080
```

Point it at another server with `--dart-define`:

```bash
flutter run --dart-define=API_BASE_URL=https://agromaster.duckdns.org/api
flutter build apk --release --dart-define=API_BASE_URL=https://agromaster.duckdns.org/api
```

Debug builds allow plain HTTP so they can reach the local backend. Release
builds refuse it, so the production URL must be HTTPS.

After changing a model, regenerate the code:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Tests

```bash
flutter analyze
flutter test
```

- `test/core/auth_interceptor_test.dart` runs the interceptor against a fake backend that, like the real one, accepts each refresh token once. That proves concurrent expiries cause exactly one refresh.
- `test/features/` holds widget tests for sign-in, the three-step sign-up and the crop list.
- `test/data/` covers model parsing (including unknown enum values from a newer server) and request bodies.

## Push notifications setup

Optional. Without it the app works fully, minus notifications.

1. Create a project at [console.firebase.google.com](https://console.firebase.google.com) and add an **Android app** with package `com.agromaster.app`.
2. From the app's settings, note the **API key**, **App ID**, **Project number** (sender ID) and **Project ID**, and build with them:

   ```bash
   flutter build apk --dart-define=FIREBASE_API_KEY=... --dart-define=FIREBASE_APP_ID=... \
     --dart-define=FIREBASE_SENDER_ID=... --dart-define=FIREBASE_PROJECT_ID=...
   ```

3. For the backend, go to **Project settings → Service accounts → Generate new private key**. Put the JSON (on one line, or a path to the file) in the backend's `FIREBASE_CREDENTIALS`.
4. In the app, go to **More → Send a test notification**.

## Google Sign-In setup

The app requests ID tokens for the backend's **web** client id, which it reads
from `/api/auth/config`, so nothing is configured in the app itself. Google
still needs to recognise the app:

1. In the same Google Cloud project, create an **Android** OAuth client for package `com.agromaster.app`.
2. Add the SHA-1 of each signing key. For the debug key, run `cd android && ./gradlew signingReport`.
3. Optionally list that client id in the backend's `GOOGLE_MOBILE_CLIENT_IDS`.
