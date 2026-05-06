import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:quran_app/presentation/screens/prayer/prayer_settings_screen.dart';
import 'package:quran_app/presentation/screens/prayer/qibla_screen.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/services/notification_service.dart';
import '../../../data/local/hive_service.dart';
import '../../../data/models/prayer_time.dart';
import '../../blocs/prayer/prayer_cubit.dart';
import '../../blocs/prayer/prayer_state.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});
  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  late final HiveService _hiveService;

  @override
  void initState() {
    super.initState();
    _hiveService = GetIt.instance<HiveService>();
    context.read<PrayerCubit>().loadPrayerTimes();
  }

  static int _prayerNotifId(String prayerName) {
    const ids = {
      'Fajr': 1,
      'Sunrise': 2,
      'Dhuhr': 3,
      'Asr': 4,
      'Maghrib': 5,
      'Isha': 6,
      // Nama Indonesia
      'Subuh': 1,
      'Terbit': 2,
      'Dzuhur': 3,
      'Ashar': 4,
      'Isya': 6,
    };
    return ids[prayerName] ?? prayerName.hashCode.abs() % 100 + 10;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrayerCubit, PrayerState>(
      builder: (context, state) {
        final title = state is PrayerLoaded
            ? state.locationName
            : 'Jadwal Sholat';

        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Flexible(
                  child: Text(
                    title,
                    style: AppTextStyles.headingSmall(context),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.calendar_today_outlined),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null && context.mounted) {
                    context.read<PrayerCubit>().loadPrayerTimesByDate(picked);
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.location_on_outlined),
                onPressed: () {
                  context.read<PrayerCubit>().loadPrayerTimes();
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PrayerSettingsScreen(),
                    ),
                  );
                  if (context.mounted) setState(() {});
                },
              ),
            ],
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, PrayerState state) {
    if (state is PrayerLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is PrayerError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off_outlined,
              size: 52,
              color: AppColors.textSecondary(context),
            ),
            const SizedBox(height: 12),
            Text(
              'Gagal mendapatkan lokasi',
              style: AppTextStyles.bodyMedium(context),
            ),
            const SizedBox(height: 4),
            Text(
              'Pastikan GPS aktif dan izin lokasi diberikan',
              style: AppTextStyles.bodySmall(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => context.read<PrayerCubit>().loadPrayerTimes(),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }
    if (state is PrayerLoaded) {
      final times = state.prayerTime.toList();
      final nextIndex = state.prayerTime.getNextPrayerIndex();
      final nextPrayer = state.prayerTime.getNextPrayer();
      final timeUntil = state.prayerTime.getTimeUntilNextPrayer();
      final use12h = _hiveService.getUse12HourFormat();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: AppColors.surface(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      state.prayerTime.hijriDate,
                      style: AppTextStyles.bodyMedium(context),
                    ),
                    Text(
                      state.prayerTime.date,
                      style: AppTextStyles.bodySmall(context),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (nextPrayer != null) ...[
                            Text(
                              'Menuju ${nextPrayer.name}',
                              style: AppTextStyles.bodySmall(context).copyWith(
                                color: AppColors.primary,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (timeUntil != null)
                              Text(
                                '${timeUntil.inHours} jam ${timeUntil.inMinutes % 60} menit lagi',
                                style: AppTextStyles.bodySmall(context),
                              ),
                          ] else
                            Text(
                              'Semua waktu sholat hari ini sudah lewat',
                              style: AppTextStyles.bodySmall(context).copyWith(
                                color: AppColors.primary,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        if (state.qiblaDirection != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => QiblaScreen(
                                qiblaDirection: state.qiblaDirection!,
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Arah kiblat tidak tersedia. Aktifkan GPS dan muat ulang.',
                              ),
                              duration: Duration(seconds: 3),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.explore, size: 18),
                      label: const Text('QIBLAT'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary(context),
                        side: BorderSide(
                          color: AppColors.textSecondary(context),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: AppColors.textSecondary(context),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        state.locationName,
                        style: AppTextStyles.bodySmall(context),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: () => context.read<PrayerCubit>().loadPrayerTimes(),
              color: AppColors.primary,
              child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: times.length,
              separatorBuilder: (_, _) =>
                  Divider(height: 1, color: AppColors.dividerColor(context)),
              itemBuilder: (context, index) {
                final p = times[index];
                final isNext = nextIndex != -1 && index == nextIndex;
                final isPassed = nextIndex == -1 || index < nextIndex;
                final alarmEnabled = _hiveService.isAlarmEnabled(p.name);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          p.name,
                          style: AppTextStyles.bodyLarge(context).copyWith(
                            color: isNext
                                ? AppColors.primary
                                : isPassed
                                    ? AppColors.textSecondary(context)
                                    : AppColors.textPrimary(context),
                            fontWeight: isNext ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        use12h ? PrayerTime.to12Hour(p.time) : p.time,
                        style: AppTextStyles.bodyLarge(context).copyWith(
                          color: isNext
                              ? AppColors.primary
                              : isPassed
                                  ? AppColors.textSecondary(context)
                                  : AppColors.textPrimary(context),
                          fontWeight: isNext ? FontWeight.w700 : FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () {
                          final enabled = !_hiveService.isAlarmEnabled(p.name);
                          _hiveService.setAlarmEnabled(p.name, enabled);
                          setState(() {});
                          if (enabled) {
                            NotificationService.scheduleAdzan(
                              id: _prayerNotifId(p.name),
                              prayerName: p.name,
                              time: p.time,
                            );
                          } else {
                            NotificationService.cancelAdzan(
                              _prayerNotifId(p.name),
                            );
                          }
                        },
                        child: Icon(
                          alarmEnabled
                              ? Icons.notifications_active
                              : Icons.notifications_off_outlined,
                          color: alarmEnabled
                              ? AppColors.primary
                              : AppColors.textSecondary(context),
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            ),
          ),
        ],
      );
    }
    return const SizedBox();
  }
}
