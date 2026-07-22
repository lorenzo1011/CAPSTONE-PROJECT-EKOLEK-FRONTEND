# E-KOLEK Resident App

Flutter Resident App for the E-KOLEK recycling incentive and environmental
engagement platform.

## API environment configuration

Configuration uses compile-time Dart environment values. No `.env` package or
runtime secret file is used.

Android emulator development:

```powershell
flutter run --dart-define=APP_ENV=development --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/
```

Android emulators use `10.0.2.2` to reach a backend running on the development
computer. An iOS simulator can commonly use `127.0.0.1` for a local backend.

A physical device must use the development computer's reachable LAN IP, for
example:

```powershell
flutter run --dart-define=APP_ENV=development --dart-define=API_BASE_URL=http://192.168.1.11:8000/api/
```

The example LAN address is not a permanent project value. Replace it with the
computer's current LAN IP and configure Django's development host access.

Production must use HTTPS:

```powershell
flutter build apk --release --dart-define=APP_ENV=production --dart-define=API_BASE_URL=https://example.com/api/
```

Never store Django `SECRET_KEY`, database credentials, Cloudinary API secrets,
email passwords, signing passwords, or JWTs in the Flutter application.

## Current status

Phase 1 includes the Material 3 design system, splash and adaptive five-tab
navigation, compile-time API configuration, a reusable Dio client, centralized
safe error handling, redacted development logging, connectivity monitoring and
app-level offline feedback.

The secure JWT foundation now stores tokens with platform secure storage,
attaches Bearer credentials only to explicitly protected trusted API requests,
coordinates token rotation through a single refresh operation, and prevents
automatic replay of multipart and non-idempotent requests. The verified Django
refresh path is `auth/token/refresh/` relative to the configured `/api/` base:

```powershell
flutter run --dart-define=APP_ENV=development --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/ --dart-define=AUTH_REFRESH_PATH=auth/token/refresh/
```

The refresh path has a verified development default, so the define is optional.
Never put access tokens, refresh tokens, passwords, Django secrets, or other
credentials in `--dart-define`, source files, logs, or commits.

## Resident authentication flow

The animated Splash Screen now restores secure tokens and verifies the current
account through the backend before protected content is shown:

- No or expired session → Login
- Approved `RESIDENT` → Home and the five-tab application shell
- Pending, rejected, suspended, or unknown resident status → Account Status
- Non-resident role → local session cleared and access denied

Login uses the verified `auth/login/` endpoint with `email` and `password`, then
verifies the resident through `auth/me/`. Sign out is currently local-only
because the backend exposes no API logout or blacklist route. Resident signup
and password recovery are intentionally deferred.
