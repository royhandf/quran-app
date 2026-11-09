import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/constants/app_colors.dart';
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

class PrayerCard extends StatelessWidget {
  final PrayerLoaded data;

  const PrayerCard({super.key, required this.data});

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
          const Positioned.fill(
            child: ColoredBox(color: AppColors.forest),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final scale = (constraints.maxHeight / 192).clamp(1.0, 1.6);
                  final width = 350 * scale;
                  final height = 220 * scale;
                  return OverflowBox(
                    maxWidth: width,
                    maxHeight: height,
                    alignment: Alignment.bottomRight,
                    child: Transform.translate(
                      // Setengah pitch bintang (pitch horizontal 64) supaya
                      // tepi card memotong badan bintang, bukan ujungnya.
                      offset: Offset(32 * scale, 0),
                      child: SvgPicture.asset(
                        'assets/images/ornamen-kartu-sholat-v2.svg',
                        width: width,
                        height: height,
                        fit: BoxFit.none,
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
                    Text(_hijri, style: AppTokens.hijriDate),
                  ],
                ),
                const SizedBox(height: 18),
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
          ),
        ],
      ),
    );
  }
}
