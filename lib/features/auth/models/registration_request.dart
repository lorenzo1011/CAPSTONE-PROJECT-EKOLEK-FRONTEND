class RegistrationRequest {
  const RegistrationRequest({
    required this.email,
    required this.password,
    required this.fullName,
    required this.birthdate,
    required this.barangayId,
    required this.completeAddress,
    this.phoneNumber = '',
    this.profilePhotoPath,
    this.validIdImagePath,
  });

  final String email;
  final String password;
  final String fullName;
  final DateTime birthdate;
  final int barangayId;
  final String completeAddress;
  final String phoneNumber;
  final String? profilePhotoPath;
  final String? validIdImagePath;

  Map<String, Object?> toFields() => {
    'email': email.trim().toLowerCase(),
    'password': password,
    'full_name': fullName.trim(),
    'birthdate':
        '${birthdate.year.toString().padLeft(4, '0')}-'
        '${birthdate.month.toString().padLeft(2, '0')}-'
        '${birthdate.day.toString().padLeft(2, '0')}',
    'barangay': barangayId,
    'complete_address': completeAddress.trim(),
    if (phoneNumber.trim().isNotEmpty) 'phone_number': phoneNumber.trim(),
  };

  @override
  String toString() =>
      'RegistrationRequest(barangayId: $barangayId, '
      'hasProfilePhoto: ${profilePhotoPath != null}, '
      'hasValidId: ${validIdImagePath != null}, credentials: [REDACTED])';
}
