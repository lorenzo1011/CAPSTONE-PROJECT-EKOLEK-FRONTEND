class ProfileFieldPermissions {
  const ProfileFieldPermissions({
    required this.canEditPhone,
    required this.canEditPhoto,
  });
  factory ProfileFieldPermissions.fromJson(Object? value) {
    final fields = value is List
        ? value.whereType<String>().toSet()
        : <String>{};
    return ProfileFieldPermissions(
      canEditPhone: fields.contains('phone_number'),
      canEditPhoto: fields.contains('profile_photo'),
    );
  }
  final bool canEditPhone, canEditPhoto;
}
