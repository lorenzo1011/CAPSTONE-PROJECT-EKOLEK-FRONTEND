enum UserRole {
  resident('RESIDENT'),
  superAdmin('SUPER_ADMIN'),
  operationsAdmin('OPERATIONS_ADMIN'),
  contentRewardsAdmin('CONTENT_REWARDS_ADMIN'),
  unknown('UNKNOWN');

  const UserRole(this.value);
  final String value;

  static UserRole fromJson(Object? value) => UserRole.values.firstWhere(
    (role) => role.value == value,
    orElse: () => UserRole.unknown,
  );
}

enum ResidentApprovalStatus {
  pending('PENDING'),
  approved('APPROVED'),
  rejected('REJECTED'),
  suspended('SUSPENDED'),
  unknown('UNKNOWN');

  const ResidentApprovalStatus(this.value);
  final String value;

  static ResidentApprovalStatus fromJson(Object? value) =>
      ResidentApprovalStatus.values.firstWhere(
        (status) => status.value == value,
        orElse: () => ResidentApprovalStatus.unknown,
      );
}

class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.role,
    required this.approvalStatus,
    this.fullName,
    this.residentProfileId,
    this.rejectionReason,
  });

  factory AuthUser.fromCurrentUserData(Map<String, Object?> data) {
    final user = _map(data['user']);
    if (user == null) {
      throw const FormatException('Current-user response has no user object.');
    }
    final id = user['id'];
    final email = user['email'];
    if (id is! int || email is! String || email.trim().isEmpty) {
      throw const FormatException('Current-user identity is invalid.');
    }
    final role = UserRole.fromJson(user['role']);
    final resident = _map(data['resident']);
    return AuthUser(
      id: id,
      email: email,
      role: role,
      approvalStatus: ResidentApprovalStatus.fromJson(
        resident?['approval_status'],
      ),
      fullName: resident?['full_name'] is String
          ? resident!['full_name']! as String
          : null,
      residentProfileId: resident?['id'] is int
          ? resident!['id']! as int
          : null,
      rejectionReason:
          resident?['rejection_reason'] is String &&
              (resident!['rejection_reason']! as String).trim().isNotEmpty
          ? resident['rejection_reason']! as String
          : null,
    );
  }

  final int id;
  final String email;
  final String? fullName;
  final UserRole role;
  final ResidentApprovalStatus approvalStatus;
  final int? residentProfileId;
  final String? rejectionReason;

  bool get isApprovedResident =>
      role == UserRole.resident &&
      approvalStatus == ResidentApprovalStatus.approved;

  AuthUser copyWith({
    ResidentApprovalStatus? approvalStatus,
    String? fullName,
    int? residentProfileId,
    String? rejectionReason,
    bool clearRejectionReason = false,
  }) => AuthUser(
    id: id,
    email: email,
    role: role,
    approvalStatus: approvalStatus ?? this.approvalStatus,
    fullName: fullName ?? this.fullName,
    residentProfileId: residentProfileId ?? this.residentProfileId,
    rejectionReason: clearRejectionReason
        ? null
        : rejectionReason ?? this.rejectionReason,
  );

  static Map<String, Object?>? _map(Object? value) {
    if (value is! Map) return null;
    return value.map((key, item) => MapEntry(key.toString(), item));
  }

  @override
  String toString() =>
      'AuthUser(id: $id, role: ${role.value}, '
      'approvalStatus: ${approvalStatus.value})';
}
