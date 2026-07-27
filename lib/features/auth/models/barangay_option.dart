class BarangayOption {
  const BarangayOption({
    required this.id,
    required this.name,
    this.districtOrArea,
  });

  factory BarangayOption.fromJson(Map<String, Object?> json) {
    final id = json['id'];
    final name = json['name'];
    if (id is! int || name is! String || name.trim().isEmpty) {
      throw const FormatException('Barangay information is invalid.');
    }
    final area = json['district_or_area'];
    return BarangayOption(
      id: id,
      name: name.trim(),
      districtOrArea: area is String && area.trim().isNotEmpty
          ? area.trim()
          : null,
    );
  }

  final int id;
  final String name;
  final String? districtOrArea;

  String get displayName =>
      districtOrArea == null ? name : '$name • $districtOrArea';
}
