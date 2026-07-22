class ProfileUpdateRequest {
  const ProfileUpdateRequest({required this.phoneNumber});
  final String phoneNumber;
  Map<String, Object?> toJson() => {'phone_number': phoneNumber.trim()};
  @override
  String toString() =>
      'ProfileUpdateRequest(hasPhone: ${phoneNumber.trim().isNotEmpty})';
}
