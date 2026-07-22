import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/auth_request_options.dart';
import '../../../core/errors/app_exception.dart';
import '../models/quiz_answer.dart';
import '../models/quiz_detail.dart';
import '../models/quiz_result.dart';

class QuizService {
  QuizService(this._client);
  final ApiClient _client;

  Future<QuizDetail> getQuiz(int quizId, {CancelToken? cancelToken}) async {
    final response = await _client.get<Object?>(
      ApiEndpoints.learningQuiz(quizId),
      options: AuthRequestOptions.authenticated(),
      cancelToken: cancelToken,
    );
    return QuizDetail.fromJson(_data(response.data));
  }

  Future<QuizResult> submitQuiz(
    int quizId,
    List<QuizAnswer> answers, {
    CancelToken? cancelToken,
  }) async {
    final response = await _client.post<Object?>(
      ApiEndpoints.submitLearningQuiz(quizId),
      data: {
        'answers': answers
            .map((answer) => answer.toRequestJson())
            .toList(growable: false),
      },
      options: AuthRequestOptions.authenticated(skipRefresh: true),
      cancelToken: cancelToken,
    );
    return QuizResult.fromJson(_data(response.data));
  }

  static Map<String, Object?> _data(Object? raw) {
    if (raw is! Map || raw['data'] is! Map) {
      throw const InvalidResponseException();
    }
    return (raw['data'] as Map).map(
      (key, value) => MapEntry(key.toString(), value),
    );
  }
}
