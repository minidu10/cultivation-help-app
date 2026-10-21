# AgroMaster Mobile

The Flutter companion to the AgroMaster web app: the same farm records,
built for a phone in the field. It talks to the same Spring Boot API and
uses the same account.

## What it does

- **Sign in** with email and password or Google. Sign-up uses the same three steps as the web: email, a 6-digit code, then your details.
- **Dashboard**: revenue, expenses, net profit and active crops; a revenue vs expenses chart per crop; weather for your town; due and upcoming reminders, each with one-tap "mark done".
- **Crops**: filter by status; add and edit crops; change status in one tap; per-crop profit, AI insight and tabs for expenses, harvests and reminders, all editable.
- **AI advisor**: a chat that sends your crop list as context automatically.
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

## Google Sign-In setup

The app requests ID tokens for the backend's **web** client id, which it reads
from `/api/auth/config`, so nothing is configured in the app itself. Google
still needs to recognise the app:

1. In the same Google Cloud project, create an **Android** OAuth client for package `com.agromaster.app`.
2. Add the SHA-1 of each signing key. For the debug key, run `cd android && ./gradlew signingReport`.
3. Optionally list that client id in the backend's `GOOGLE_MOBILE_CLIENT_IDS`.
