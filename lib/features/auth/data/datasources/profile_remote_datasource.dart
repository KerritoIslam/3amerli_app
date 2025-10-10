import 'dart:convert';

import 'package:amerli_app/core/dio/api_service.dart';
import '../../data/models/user_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserModel> fetchProfile();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiService apiService;

  ProfileRemoteDataSourceImpl({required this.apiService});

  @override
  Future<UserModel> fetchProfile() async {
    // Simulate network latency and return a mocked user
    await Future.delayed(const Duration(seconds: 2));
    const sample = '''{
      "id": 1,
      "phoneNumber": "+201234567890",
      "name": "Ahmed Ali",
      "locationUrl": null,
      "addressId": null,
      "supermarketName": null,
      "profilePic": "https://example.com/avatar.png",
      "role": "customer"
    }''';
    final Map<String, dynamic> json = jsonDecode(sample) as Map<String, dynamic>;
    return UserModel.fromJson(json);
  }
}
