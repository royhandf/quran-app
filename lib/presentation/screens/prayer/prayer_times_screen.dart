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

  static int _prayerNotifId(String name) {
    const ids = {
      'Fajr': 1, 'Sunrise': 2, 'Dhuhr': 3, 'Asr': 4, 'Maghrib': 5, 'Isha': 6,
      'Subuh': 1, 'Terbit': 2, 'Dzuhur': 3, 'Ashar': 4, 'Isya': 6,
    };
    return ids[name] ?? name.hashCode.abs() % 100 + 10;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<PrayerCubit, PrayerState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background(context),
          appBar: AppBar(
            backgroundColor: AppColors.background(context),
            elevation: 0,
            scrolledUnderElevation: 0,
            title: Text(
              'Jadwal Sholat',
              style: AppTextStyles.headingSmall(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.calendar_today_outlined, size: 20),
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
                icon: const Icon(Icons.my_location_rounded, size: 20),
                onPressed: () => context.read<PrayerCubit>().loadPrayerTimes(),
              ),
              IconButton(
                icon: const Icon(Icons.tune_rounded, size: 20),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const PrayerSettingsScreen()),
                  );
                  if (context.mounted) setState(() {});
                },
              ),
            ],
          ),
          body: _buildBody(context, state, isDark),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, PrayerState state, bool isDark) {
    if (state is PrayerLoading) return _buildLoading(context);
    if (state is PrayerError) return _buildError(context);
    if (state is PrayerLoaded) return _buildLoaded(context, state, isDark);
    return const SizedBox();
  }

  Widget _buildLoading(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildError(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.location_off_outlined, size: 32,
                  color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            Text('Gagal mendapatkan lokasi',
                style: AppTextStyles.bodyLarge(context)
                    .copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text('Pastikan GPS aktif dan izin lokasi diberikan',
                style: AppTextStyles.bodySmall(context),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.read<PrayerCubit>().loadPrayerTimes(),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoaded(
      BuildContext context, PrayerLoaded state, bool isDark) {
    final times = state.prayerTime.toList();
    final nextIndex = state.prayerTime.getNextPrayerIndex();
    final nextPrayer = state.prayerTime.getNextPrayer();
    final timeUntil = state.prayerTime.getTimeUntilNextPrayer();
    final use12h = _hiveService.getUse12HourFormat();

    return RefreshIndicator(
      onRefresh: () => context.read<PrayerCubit>().loadPrayerTimes(),
      color: AppColors.primary,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ── Header ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Lokasi + tanggal
                Row(
                  children: [
                    Icon(Icons.location_on_rounded, size: 13,
                        color: AppColors.textSecondary(context)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        state.locationName,
                        style: AppTextStyles.bodySmall(context),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      state.prayerTime.date,
                      style: AppTextStyles.bodySmall(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Next prayer card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: nextPrayer != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Label
                            Row(
                              children: [
                                Text(
                                  state.prayerTime.hijriDate,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                const Spacer(),
                                // Kiblat button
                                GestureDetector(
                                  onTap: () => _openQibla(context, state),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withValues(alpha: 0.18),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.explore_rounded,
                                            color: Colors.white, size: 14),
                                        SizedBox(width: 4),
                                        Text(
                                          'Kiblat',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Berikutnya',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 12,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  nextPrayer.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  use12h
                                      ? PrayerTime.to12Hour(nextPrayer.time)
                                      : nextPrayer.time,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w700,
                                    fontFeatures: [
                                      FontFeature.tabularFigures()
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (timeUntil != null) ...[
                              const SizedBox(height: 12),
                              Container(
                                height: 1,
                                color: Colors.white.withValues(alpha: 0.15),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '${timeUntil.inHours} jam ${timeUntil.inMinutes % 60} menit lagi',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ],
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    state.prayerTime.hijriDate,
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 12),
                                  ),
                                  const Spacer(),
                                  GestureDetector(
                                    onTap: () => _openQibla(context, state),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: Colors.white
                                            .withValues(alpha: 0.18),
                                        borderRadius:
                                            BorderRadius.circular(20),
                                      ),
                                      child: const Row(children: [
                                        Icon(Icons.explore_rounded,
                                            color: Colors.white, size: 14),
                                        SizedBox(width: 4),
                                        Text('Kiblat',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600)),
                                      ]),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Semua waktu sholat\nsudah selesai',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),

          // ── Divider + label ───────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Jadwal Hari Ini',
                  style: AppTextStyles.bodySmall(context).copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // ── Prayer rows ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.card(context),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.dividerColor(context)),
              ),
              clipBehavior: Clip.hardEdge,
              child: Column(
                children: List.generate(times.length, (index) {
                  final p = times[index];
                  final isNext = nextIndex != -1 && index == nextIndex;
                  final isPassed = nextIndex == -1 || index < nextIndex;
                  final alarmEnabled = _hiveService.isAlarmEnabled(p.name);
                  final isLast = index == times.length - 1;

                  return _PrayerRow(
                    prayer: p,
                    isNext: isNext,
                    isPassed: isPassed,
                    alarmEnabled: alarmEnabled,
                    isLast: isLast,
                    use12h: use12h,
                    onAlarmTap: () {
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
                        NotificationService.cancelAdzan(_prayerNotifId(p.name));
                      }
                    },
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _openQibla(BuildContext context, PrayerLoaded state) {
    if (state.qiblaDirection != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              QiblaScreen(qiblaDirection: state.qiblaDirection!),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Arah kiblat tidak tersedia. Aktifkan GPS.'),
        ),
      );
    }
  }
}

// ── Prayer row widget ──────────────────────────────────────────────────────────
class _PrayerRow extends StatelessWidget {
  final dynamic prayer;
  final bool isNext;
  final bool isPassed;
  final bool alarmEnabled;
  final bool isLast;
  final bool use12h;
  final VoidCallback onAlarmTap;

  const _PrayerRow({
    required this.prayer,
    required this.isNext,
    required this.isPassed,
    required this.alarmEnabled,
    required this.isLast,
    required this.use12h,
    required this.onAlarmTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color nameColor = isNext
        ? AppColors.primary
        : isPassed
            ? AppColors.textSecondary(context).withValues(alpha: 0.6)
            : AppColors.textPrimary(context);

    final Color timeColor = isNext
        ? AppColors.primary
        : isPassed
            ? AppColors.textSecondary(context).withValues(alpha: 0.5)
            : AppColors.textSecondary(context);

    return Column(
      children: [
        Container(
          color: isNext ? AppColors.primary.withValues(alpha: 0.05) : null,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            children: [
              // Dot indicator
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(right: 14),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isNext
                      ? AppColors.primary
                      : isPassed
                          ? AppColors.dividerColor(context)
                          : AppColors.primary.withValues(alpha: 0.3),
                ),
              ),

              // Nama sholat
              Expanded(
                child: Text(
                  prayer.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight:
                        isNext ? FontWeight.w700 : FontWeight.w500,
                    color: nameColor,
                  ),
                ),
              ),

              // Jam
              Text(
                use12h ? PrayerTime.to12Hour(prayer.time) : prayer.time,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight:
                      isNext ? FontWeight.w700 : FontWeight.w500,
                  color: timeColor,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),

              const SizedBox(width: 12),

              // Alarm toggle
              GestureDetector(
                onTap: onAlarmTap,
                child: Icon(
                  alarmEnabled
                      ? Icons.notifications_rounded
                      : Icons.notifications_none_rounded,
                  size: 20,
                  color: alarmEnabled
                      ? AppColors.primary
                      : AppColors.textSecondary(context)
                          .withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Padding(
            padding: const EdgeInsets.only(left: 40),
            child: Divider(
              height: 1,
              color: AppColors.dividerColor(context),
            ),
          ),
      ],
    );
  }
}
