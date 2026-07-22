import '../models/resident_profile.dart';

enum ProfilePhase {
  initial,
  loading,
  loaded,
  refreshing,
  editing,
  saving,
  uploadingPhoto,
  saved,
  offline,
  failure,
}

class ProfileState {
  const ProfileState({
    this.phase = ProfilePhase.initial,
    this.profile,
    this.stale = false,
    this.message,
    this.uploadProgress,
  });
  final ProfilePhase phase;
  final ResidentProfile? profile;
  final bool stale;
  final String? message;
  final double? uploadProgress;
  ProfileState copyWith({
    ProfilePhase? phase,
    ResidentProfile? profile,
    bool? stale,
    String? message,
    double? uploadProgress,
    bool clearMessage = false,
    bool clearProgress = false,
  }) => ProfileState(
    phase: phase ?? this.phase,
    profile: profile ?? this.profile,
    stale: stale ?? this.stale,
    message: clearMessage ? null : message ?? this.message,
    uploadProgress: clearProgress
        ? null
        : uploadProgress ?? this.uploadProgress,
  );
}
