# Secure authentication storage

JWTs are stored only through `TokenStorage` and its `SecureTokenStorage`
implementation backed by `flutter_secure_storage`. The implementation stores:

- Access token
- Rotating refresh token
- Access expiration timestamp in UTC ISO-8601 format
- Refresh expiration timestamp in UTC ISO-8601 format

It intentionally does not store passwords, resident profiles, barangay data,
IDs, images, or backend credentials. JWTs must never be stored in ordinary
SharedPreferences, logs, UI models, crash messages, or source control.

Incomplete or corrupted token pairs are cleared. Logout and definitive refresh
rejection clear all namespaced token keys and in-memory session state. Platform
secure-storage defaults use the supported OS credential storage; platform
backup/keychain policy should be reviewed again when release signing and final
deployment targets are configured.
