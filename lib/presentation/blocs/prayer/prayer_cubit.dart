import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/notification_service.dart';
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
    final cached = _hiveService.getCachedPrayerData();
    if (cached != null && state is! PrayerLoaded) {
      emit(cached);
    }

    if (state is! PrayerLoaded) emit(PrayerLoading());

    try {
      final position = await _locationService.getCurrentPosition();
      final result = await _fetchPrayerData(position);
      _hiveService.cachePrayerData(result);
      emit(result);
      // Schedule ulang semua alarm sesuai preferensi user
      await NotificationService.scheduleAllPrayers(
        result.prayerTime.toList(),
        _hiveService,
      );
    } catch (e) {
      if (state is! PrayerLoaded) emit(PrayerError(e.toString()));
    }
  }

  Future<PrayerLoaded> _fetchPrayerData(
    Position position, {
    DateTime? date,
    PrayerLoaded? reuse,
  }) async {
    final lat = position.latitude;
    final lng = position.longitude;

    final prayerTime = await _repository.getPrayerTimes(
      lat,
      lng,
      date: date,
      method: _hiveService.getPrayerMethod(),
      school: _hiveService.getPrayerSchool(),
      hijriAdjustment: _hiveService.getHijriAdjustment(),
    );

    final qiblaFuture = reuse?.qiblaDirection != null
        ? Future.value(reuse!.qiblaDirection)
        : _repository.getQiblaDirection(lat, lng);
    final cityFuture = reuse?.locationName.isNotEmpty == true
        ? Future.value(reuse!.locationName)
        : _locationService.getCityName(lat, lng);

    final results = await Future.wait([qiblaFuture, cityFuture]);

    return PrayerLoaded(
      prayerTime: prayerTime,
      qiblaDirection: results[0] as double?,
      locationName: results[1] as String,
    );
  }

  Future<void> loadPrayerTimesByDate(DateTime date) async {
    final prev = state is PrayerLoaded ? state as PrayerLoaded : null;
    emit(PrayerLoading());
    try {
      final position = await _locationService.getCurrentPosition();
      final result = await _fetchPrayerData(position, date: date, reuse: prev);
      emit(result);
    } catch (e) {
      emit(PrayerError(e.toString()));
    }
  }
}
