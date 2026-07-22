import 'dart:convert';

class JwtUtils {
  JwtUtils._();

  /// Reads expiration metadata only. This does not verify a JWT signature and
  /// must never be used as proof of authorization.
  static DateTime? expiration(String token) {
    try {
      final segments = token.split('.');
      if (segments.length != 3 || segments[1].isEmpty) return null;
      final payloadBytes = base64Url.decode(base64Url.normalize(segments[1]));
      final payload = jsonDecode(utf8.decode(payloadBytes));
      if (payload is! Map) return null;
      final exp = payload['exp'];
      final seconds = switch (exp) {
        int value => value,
        num value => value.toInt(),
        _ => null,
      };
      if (seconds == null || seconds <= 0) return null;
      return DateTime.fromMillisecondsSinceEpoch(
        seconds * Duration.millisecondsPerSecond,
        isUtc: true,
      );
    } on Object {
      return null;
    }
  }
}
