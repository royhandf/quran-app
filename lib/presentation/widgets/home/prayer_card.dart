import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_tokens.dart';
import '../../../data/models/prayer_time.dart';
import '../../blocs/prayer/prayer_state.dart';

const _prayerArabic = {
  'Imsak': 'الإمساك',
  'Subuh': 'الفجر',
  'Terbit': 'الشروق',
  'Dzuhur': 'الظهر',
  'Ashar': 'العصر',
  'Maghrib': 'المغرب',
  'Isya': 'العشاء',
};

class PrayerCard extends StatelessWidget {
  final PrayerLoaded data;
  final bool use12h;
  final String zoneLabel;
  final bool showRemaining;
  final VoidCallback? onKiblatTap;

  final String? dateHeading;

  const PrayerCard({
    super.key,
    required this.data,
    this.use12h = false,
    this.zoneLabel = 'WIB',
    this.showRemaining = true,
    this.onKiblatTap,
    this.dateHeading,
  });

  String _formatTime(String hhmm) => use12h ? PrayerTime.to12Hour(hhmm) : hhmm;

  String get _city {
    final name = data.locationName;
    if (name.isEmpty) return 'Lokasi';
    final city = name.split(' - ').first;
    return city.replaceFirst(RegExp(r'^(Kota|Kabupaten)\s+'), '');
  }

  String get _hijri {
    final raw = data.prayerTime.hijriDate;
    return raw.endsWith('H') && !raw.endsWith(' H')
        ? '${raw.substring(0, raw.length - 1)} H'
        : raw;
  }

  @override
  Widget build(BuildContext context) {
    final next = data.prayerTime.getNextPrayer();
    final remaining = data.prayerTime.getTimeUntilNextPrayer();
    final remainingText = remaining == null
        ? null
        : '${remaining.inHours} jam ${remaining.inMinutes % 60} menit lagi';

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTokens.cardRadius),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned.fill(child: ColoredBox(color: AppColors.forest)),
          Positioned.fill(
            child: IgnorePointer(
              child: LayoutBuilder(
                builder: (context, card) {
                  final scale = (card.maxHeight / 192).clamp(1.0, 2.0);
                  final ornWidth = 350 * scale;
                  final ornHeight = 220 * scale;
                  return OverflowBox(
                    alignment: Alignment.bottomRight,
                    minWidth: 0,
                    minHeight: 0,
                    maxWidth: ornWidth,
                    maxHeight: ornHeight,
                    child: SizedBox(
                      width: ornWidth,
                      height: ornHeight,
                      child: Transform.translate(
                        offset: Offset(32 * scale, 0),
                        child: SvgPicture.asset(
                          'assets/images/ornamen-kartu-sholat-v2.svg',
                          width: ornWidth,
                          height: ornHeight,
                          fit: BoxFit.none,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppTokens.pageMargin),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _city,
                        style: AppTokens.prayerCity,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (onKiblatTap != null)
                      GestureDetector(
                        onTap: onKiblatTap,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.explore_rounded,
                                color: Colors.white,
                                size: 13,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Kiblat',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(_hijri, style: AppTokens.hijriDate),
                const SizedBox(height: 18),
                if (dateHeading != null) ...[
                  Text(
                    'JADWAL SHOLAT',
                    style: AppTokens.cardLabel(
                      context,
                    ).copyWith(color: Colors.white.withValues(alpha: 0.7)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateHeading!,
                    style: AppTokens.prayerName.copyWith(fontSize: 22),
                  ),
                ] else if (next != null) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Flexible(
                        child: Text(
                          next.name,
                          style: AppTokens.prayerName,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _prayerArabic[next.name] ?? '',
                        style: AppTokens.prayerArabic,
                        textDirection: TextDirection.rtl,
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(_formatTime(next.time), style: AppTokens.prayerTime),
                      const SizedBox(width: 8),
                      Text(zoneLabel, style: AppTokens.prayerTimezone),
                    ],
                  ),
                ] else ...[
                  Text(
                    'Semua waktu sholat\nsudah selesai',
                    style: AppTokens.prayerName.copyWith(height: 1.3),
                  ),
                ],
                const SizedBox(height: 14),
                if (next != null && remainingText != null && showRemaining)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(remainingText, style: AppTokens.prayerChip),
                  )
                else if (next == null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      'Subuh besok pukul ${_formatTime(data.prayerTime.fajr)}',
                      style: AppTokens.prayerChip,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
