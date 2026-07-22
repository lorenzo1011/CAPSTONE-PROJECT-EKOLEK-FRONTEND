class RewardCategory {
  const RewardCategory(this.name);
  factory RewardCategory.fromJson(Map<String, Object?> json) {
    final value = json['name'];
    if (value is! String || value.trim().isEmpty) throw const FormatException();
    return RewardCategory(value.trim());
  }
  final String name;
}
