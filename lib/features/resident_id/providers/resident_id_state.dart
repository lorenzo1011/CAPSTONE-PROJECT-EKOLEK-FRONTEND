import '../models/digital_resident_id.dart';

enum ResidentIdLoadStatus {
  initial,
  loading,
  loaded,
  refreshing,
  offline,
  failure,
  unavailable,
}

class ResidentIdState {
  const ResidentIdState({
    this.status = ResidentIdLoadStatus.initial,
    this.id,
    this.lastUpdated,
    this.message,
    this.isStale = false,
  });
  final ResidentIdLoadStatus status;
  final DigitalResidentId? id;
  final DateTime? lastUpdated;
  final String? message;
  final bool isStale;
  ResidentIdState copyWith({
    ResidentIdLoadStatus? status,
    DigitalResidentId? id,
    DateTime? lastUpdated,
    String? message,
    bool? isStale,
  }) => ResidentIdState(
    status: status ?? this.status,
    id: id ?? this.id,
    lastUpdated: lastUpdated ?? this.lastUpdated,
    message: message,
    isStale: isStale ?? this.isStale,
  );
}
