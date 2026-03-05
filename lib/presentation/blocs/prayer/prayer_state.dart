import 'package:equatable/equatable.dart';
import '../../../data/models/prayer_time.dart';

abstract class PrayerState extends Equatable {
  const PrayerState();
  @override
  List<Object?> get props => [];
}

class PrayerInitial extends PrayerState {}

class PrayerLoading extends PrayerState {}

class PrayerLoaded extends PrayerState {
  final PrayerTime prayerTime;
  final double? qiblaDirection;
  const PrayerLoaded({required this.prayerTime, this.qiblaDirection});
  @override
  List<Object?> get props => [prayerTime, qiblaDirection];
}

class PrayerError extends PrayerState {
  final String message;
  const PrayerError(this.message);
  @override
  List<Object?> get props => [message];
}
