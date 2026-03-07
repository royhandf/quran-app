import '../models/prayer_time.dart';
import '../../core/services/api_service.dart';
import '../../core/constants/api_constants.dart';

class PrayerRepository {
  final ApiService _apiService;
  PrayerRepository(this._apiService);

  Future<PrayerTime> getPrayerTimes(
    double lat,
    double lng, {
    DateTime? date,
    int method = 20,
    int school = 0,
    int hijriAdjustment = 0,
  }) async {
    final d = date ?? DateTime.now();
    final response = await _apiService.get(
      '${ApiConstants.aladhanBaseUrl}/timings/${d.day}-${d.month}-${d.year}',
      params: {
        'latitude': lat,
        'longitude': lng,
        'method': method,
        'school': school,
        'adjustment': hijriAdjustment,
      },
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
