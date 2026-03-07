import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../blocs/quran/quran_cubit.dart';
import '../../blocs/quran/quran_state.dart';
import '../../blocs/settings/settings_cubit.dart';

class JuzDetailScreen extends StatelessWidget {
  final int juzNumber;
  const JuzDetailScreen({super.key, required this.juzNumber});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state;

    return Scaffold(
      appBar: AppBar(title: Text('Juz $juzNumber'), centerTitle: true),
      body: BlocBuilder<QuranCubit, QuranState>(
        builder: (context, state) {
          if (state is QuranLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is QuranError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          if (state is JuzVersesLoaded) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.verses.length,
              itemBuilder: (context, index) {
                final ayah = state.verses[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card(context),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary.withValues(alpha: 0.15),
                            ),
                            child: Center(
                              child: Text(
                                '${ayah.verseNumber}',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        ayah.textArabic,
                        textAlign: TextAlign.right,
                        style: AppTextStyles.arabicLarge(
                          context,
                          fontSize: settings.arabicFontSize,
                        ),
                      ),
                      if (settings.showLatin) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Transliterasi ayat ${ayah.verseNumber}',
                          style: TextStyle(
                            fontSize: settings.latinFontSize,
                            fontStyle: FontStyle.italic,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                      if (settings.showTranslation &&
                          ayah.textTranslation != null) ...[
                        Divider(
                          height: 24,
                          color: AppColors.dividerColor(context),
                        ),
                        Text(
                          ayah.textTranslation!,
                          style: TextStyle(
                            fontSize: settings.translationFontSize,
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
