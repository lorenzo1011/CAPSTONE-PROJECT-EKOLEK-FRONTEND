import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ResidentStatusMetadata {
  const ResidentStatusMetadata({
    required this.status,
    required this.verifiedAt,
    required this.welcomeCompleted,
  });
  final String status;
  final DateTime verifiedAt;
  final bool welcomeCompleted;
}

abstract interface class ResidentStatusStorage {
  Future<ResidentStatusMetadata?> read(int userId);
  Future<void> writeStatus(int userId, String status, DateTime verifiedAt);
  Future<void> markWelcomeCompleted(int userId);
  Future<void> clear(int userId);
}

class SecureResidentStatusStorage implements ResidentStatusStorage {
  SecureResidentStatusStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();
  final FlutterSecureStorage _storage;
  String _key(int id, String suffix) => 'ekolek.resident_status.$id.$suffix';

  @override
  Future<ResidentStatusMetadata?> read(int userId) async {
    final status = await _storage.read(key: _key(userId, 'value'));
    final timestamp = DateTime.tryParse(
      await _storage.read(key: _key(userId, 'verified_at')) ?? '',
    );
    if (status == null || timestamp == null) return null;
    return ResidentStatusMetadata(
      status: status,
      verifiedAt: timestamp.toUtc(),
      welcomeCompleted:
          await _storage.read(key: _key(userId, 'welcome_completed')) == 'true',
    );
  }

  @override
  Future<void> writeStatus(
    int userId,
    String status,
    DateTime verifiedAt,
  ) async {
    await _storage.write(key: _key(userId, 'value'), value: status);
    await _storage.write(
      key: _key(userId, 'verified_at'),
      value: verifiedAt.toUtc().toIso8601String(),
    );
  }

  @override
  Future<void> markWelcomeCompleted(int userId) =>
      _storage.write(key: _key(userId, 'welcome_completed'), value: 'true');

  @override
  Future<void> clear(int userId) async {
    await Future.wait([
      _storage.delete(key: _key(userId, 'value')),
      _storage.delete(key: _key(userId, 'verified_at')),
      _storage.delete(key: _key(userId, 'welcome_completed')),
    ]);
  }
}
