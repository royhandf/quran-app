import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/location_service.dart';
import '../../../data/local/hive_service.dart';
import '../../../data/repositories/prayer_repository.dart';
import 'prayer_state.dart';

class PrayerCubit extends Cubit<PrayerState> {
  final PrayerRepository _repository;
  final LocationService _locationService;
  final HiveService _hiveService;

  PrayerCubit(this._repository, this._locationService, this._hiveService)
    : super(PrayerInitial());

  Future<void> loadPrayerTimes() async {
    emit(PrayerLoading());
    try {
      final position = await _locationService.getCurrentPosition();
      final lat = position.latitude;
      final lng = position.longitude;

      final prayerTime = await _repository.getPrayerTimes(
        lat,
        lng,
        method: _hiveService.getPrayerMethod(),
        school: _hiveService.getPrayerSchool(),
        hijriAdjustment: _hiveService.getHijriAdjustment(),
      );
      final qibla = await _repository.getQiblaDirection(lat, lng);
      final cityName = await _locationService.getCityName(lat, lng);

      emit(
        PrayerLoaded(
          prayerTime: prayerTime,
          qiblaDirection: qibla,
          locationName: cityName,
        ),
      );
    } catch (e) {
      emit(PrayerError(e.toString()));
    }
  }

  Future<void> loadPrayerTimesByDate(DateTime date) async {
    final prev = state is PrayerLoaded ? state as PrayerLoaded : null;
    emit(PrayerLoading());
    try {
      final position = await _locationService.getCurrentPosition();
      final prayerTime = await _repository.getPrayerTimes(
        position.latitude,
        position.longitude,
        date: date,
        method: _hiveService.getPrayerMethod(),
        school: _hiveService.getPrayerSchool(),
        hijriAdjustment: _hiveService.getHijriAdjustment(),
      );

      // Reuse qibla & city name dari state sebelumnya jika ada,
      // karena tidak berubah hanya karena ganti tanggal.
      final qibla = prev?.qiblaDirection ??
          await _repository.getQiblaDirection(
            position.latitude,
            position.longitude,
          );
      final cityName = prev?.locationName ??
          await _locationService.getCityName(
            position.latitude,
            position.longitude,
          );

      emit(
        PrayerLoaded(
          prayerTime: prayerTime,
          qiblaDirection: qibla,
          locationName: cityName,
        ),
      );
    } catch (e) {
      emit(PrayerError(e.toString()));
    }
  }
}
