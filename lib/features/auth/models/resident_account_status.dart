enum ResidentAccountStatus {
  pending,
  approved,
  rejected,
  suspended,
  unknown;

  factory ResidentAccountStatus.fromBackend(Object? value) => switch (value) {
    'PENDING' => pending,
    'APPROVED' => approved,
    'REJECTED' => rejected,
    'SUSPENDED' => suspended,
    _ => unknown,
  };

  String get backendValue => switch (this) {
    pending => 'PENDING',
    approved => 'APPROVED',
    rejected => 'REJECTED',
    suspended => 'SUSPENDED',
    unknown => 'UNKNOWN',
  };

  bool get isApproved => this == approved;
  bool get isPending => this == pending;
  bool get isRejected => this == rejected;
  bool get isSuspended => this == suspended;
  bool get canAccessResidentApp => isApproved;
}
