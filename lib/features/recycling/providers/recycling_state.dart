import '../models/collection_transaction.dart';
import '../models/recyclable_material.dart';

enum RecyclingPhase {
  initial,
  loading,
  loaded,
  refreshing,
  loadingMore,
  offline,
  failure,
}

class RecyclingState {
  const RecyclingState({
    this.phase = RecyclingPhase.initial,
    this.collections = const [],
    this.materials = const [],
    this.hasNext = true,
    this.message,
    this.materialsMessage,
    this.stale = false,
    this.refreshedAt,
  });
  final RecyclingPhase phase;
  final List<CollectionTransaction> collections;
  final List<RecyclableMaterial> materials;
  final bool hasNext, stale;
  final String? message, materialsMessage;
  final DateTime? refreshedAt;
}
