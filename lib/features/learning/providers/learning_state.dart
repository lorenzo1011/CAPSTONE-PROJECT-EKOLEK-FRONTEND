import '../models/learning_video.dart';

enum LearningStatus {
  initial,
  loading,
  loaded,
  refreshing,
  loadingMore,
  offline,
  failure,
}

class LearningState {
  const LearningState({
    this.status = LearningStatus.initial,
    this.videos = const [],
    this.hasNext = false,
    this.message,
    this.isStale = false,
    this.selectedCategory,
    this.searchQuery = '',
  });
  final LearningStatus status;
  final List<LearningVideo> videos;
  final bool hasNext;
  final String? message;
  final bool isStale;
  final String? selectedCategory;
  final String searchQuery;
  List<String> get categories => ({
    for (final video in videos)
      if (video.category.isNotEmpty) video.category,
  }.toList()..sort());

  LearningState copyWith({
    LearningStatus? status,
    List<LearningVideo>? videos,
    bool? hasNext,
    String? message,
    bool clearMessage = false,
    bool? isStale,
    String? selectedCategory,
    bool clearCategory = false,
    String? searchQuery,
  }) => LearningState(
    status: status ?? this.status,
    videos: videos ?? this.videos,
    hasNext: hasNext ?? this.hasNext,
    message: clearMessage ? null : message ?? this.message,
    isStale: isStale ?? this.isStale,
    selectedCategory: clearCategory
        ? null
        : selectedCategory ?? this.selectedCategory,
    searchQuery: searchQuery ?? this.searchQuery,
  );
}
