import 'package:amerli_app/core/dio/api_service.dart';
import 'package:amerli_app/core/network/api_exception.dart';
import 'package:amerli_app/core/network/error_message_extractor.dart';
import '../models/notification_model.dart';
import 'package:dio/dio.dart';
import 'dart:developer' as developer;

class NotificationsRemoteDataSource {
  final ApiService apiService;

  NotificationsRemoteDataSource({required this.apiService});

  bool _isSuccess(int? status) =>
      status != null && status >= 200 && status < 300;

  /// GET /notifications
  Future<List<NotificationModel>> fetchNotifications(
      {int page = 1, int pageSize = 50}) async {
    try {
      final resp = await apiService.get('/notifications',
          queryParameters: {'page': page, 'limit': pageSize});
      if (_isSuccess(resp.statusCode) && resp.data != null) {
        final list = resp.data as List<dynamic>;
        return list
            .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw ApiException(
          extractErrorMessage(resp.data, defaultMessage: "network error"),
          statusCode: resp.statusCode,
          serverResponse: resp.data);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final serverResp = e.response?.data;

      developer.log(
          'Dio error fetchNotifications - status: $status, serverResponse: $serverResp',
          name: 'NotificationsRemoteDataSource',
          error: e,
          stackTrace: StackTrace.current,
          level: 1000);
      throw ApiException(
          extractErrorMessage(serverResp, defaultMessage: "network error"),
          statusCode: status,
          isNetworkError: true,
          serverResponse: serverResp);
    }
  }

  /// PATCH /notifications/{id}
  Future<void> markRead(int id) async {
    try {
      final resp = await apiService.client
          .patch('/notifications/$id', data: {'read': true});
      if (_isSuccess(resp.statusCode)) return;
      throw ApiException(
          extractErrorMessage(resp.data, defaultMessage: "network error"),
          statusCode: resp.statusCode,
          serverResponse: resp.data);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final serverResp = e.response?.data;

      developer.log(
          'Dio error markRead - status: $status, serverResponse: $serverResp',
          name: 'NotificationsRemoteDataSource',
          error: e,
          stackTrace: StackTrace.current,
          level: 1000);
      throw ApiException(
          extractErrorMessage(serverResp, defaultMessage: "network error"),
          statusCode: status,
          isNetworkError: true,
          serverResponse: serverResp);
    }
  }

  Future<void> createNotification(Map<String, dynamic> payload) async {
    try {
      final resp = await apiService.post('/notifications', data: payload);
      if (_isSuccess(resp.statusCode)) return;
      throw ApiException(
          extractErrorMessage(resp.data, defaultMessage: "network error"),
          statusCode: resp.statusCode,
          serverResponse: resp.data);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final serverResp = e.response?.data;

      developer.log(
          'Dio error createNotification - status: $status, serverResponse: $serverResp',
          name: 'NotificationsRemoteDataSource',
          error: e,
          stackTrace: StackTrace.current,
          level: 1000);
      throw ApiException(
          extractErrorMessage(serverResp, defaultMessage: "network error"),
          statusCode: status,
          isNetworkError: true,
          serverResponse: serverResp);
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      final resp = await apiService.delete('/notifications/$id');
      if (_isSuccess(resp.statusCode)) return;
      throw ApiException(
          extractErrorMessage(resp.data, defaultMessage: "network error"),
          statusCode: resp.statusCode,
          serverResponse: resp.data);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final serverResp = e.response?.data;

      developer.log(
          'Dio error deleteNotification - status: $status, serverResponse: $serverResp',
          name: 'NotificationsRemoteDataSource',
          error: e,
          stackTrace: StackTrace.current,
          level: 1000);
      throw ApiException(
          extractErrorMessage(serverResp, defaultMessage: "network error"),
          statusCode: status,
          isNetworkError: true,
          serverResponse: serverResp);
    }
  }

  /// PATCH /notifications/read - Mark multiple notifications as read
  Future<void> markMultipleRead(List<int> ids) async {
    try {
      final resp =
          await apiService.patch('/notifications/read', data: {'ids': ids});
      if (_isSuccess(resp.statusCode)) return;
      throw ApiException(
          extractErrorMessage(resp.data, defaultMessage: "network error"),
          statusCode: resp.statusCode,
          serverResponse: resp.data);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final serverResp = e.response?.data;

      developer.log(
          'Dio error markMultipleRead - status: $status, serverResponse: $serverResp',
          name: 'NotificationsRemoteDataSource',
          error: e,
          stackTrace: StackTrace.current,
          level: 1000);
      throw ApiException(
          extractErrorMessage(serverResp, defaultMessage: "network error"),
          statusCode: status,
          isNetworkError: true,
          serverResponse: serverResp);
    }
  }

  /// POST /notifications/register-fcm-token - Register FCM token for current user
  Future<void> registerFcmToken(String token, String os, String lang) async {
    try {
      final resp =
          await apiService.post('/notifications/register-fcm-token', data: {
        'fcmToken': token,
        'os': os, // "android" or "ios"
        'lang': lang,
      });
      if (_isSuccess(resp.statusCode)) return;
      throw ApiException(
          extractErrorMessage(resp.data, defaultMessage: "network error"),
          statusCode: resp.statusCode,
          serverResponse: resp.data);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final serverResp = e.response?.data;

      developer.log(
          'Dio error registerFcmToken - status: $status, serverResponse: $serverResp',
          name: 'NotificationsRemoteDataSource',
          error: e,
          stackTrace: StackTrace.current,
          level: 1000);
      throw ApiException(
          extractErrorMessage(serverResp, defaultMessage: "network error"),
          statusCode: status,
          isNetworkError: true,
          serverResponse: serverResp);
    }
  }

  /// PATCH /notifications/language - Update notification language
  Future<void> updateLanguage(String fcmToken, String language) async {
    try {
      final resp = await apiService.patch('/notifications/language', data: {
        'fcmToken': fcmToken,
        'language': language,
      });
      if (_isSuccess(resp.statusCode)) return;
      throw ApiException(
          extractErrorMessage(resp.data, defaultMessage: "network error"),
          statusCode: resp.statusCode,
          serverResponse: resp.data);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final serverResp = e.response?.data;

      developer.log(
          'Dio error updateLanguage - status: $status, serverResponse: $serverResp',
          name: 'NotificationsRemoteDataSource',
          error: e,
          stackTrace: StackTrace.current,
          level: 1000);
      throw ApiException(
          extractErrorMessage(serverResp, defaultMessage: "network error"),
          statusCode: status,
          isNetworkError: true,
          serverResponse: serverResp);
    }
  }
}
