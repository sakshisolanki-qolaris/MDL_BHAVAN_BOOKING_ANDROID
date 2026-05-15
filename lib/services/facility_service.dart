import '../core/network/api_client.dart';
import '../models/facility_model.dart';

class FacilityService {
  final ApiClient _apiClient;

  FacilityService(this._apiClient);

  Future<List<FacilityModel>> getFacilities() async {
    try {
      final response = await _apiClient.dio.get('/facilities');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((item) => FacilityModel.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load facilities: $e');
    }
  }
}