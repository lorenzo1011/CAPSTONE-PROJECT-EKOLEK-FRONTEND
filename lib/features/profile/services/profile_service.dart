import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/auth_request_options.dart';
import '../../../core/errors/app_exception.dart';
import '../models/profile_update_request.dart';
import '../models/profile_update_result.dart';
import '../models/resident_profile.dart';

class ProfileService {
  ProfileService(this._client);
  final ApiClient _client;
  Future<ResidentProfile> getCurrentProfile({CancelToken? cancelToken}) async {
    final r = await _client.get<Object?>(
      ApiEndpoints.profile,
      options: AuthRequestOptions.authenticated(),
      cancelToken: cancelToken,
    );
    return ResidentProfile.fromJson(_data(r.data));
  }

  Future<ProfileUpdateResult> updateProfile(
    ProfileUpdateRequest request, {
    CancelToken? cancelToken,
  }) async {
    final r = await _client.patch<Object?>(
      ApiEndpoints.profile,
      data: request.toJson(),
      options: AuthRequestOptions.authenticated(),
      cancelToken: cancelToken,
    );
    return ProfileUpdateResult(ResidentProfile.fromJson(_data(r.data)));
  }

  Future<ProfileUpdateResult> uploadPhoto(
    String path, {
    CancelToken? cancelToken,
    ProgressCallback? onProgress,
  }) async {
    final file = await MultipartFile.fromFile(path);
    final r = await _client.patch<Object?>(
      ApiEndpoints.profile,
      data: FormData.fromMap({'profile_photo': file}),
      options: AuthRequestOptions.authenticated(),
      cancelToken: cancelToken,
      onSendProgress: onProgress,
    );
    return ProfileUpdateResult(ResidentProfile.fromJson(_data(r.data)));
  }

  Future<ProfileUpdateResult> removePhoto({CancelToken? cancelToken}) async {
    final r = await _client.patch<Object?>(
      ApiEndpoints.profile,
      data: {'profile_photo': null},
      options: AuthRequestOptions.authenticated(),
      cancelToken: cancelToken,
    );
    return ProfileUpdateResult(ResidentProfile.fromJson(_data(r.data)));
  }

  static Map<String, Object?> _data(Object? raw) {
    if (raw is! Map || raw['data'] is! Map) {
      throw const InvalidResponseException();
    }
    return (raw['data'] as Map).map((k, v) => MapEntry(k.toString(), v));
  }
}
