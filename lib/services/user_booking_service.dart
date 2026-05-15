// lib/services/user_booking_service.dart
import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../models/booking_model.dart';
import '../models/api_response.dart';

class UserBookingService {
  final ApiClient _apiClient;

  UserBookingService(this._apiClient);

  Future<ApiResponse<List<BookingModel>>> getMyBookings() async {
    try {
      final response = await _apiClient.dio.get('/bookings/my-bookings');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        final bookings = data.map((item) => BookingModel.fromJson(item)).toList();
        return ApiResponse(success: true, message: 'Bookings loaded', data: bookings);
      }
      return ApiResponse(success: false, message: 'Failed to load bookings.');
    } on DioException catch (e) {
      return ApiResponse(success: false, message: e.response?.data['message'] ?? e.message ?? 'Unknown error');
    } catch (e) {
      return ApiResponse(success: false, message: 'App Error: $e');
    }
  }

  Future<ApiResponse<void>> uploadAadhaar(String bookingId, String frontPath, String backPath) async {
    try {
      FormData formData = FormData.fromMap({
        'frontImage': await MultipartFile.fromFile(frontPath, filename: 'front.jpg'),
        'backImage': await MultipartFile.fromFile(backPath, filename: 'back.jpg'),
      });

      final response = await _apiClient.dio.post(
        '/bookings/$bookingId/upload-aadhaar',
        data: formData,
      );

      if (response.statusCode == 200) {
        return ApiResponse(success: true, message: 'Aadhaar uploaded successfully');
      }
      return ApiResponse(success: false, message: 'Upload failed.');
    } on DioException catch (e) {
      return ApiResponse(success: false, message: e.response?.data['message'] ?? e.message ?? 'Unknown error');
    } catch (e) {
      return ApiResponse(success: false, message: 'App Error: $e');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> createPaymentOrder(String bookingId, String phase, {String paymentOption = 'FULL'}) async {
    try {
      final url = phase == 'INITIAL' ? '/payments/initial/create-order' : '/payments/remaining/create-order';
      final payload = phase == 'INITIAL' ? {'bookingId': bookingId, 'paymentOption': paymentOption} : {'bookingId': bookingId};

      final response = await _apiClient.dio.post(url, data: payload);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse(success: true, message: 'Order created', data: response.data['data']);
      }
      return ApiResponse(success: false, message: 'Failed to create order.');
    } on DioException catch (e) {
      return ApiResponse(success: false, message: e.response?.data['message'] ?? e.message ?? 'Unknown error');
    }
  }

  Future<ApiResponse<void>> verifyPayment(String bookingId, String phase, Map<String, dynamic> verificationData) async {
    try {
      final url = phase == 'INITIAL' ? '/payments/initial/verify' : '/payments/remaining/verify';
      verificationData['bookingId'] = bookingId;

      final response = await _apiClient.dio.post(url, data: verificationData);

      if (response.statusCode == 200) {
        return ApiResponse(success: true, message: 'Payment verified!');
      }
      return ApiResponse(success: false, message: 'Verification failed.');
    } on DioException catch (e) {
      return ApiResponse(success: false, message: e.response?.data['message'] ?? e.message ?? 'Unknown error');
    }
  }

  Future<ApiResponse<void>> cancelBooking(String bookingId, String reason) async {
    try {
      final response = await _apiClient.dio.patch(
        '/bookings/$bookingId/cancel',
        data: {'cancellationReason': reason},
      );
      if (response.statusCode == 200) {
        return ApiResponse(success: true, message: response.data['message'] ?? 'Booking cancelled successfully');
      }
      return ApiResponse(success: false, message: 'Failed to cancel booking.');
    } on DioException catch (e) {
      return ApiResponse(success: false, message: e.response?.data['message'] ?? e.message ?? 'Unknown error');
    } catch (e) {
      return ApiResponse(success: false, message: 'App Error: $e');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getCancellationPolicy() async {
    try {
      final response = await _apiClient.dio.get('/bookings/cancellation-policy');
      if (response.statusCode == 200) {
        return ApiResponse(success: true, message: 'Policy loaded', data: response.data['data']);
      }
      return ApiResponse(success: false, message: 'Failed to load policy.');
    } on DioException catch (e) {
      return ApiResponse(success: false, message: e.response?.data['message'] ?? e.message ?? 'Unknown error');
    }
  }
}