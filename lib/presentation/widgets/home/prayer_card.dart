import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/constants/app_tokens.dart';
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

/// Kartu jadwal sholat di home. Semua data diambil dari [PrayerLoaded];
/// countdown ikut dihitung ulang setiap rebuild (home punya Timer 1 menit).
class PrayerCard extends StatelessWidget {
  final PrayerLoaded data;

  const PrayerCard({super.key, required this.data});

  String get _city {
    final name = data.locationName;
    if (name.isEmpty) return 'Lokasi';
    return name.split(' - ').first;
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
      child: Container(
        color: AppTokens.forest,
        padding: const EdgeInsets.all(AppTokens.pageMargin),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              child: IgnorePointer(
                child: SvgPicture.asset(
                  'assets/images/ornamen-kartu-sholat-v2.svg',
                  width: 350,
                  height: 220,
                  fit: BoxFit.none,
                ),
              ),
            ),
            Column(
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
                    Text(_city, style: AppTokens.prayerCity),
                    const Spacer(),
                    Flexible(
                      child: Text(
                        _hijri,
                        style: AppTokens.hijriDate,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text('SHOLAT BERIKUTNYA', style: AppTokens.prayerLabel),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Flexible(
                      child: Text(
                        next?.name ?? 'Selesai',
                        style: AppTokens.prayerName,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _prayerArabic[next?.name] ?? '',
                      style: AppTokens.prayerArabic,
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                if (next != null)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(next.time, style: AppTokens.prayerTime),
                      const SizedBox(width: 8),
                      Text('WIB', style: AppTokens.prayerTimezone),
                    ],
                  ),
                if (remainingText != null) ...[
                  const SizedBox(height: 14),
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
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
