import '../models/prayer_time.dart';
import '../../core/services/api_service.dart';
import '../../core/constants/api_constants.dart';

class PrayerRepository {
  final ApiService _apiService;
  PrayerRepository(this._apiService);

  Future<PrayerTime> getPrayerTimes(double lat, double lng) async {
    final now = DateTime.now();
    final response = await _apiService.get(
      '${ApiConstants.aladhanBaseUrl}/timings/${now.day}-${now.month}-${now.year}',
      params: {'latitude': lat, 'longitude': lng, 'method': 20},
    );
    return PrayerTime.fromJson(response.data['data']);
  }

  Future<double> getQiblaDirection(double lat, double lng) async {
    final response = await _apiService.get(
      '${ApiConstants.aladhanBaseUrl}/qibla/$lat/$lng',
    );
    return (response.data['data']['direction'] as num).toDouble();
  }
}
