import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../data/local/hive_service.dart';
import '../../../data/models/prayer_time.dart';
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
      enabledAlarms: _enabledAlarmNames(prayerTime),
    );
  }

  Set<String> _enabledAlarmNames(PrayerTime prayerTime) => {
    for (final prayer in prayerTime.toList())
      if (_hiveService.isAlarmEnabled(prayer.name)) prayer.name,
  };

  bool get use12HourFormat => _hiveService.getUse12HourFormat();
  int get prayerMethod => _hiveService.getPrayerMethod();
  int get prayerSchool => _hiveService.getPrayerSchool();
  int get hijriAdjustment => _hiveService.getHijriAdjustment();

  Future<void> setPrayerMethod(int method) =>
      _hiveService.setPrayerMethod(method);

  Future<void> setPrayerSchool(int school) =>
      _hiveService.setPrayerSchool(school);

  Future<void> setHijriAdjustment(int days) =>
      _hiveService.setHijriAdjustment(days);

  Future<void> setUse12HourFormat(bool enabled) =>
      _hiveService.setUse12HourFormat(enabled);

  Future<void> togglePrayerAlarm(PrayerItem prayer) async {
    final current = state;
    if (current is! PrayerLoaded) return;

    final enabled = !current.isAlarmEnabled(prayer.name);
    await _hiveService.setAlarmEnabled(prayer.name, enabled);

    if (enabled) {
      await NotificationService.schedulePrayerAhead(
        prayerName: prayer.name,
        time: prayer.time,
      );
    } else {
      await NotificationService.cancelPrayer(prayer.name);
    }

    final alarms = Set<String>.from(current.enabledAlarms);
    enabled ? alarms.add(prayer.name) : alarms.remove(prayer.name);

    emit(
      PrayerLoaded(
        prayerTime: current.prayerTime,
        qiblaDirection: current.qiblaDirection,
        locationName: current.locationName,
        enabledAlarms: alarms,
      ),
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
