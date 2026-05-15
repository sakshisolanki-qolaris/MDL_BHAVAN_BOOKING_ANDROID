// lib/services/auth_service.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../models/user_model.dart';
import '../models/api_response.dart';

class AuthService {
  final ApiClient _apiClient;
  final FlutterSecureStorage _storage;

  AuthService(this._apiClient, this._storage);

  /// Single portal login that attempts Admin, then Clerk, then User endpoints.
  Future<ApiResponse<UserModel>> login(String mobile, String password) async {
    // 1. Attempt Admin Login First
    var response = await _attemptLogin('/auth/admin/login', mobile, password, 'ADMIN');
    if (response.success) return response;

    // 2. Fallback to Clerk Login
    response = await _attemptLogin('/auth/admin/clerk/login', mobile, password, 'CLERK');
    if (response.success) return response;

    // 3. Fallback to Standard User Login
    response = await _attemptLogin('/auth/user/login', mobile, password, 'USER');
    return response;
  }

  // Private helper method to handle the API calls
  Future<ApiResponse<UserModel>> _attemptLogin(String endpoint, String mobile, String password, String expectedRole) async {
    try {
      final response = await _apiClient.dio.post(endpoint, data: {
        'mobile': mobile,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = response.data['data'];
        final token = data['token'];
        final user = UserModel.fromJson(data['user'] ?? {});
        final role = user.role.isNotEmpty ? user.role : expectedRole;

        if (token != null) {
          await _storage.write(key: 'jwt_token', value: token);
          await _storage.write(key: 'user_role', value: role);

          return ApiResponse(
            success: true,
            message: response.data['message'] ?? 'Login Successful',
            data: user,
          );
        }
      }
      return ApiResponse(success: false, message: 'Token missing in response');
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? e.message ?? 'Unknown error';
      return ApiResponse(success: false, message: errorMessage);
    } catch (e) {
      return ApiResponse(success: false, message: 'App Error: $e');
    }
  }

  Future<ApiResponse<void>> register({
    required String name,
    required String mobile,
    required String password,
    String? email,
  }) async {
    try {
      final response = await _apiClient.dio.post('/auth/user/register', data: {
        'fullName': name,
        'mobile': mobile,
        'password': password,
        if (email != null && email.isNotEmpty) 'email': email,
      });

      if (response.statusCode == 201) {
        return ApiResponse(success: true, message: 'Registration Successful');
      }
      return ApiResponse(success: false, message: 'Registration failed');
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? e.message ?? 'Unknown error';
      return ApiResponse(success: false, message: errorMessage);
    } catch (e) {
      return ApiResponse(success: false, message: 'App Error: $e');
    }
  }

  Future<String?> getToken() async => await _storage.read(key: 'jwt_token');
  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
    await _storage.delete(key: 'user_role');
  }
}