import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../blocs/prayer/prayer_cubit.dart';
import '../../blocs/prayer/prayer_state.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});
  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PrayerCubit>().loadPrayerTimes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
              child: const Icon(
                Icons.mosque,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            Text('Kepanjen', style: AppTextStyles.headingSmall(context)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.location_on_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocBuilder<PrayerCubit, PrayerState>(
        builder: (context, state) {
          if (state is PrayerLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is PrayerError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          if (state is PrayerLoaded) {
            final times = state.prayerTime.toList();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info Panel
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Waktu Terbit Sudah Lewat',
                                style: AppTextStyles.bodySmall(context)
                                    .copyWith(
                                      color: AppColors.primary,
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              Text(
                                '± 3 jam yang lalu',
                                style: AppTextStyles.bodySmall(context),
                              ),
                            ],
                          ),
                          OutlinedButton.icon(
                            onPressed: () {},
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
                          Text(
                            'Kepanjen, Kab. Malang - Indonesia',
                            style: AppTextStyles.bodySmall(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Prayer Times List
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: times.length,
                    separatorBuilder: (_, _) => Divider(
                      height: 1,
                      color: AppColors.dividerColor(context),
                    ),
                    itemBuilder: (context, index) {
                      final p = times[index];
                      final isPassed = index <= 2;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                p.name,
                                style: AppTextStyles.bodyLarge(context)
                                    .copyWith(
                                      color: isPassed
                                          ? AppColors.primary
                                          : AppColors.textPrimary(context),
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ),
                            Text(
                              p.time,
                              style: AppTextStyles.bodyLarge(context).copyWith(
                                color: isPassed
                                    ? AppColors.primary
                                    : AppColors.textPrimary(context),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 16),
                            GestureDetector(
                              onTap: () {},
                              child: const Icon(
                                Icons.alarm,
                                color: AppColors.primary,
                                size: 22,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
