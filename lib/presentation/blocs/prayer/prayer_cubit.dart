import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/prayer_repository.dart';
import 'prayer_state.dart';

class PrayerCubit extends Cubit<PrayerState> {
  final PrayerRepository _repository;
  PrayerCubit(this._repository) : super(PrayerInitial());

  Future<void> loadPrayerTimes({
    double lat = -6.2088,
    double lng = 106.8456,
  }) async {
    emit(PrayerLoading());
    try {
      final prayerTime = await _repository.getPrayerTimes(lat, lng);
      final qibla = await _repository.getQiblaDirection(lat, lng);
      emit(PrayerLoaded(prayerTime: prayerTime, qiblaDirection: qibla));
    } catch (e) {
      emit(PrayerError(e.toString()));
    }
  }
}
