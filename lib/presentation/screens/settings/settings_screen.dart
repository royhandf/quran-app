import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../blocs/settings/settings_cubit.dart';
import '../../blocs/settings/settings_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const List<Map<String, dynamic>> _reciters = [
    {'id': 7, 'name': 'Mishari Rashid al-Afasy'},
    {'id': 2, 'name': 'AbdulBaset AbdulSamad (Murattal)'},
    {'id': 1, 'name': 'AbdulBaset AbdulSamad (Mujawwad)'},
    {'id': 3, 'name': 'Abdur-Rahman as-Sudais'},
    {'id': 4, 'name': 'Abu Bakr al-Shatri'},
    {'id': 5, 'name': 'Hani ar-Rifai'},
    {'id': 6, 'name': 'Mahmoud Khalil Al-Husary'},
    {'id': 12, 'name': 'Mahmoud Khalil Al-Husary (Muallim)'},
    {'id': 9, 'name': 'Mohamed Siddiq al-Minshawi (Murattal)'},
    {'id': 8, 'name': 'Mohamed Siddiq al-Minshawi (Mujawwad)'},
    {'id': 10, 'name': "Sa'ud ash-Shuraym"},
    {'id': 11, 'name': 'Mohamed al-Tablawi'},
  ];

  String _getReciterName(int id) {
    final r = _reciters.firstWhere(
      (r) => r['id'] == id,
      orElse: () => _reciters.first,
    );
    return r['name'] as String;
  }

  String _themeModeLabel(ThemeMode mode) => switch (mode) {
    ThemeMode.light => 'Terang',
    ThemeMode.dark => 'Gelap',
    ThemeMode.system => 'Ikuti Sistem',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        backgroundColor: AppColors.background(context),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settings) {
          final cubit = context.read<SettingsCubit>();
          return ListView(
            children: [
              _section(context, 'Umum'),
              _tile(
                context,
                'Mode Tema',
                _themeModeLabel(settings.themeMode),
                onTap: () => _showThemeModeDialog(context, cubit, settings),
              ),
              _tile(
                context,
                'Biarkan Layar Menyala',
                'Layar tidak akan mati saat membaca',
                trailing: Switch(
                  value: settings.keepScreenOn,
                  onChanged: cubit.toggleKeepScreenOn,
                  activeThumbColor: AppColors.primary,
                ),
              ),
              _tile(
                context,
                'Layar Penuh',
                'Sembunyikan status bar dan navigation bar',
                trailing: Switch(
                  value: settings.fullScreen,
                  onChanged: cubit.toggleFullScreen,
                  activeThumbColor: AppColors.primary,
                ),
              ),
              _thickDivider(context),

              _section(context, 'Audio'),
              _tile(
                context,
                'Qori Murattal',
                _getReciterName(settings.selectedReciterId),
                onTap: () => _showReciterDialog(context, cubit, settings),
              ),
              _thickDivider(context),

              _section(context, 'Arabic'),
              _tile(
                context,
                'Jenis Penulisan Arabic',
                settings.arabicFontType == 'IndoPak'
                    ? 'IndoPak (Asia)'
                    : 'Utsmani (Madinah)',
                onTap: () => _showFontTypeDialog(context, cubit, settings),
              ),
              _tile(
                context,
                'Ukuran Font Arabic',
                '${settings.arabicFontSize.toInt()} px',
                onTap: () => _showFontSizeDialog(
                  context,
                  'Ukuran Font Arabic',
                  [12, 14, 16, 18, 20, 22, 24, 26, 28, 30],
                  settings.arabicFontSize.toInt(),
                  (v) => cubit.setArabicFontSize(v.toDouble()),
                ),
              ),
              _tile(
                context,
                'Tajwid Berwarna',
                settings.tajwidColored ? 'Aktif' : 'Nonaktif',
                onTap: () => _showTajwidDialog(context, cubit),
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
                onTap: () => _showFontSizeDialog(
                  context,
                  'Ukuran Font Latin',
                  [12, 14, 16, 18, 20, 22, 24, 26, 28, 30],
                  settings.latinFontSize.toInt(),
                  (v) => cubit.setLatinFontSize(v.toDouble()),
                ),
              ),
              _thickDivider(context),

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
                onTap: () => _showFontSizeDialog(
                  context,
                  'Ukuran Font Terjemahan',
                  [12, 14, 16, 18, 20, 22, 24, 26, 28, 30],
                  settings.translationFontSize.toInt(),
                  (v) => cubit.setTranslationFontSize(v.toDouble()),
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
    trailing:
        trailing ??
        (onTap != null
            ? Icon(Icons.chevron_right, color: AppColors.textSecondary(context))
            : null),
    onTap: onTap,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
  );

  void _showThemeModeDialog(
    BuildContext context,
    SettingsCubit cubit,
    SettingsState settings,
  ) {
    final items = [
      {'mode': ThemeMode.light, 'label': 'Terang'},
      {'mode': ThemeMode.dark, 'label': 'Gelap'},
      {'mode': ThemeMode.system, 'label': 'Ikuti Sistem'},
    ];
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Mode Tema'),
        children: items.map((item) {
          final mode = item['mode'] as ThemeMode;
          final isSelected = settings.themeMode == mode;
          return ListTile(
            leading: Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? AppColors.primary : null,
            ),
            title: Text(item['label'] as String),
            onTap: () {
              cubit.setThemeMode(mode);
              Navigator.pop(ctx);
            },
          );
        }).toList(),
      ),
    );
  }

  void _showTajwidDialog(BuildContext context, SettingsCubit cubit) {
    showDialog(
      context: context,
      builder: (_) => BlocBuilder<SettingsCubit, SettingsState>(
        builder: (ctx, state) {
          final items = [
            {
              'name': 'Ghunnah',
              'color': const Color(0xFFFF7043),
              'value': state.tajwidGhunnah,
              'toggle': cubit.toggleTajwidGhunnah,
            },
            {
              'name': 'Ikhfa',
              'color': const Color(0xFF66BB6A),
              'value': state.tajwidIkhfa,
              'toggle': cubit.toggleTajwidIkhfa,
            },
            {
              'name': 'Idgham',
              'color': const Color(0xFF42A5F5),
              'value': state.tajwidIdgham,
              'toggle': cubit.toggleTajwidIdgham,
            },
            {
              'name': 'Iqlab',
              'color': const Color(0xFFAB47BC),
              'value': state.tajwidIqlab,
              'toggle': cubit.toggleTajwidIqlab,
            },
            {
              'name': 'Qalqalah',
              'color': const Color(0xFFEF5350),
              'value': state.tajwidQalqalah,
              'toggle': cubit.toggleTajwidQalqalah,
            },
            {
              'name': 'Mad Lazim',
              'color': const Color(0xFFFFA726),
              'value': state.tajwidMadLazim,
              'toggle': cubit.toggleTajwidMadLazim,
            },
          ];
          return SimpleDialog(
            title: const Text('Pengaturan Tajwid'),
            children: [
              SwitchListTile(
                title: const Text('Tajwid Berwarna'),
                subtitle: const Text('Aktifkan warna tajwid'),
                value: state.tajwidColored,
                onChanged: cubit.toggleTajwidColored,
                activeThumbColor: AppColors.primary,
              ),
              if (state.tajwidColored)
                ...items.map(
                  (item) => ListTile(
                    leading: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: item['color'] as Color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    title: Text(item['name'] as String),
                    trailing: Switch(
                      value: item['value'] as bool,
                      onChanged: item['toggle'] as ValueChanged<bool>,
                      activeThumbColor: AppColors.primary,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _showFontTypeDialog(
    BuildContext context,
    SettingsCubit cubit,
    SettingsState settings,
  ) {
    final items = [
      {'key': 'IndoPak', 'label': 'IndoPak (Asia)'},
      {'key': 'Uthmani', 'label': 'Utsmani (Madinah)'},
    ];
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Jenis Penulisan Arabic'),
        children: items.map((item) {
          final isSelected = settings.arabicFontType == item['key'];
          return ListTile(
            leading: Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? AppColors.primary : null,
            ),
            title: Text(item['label']!),
            onTap: () {
              cubit.setArabicFontType(item['key']!);
              Navigator.pop(ctx);
            },
          );
        }).toList(),
      ),
    );
  }

  void _showFontSizeDialog(
    BuildContext context,
    String title,
    List<int> sizes,
    int currentSize,
    ValueChanged<int> onSelect,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(title),
        children: sizes.map((size) {
          final isSelected = currentSize == size;
          return ListTile(
            leading: Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? AppColors.primary : null,
            ),
            title: Text('$size px'),
            onTap: () {
              onSelect(size);
              Navigator.pop(ctx);
            },
          );
        }).toList(),
      ),
    );
  }

  void _showReciterDialog(
    BuildContext context,
    SettingsCubit cubit,
    SettingsState settings,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Pilih Qori Murattal'),
        children: _reciters.map((r) {
          final isSelected = settings.selectedReciterId == r['id'];
          return ListTile(
            leading: Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? AppColors.primary : null,
            ),
            title: Text(
              r['name'] as String,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            onTap: () {
              cubit.setReciterId(r['id'] as int);
              Navigator.pop(ctx);
            },
          );
        }).toList(),
      ),
    );
  }
}
