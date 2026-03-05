import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../blocs/settings/settings_cubit.dart';
import '../../blocs/settings/settings_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settings) {
          final cubit = context.read<SettingsCubit>();
          return ListView(
            children: [
              // Tema
              _section(context, 'Tema'),
              _tile(
                context,
                'Mode Gelap',
                settings.themeMode == ThemeMode.dark ? 'Aktif' : 'Nonaktif',
                trailing: Switch(
                  value: settings.themeMode == ThemeMode.dark,
                  onChanged: (_) => cubit.toggleTheme(),
                  activeThumbColor: AppColors.primary,
                ),
              ),
              _thickDivider(context),

              // Arabic
              _section(context, 'Arabic'),
              _tile(
                context,
                'Jenis Penulisan Arabic',
                '${settings.arabicFontType} (Asia)',
                onTap: () => _showFontTypeDialog(context, cubit, settings),
              ),
              _tile(
                context,
                'Ukuran Font Arabic',
                '${settings.arabicFontSize.toInt()} px',
                trailing: SizedBox(
                  width: 150,
                  child: Slider(
                    value: settings.arabicFontSize,
                    min: 18,
                    max: 40,
                    divisions: 22,
                    activeColor: AppColors.primary,
                    onChanged: cubit.setArabicFontSize,
                  ),
                ),
              ),
              _tile(
                context,
                'Tajwid Berwarna',
                'Mengaktifkan dan nonaktifkan tajwid berwarna serta penjelasannya',
                trailing: Switch(
                  value: settings.tajwidColored,
                  onChanged: cubit.toggleTajwidColored,
                  activeThumbColor: AppColors.primary,
                ),
              ),
              _tile(
                context,
                'Nomor Ayat Arabic',
                'Perlihatkan nomor ayat arabic di ayat',
                trailing: Switch(
                  value: settings.showArabicNumbers,
                  onChanged: cubit.toggleArabicNumbers,
                  activeThumbColor: AppColors.primary,
                ),
              ),
              _thickDivider(context),

              // Latin
              _section(context, 'Latin (Transliterasi)'),
              _tile(
                context,
                'Aktifkan Latin',
                "Perlihatkan latin (transliterasi) Qur'an",
                trailing: Switch(
                  value: settings.showLatin,
                  onChanged: cubit.toggleLatin,
                  activeThumbColor: AppColors.primary,
                ),
              ),
              _tile(
                context,
                'Ukuran Font Latin',
                '${settings.latinFontSize.toInt()} px',
                trailing: SizedBox(
                  width: 150,
                  child: Slider(
                    value: settings.latinFontSize,
                    min: 12,
                    max: 24,
                    divisions: 12,
                    activeColor: AppColors.primary,
                    onChanged: cubit.setLatinFontSize,
                  ),
                ),
              ),
              _thickDivider(context),

              // Terjemahan
              _section(context, 'Terjemahan'),
              _tile(
                context,
                'Aktifkan Terjemahan',
                "Perlihatkan terjemahan Qur'an Bahasa Indonesia",
                trailing: Switch(
                  value: settings.showTranslation,
                  onChanged: cubit.toggleTranslation,
                  activeThumbColor: AppColors.primary,
                ),
              ),
              _tile(context, 'Penerjemah', settings.translator),
              _tile(
                context,
                'Ukuran Font Terjemahan',
                '${settings.translationFontSize.toInt()} px',
                trailing: SizedBox(
                  width: 150,
                  child: Slider(
                    value: settings.translationFontSize,
                    min: 12,
                    max: 24,
                    divisions: 12,
                    activeColor: AppColors.primary,
                    onChanged: cubit.setTranslationFontSize,
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _section(BuildContext context, String title) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
    child: Text(title, style: AppTextStyles.sectionHeader(context)),
  );

  Widget _thickDivider(BuildContext context) =>
      Divider(height: 1, thickness: 6, color: AppColors.background(context));

  Widget _tile(
    BuildContext context,
    String title,
    String subtitle, {
    Widget? trailing,
    VoidCallback? onTap,
  }) => ListTile(
    title: Text(
      title,
      style: AppTextStyles.bodyLarge(
        context,
      ).copyWith(fontWeight: FontWeight.w500),
    ),
    subtitle: Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(subtitle, style: AppTextStyles.bodySmall(context)),
    ),
    trailing: trailing,
    onTap: onTap,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
  );

  void _showFontTypeDialog(
    BuildContext context,
    SettingsCubit cubit,
    SettingsState settings,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Jenis Penulisan Arabic'),
        children: ['IndoPak', 'Uthmani'].map((t) {
          final isSelected = settings.arabicFontType == t;
          return ListTile(
            leading: Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? AppColors.primary : null,
            ),
            title: Text(t),
            onTap: () {
              cubit.setArabicFontType(t);
              Navigator.pop(ctx);
            },
          );
        }).toList(),
      ),
    );
  }
}
