# API and authentication foundation

The Resident App uses one Riverpod-managed Dio client configured by `AppConfig`.
The backend contract currently confirms `/api/auth/` and `/api/mobile/` groups.
The verified SimpleJWT refresh path relative to the API base URL is
`auth/token/refresh/`.

Protected requests must explicitly use `AuthRequestOptions.authenticated()`.
Public authentication requests use `AuthRequestOptions.public()` and never
receive an Authorization header. Bearer tokens are attached only when the
request origin and API path match the configured trusted base URL.

Concurrent 401 responses share one refresh operation. The backend rotates
refresh tokens and blacklists the previous refresh token, so both returned
`access` and `refresh` values are saved atomically. Safe GET, HEAD and OPTIONS
requests can be replayed once. Multipart, stream and non-idempotent requests are
never replayed automatically.

Definitively rejected refresh tokens clear the local session and emit one safe
session-expired event. Networking code performs no navigation or UI work.

Development logging records sanitized request metadata only. Authorization,
access and refresh tokens, passwords, resident images and multipart bytes are
always rendered as `[REDACTED]` or omitted. Logging is disabled in production.

The backend currently exposes no API logout, blacklist, or token-verify route.
Logout therefore clears local secure storage only; no route is assumed.

## Verified resident authentication contract

- Login: `auth/login/` with JSON fields `email` and `password`
- Login tokens: `data.tokens.access` and `data.tokens.refresh`
- Current session: `auth/me/` with `data.user` and optional `data.resident`
- Resident authorization requires user role `RESIDENT`
- Full application access requires resident `approval_status` of `APPROVED`

`PENDING`, `REJECTED`, `SUSPENDED`, missing, and unsupported resident statuses
remain outside the main application shell. No server logout call is made because
the backend does not currently publish one.
