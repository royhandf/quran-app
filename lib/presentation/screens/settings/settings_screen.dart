import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../blocs/settings/settings_cubit.dart';
import '../../blocs/settings/settings_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const List<Map<String, dynamic>> _reciters = [
    {'id': 5, 'name': 'Misyari Rasyid Al-Afasi'},
    {'id': 1, 'name': 'Abdullah Al-Juhany'},
    {'id': 2, 'name': 'Abdul-Muhsin Al-Qasim'},
    {'id': 3, 'name': 'Abdurrahman as-Sudais'},
    {'id': 4, 'name': 'Ibrahim Al-Dossari'},
    {'id': 6, 'name': 'Yasser Al-Dosari'},
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

  IconData _themeModeIcon(ThemeMode mode) => switch (mode) {
    ThemeMode.light => Icons.light_mode_rounded,
    ThemeMode.dark => Icons.dark_mode_rounded,
    ThemeMode.system => Icons.brightness_auto_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: Text('Pengaturan', style: AppTextStyles.headingSmall(context)),
        backgroundColor: AppColors.background(context),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settings) {
          final cubit = context.read<SettingsCubit>();

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              _SectionLabel(label: 'Umum'),
              _SettingsCard(
                children: [
                  _SelectTile(
                    icon: Icons.palette_outlined,
                    iconColor: const Color(0xFF7C4DFF),
                    title: 'Mode Tema',
                    value: _themeModeLabel(settings.themeMode),
                    valueIcon: _themeModeIcon(settings.themeMode),
                    onTap: () => _showThemeModeDialog(context, cubit, settings),
                  ),
                  _Divider(),
                  _SwitchTile(
                    icon: Icons.screen_lock_portrait_outlined,
                    iconColor: const Color(0xFF00897B),
                    title: 'Layar Menyala',
                    subtitle: 'Layar tidak akan mati saat membaca',
                    value: settings.keepScreenOn,
                    onChanged: cubit.toggleKeepScreenOn,
                  ),
                  _Divider(),
                  _SwitchTile(
                    icon: Icons.fullscreen_rounded,
                    iconColor: const Color(0xFF1E88E5),
                    title: 'Layar Penuh',
                    subtitle: 'Sembunyikan status bar & navigasi',
                    value: settings.fullScreen,
                    onChanged: cubit.toggleFullScreen,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              _SectionLabel(label: 'Audio'),
              _SettingsCard(
                children: [
                  _SelectTile(
                    icon: Icons.mic_none_rounded,
                    iconColor: const Color(0xFFE53935),
                    title: 'Qori Murattal',
                    value: _getReciterName(settings.selectedReciterId),
                    onTap: () => _showReciterDialog(context, cubit, settings),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              _SectionLabel(label: 'Teks Arab'),
              _SettingsCard(
                children: [
                  _SelectTile(
                    icon: Icons.translate_rounded,
                    iconColor: const Color(0xFF43A047),
                    title: 'Jenis Penulisan',
                    value: settings.arabicFontType == 'IndoPak'
                        ? 'IndoPak (Asia)'
                        : 'Utsmani (Madinah)',
                    onTap: () => _showFontTypeDialog(context, cubit, settings),
                  ),
                  _Divider(),
                  _SelectTile(
                    icon: Icons.format_size_rounded,
                    iconColor: const Color(0xFFFB8C00),
                    title: 'Ukuran Font',
                    value: '${settings.arabicFontSize.toInt()} px',
                    onTap: () => _showFontSizeDialog(
                      context,
                      'Ukuran Font Arab',
                      [14, 16, 18, 20, 22, 24, 26, 28, 30, 32],
                      settings.arabicFontSize.toInt(),
                      (v) => cubit.setArabicFontSize(v.toDouble()),
                    ),
                  ),
                  _Divider(),
                  _SwitchTile(
                    icon: Icons.tag_rounded,
                    iconColor: const Color(0xFF8E24AA),
                    title: 'Nomor Ayat Arab',
                    subtitle: 'Tampilkan nomor ayat dengan angka Arab',
                    value: settings.showArabicNumbers,
                    onChanged: cubit.toggleArabicNumbers,
                  ),
                  _Divider(),
                  _TajwidTile(
                    settings: settings,
                    cubit: cubit,
                    onTap: () => _showTajwidDialog(context, cubit),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              _SectionLabel(label: 'Latin (Transliterasi)'),
              _SettingsCard(
                children: [
                  _SwitchTile(
                    icon: Icons.abc_rounded,
                    iconColor: const Color(0xFF00ACC1),
                    title: 'Tampilkan Latin',
                    subtitle: 'Transliterasi teks Al-Qur\'an',
                    value: settings.showLatin,
                    onChanged: cubit.toggleLatin,
                  ),
                  _Divider(),
                  _SelectTile(
                    icon: Icons.format_size_rounded,
                    iconColor: const Color(0xFF00ACC1),
                    title: 'Ukuran Font Latin',
                    value: '${settings.latinFontSize.toInt()} px',
                    enabled: settings.showLatin,
                    onTap: settings.showLatin
                        ? () => _showFontSizeDialog(
                            context,
                            'Ukuran Font Latin',
                            [10, 12, 14, 16, 18, 20, 22, 24],
                            settings.latinFontSize.toInt(),
                            (v) => cubit.setLatinFontSize(v.toDouble()),
                          )
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              _SectionLabel(label: 'Terjemahan'),
              _SettingsCard(
                children: [
                  _SwitchTile(
                    icon: Icons.menu_book_rounded,
                    iconColor: const Color(0xFFD81B60),
                    title: 'Tampilkan Terjemahan',
                    subtitle: 'Terjemahan Bahasa Indonesia',
                    value: settings.showTranslation,
                    onChanged: cubit.toggleTranslation,
                  ),
                  _Divider(),
                  _SelectTile(
                    icon: Icons.format_size_rounded,
                    iconColor: const Color(0xFFD81B60),
                    title: 'Ukuran Font Terjemahan',
                    value: '${settings.translationFontSize.toInt()} px',
                    enabled: settings.showTranslation,
                    onTap: settings.showTranslation
                        ? () => _showFontSizeDialog(
                            context,
                            'Ukuran Font Terjemahan',
                            [10, 12, 14, 16, 18, 20, 22, 24],
                            settings.translationFontSize.toInt(),
                            (v) => cubit.setTranslationFontSize(v.toDouble()),
                          )
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  void _showThemeModeDialog(
    BuildContext context,
    SettingsCubit cubit,
    SettingsState settings,
  ) {
    final items = [
      {
        'mode': ThemeMode.light,
        'label': 'Terang',
        'icon': Icons.light_mode_rounded,
      },
      {
        'mode': ThemeMode.dark,
        'label': 'Gelap',
        'icon': Icons.dark_mode_rounded,
      },
      {
        'mode': ThemeMode.system,
        'label': 'Ikuti Sistem',
        'icon': Icons.brightness_auto_rounded,
      },
    ];
    _showOptionDialog(
      context: context,
      title: 'Mode Tema',
      children: items.map((item) {
        final mode = item['mode'] as ThemeMode;
        final isSelected = settings.themeMode == mode;
        return _OptionTile(
          icon: item['icon'] as IconData,
          label: item['label'] as String,
          isSelected: isSelected,
          onTap: () {
            cubit.setThemeMode(mode);
            Navigator.pop(context);
          },
        );
      }).toList(),
    );
  }

  void _showTajwidDialog(BuildContext context, SettingsCubit cubit) {
    final tajwidRules = [
      {
        'key': 'ghunnah',
        'name': 'Ghunnah',
        'color': const Color(0xFFFF7043),
        'desc': 'Dengung (nun/mim tasydid)',
      },
      {
        'key': 'ikhfa',
        'name': 'Ikhfa',
        'color': const Color(0xFF66BB6A),
        'desc': 'Samar (nun sukun/tanwin)',
      },
      {
        'key': 'idgham',
        'name': 'Idgham',
        'color': const Color(0xFF42A5F5),
        'desc': 'Memasukkan (nun sukun/tanwin)',
      },
      {
        'key': 'iqlab',
        'name': 'Iqlab',
        'color': const Color(0xFFAB47BC),
        'desc': 'Menukar nun ke mim',
      },
      {
        'key': 'qalqalah',
        'name': 'Qalqalah',
        'color': const Color(0xFFEF5350),
        'desc': 'Memantulkan (huruf qalqalah)',
      },
      {
        'key': 'madLazim',
        'name': 'Mad Lazim',
        'color': const Color(0xFFFFA726),
        'desc': 'Mad panjang wajib (6 harakat)',
      },
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (ctx, state) {
            Map<String, bool> valueMap = {
              'ghunnah': state.tajwidGhunnah,
              'ikhfa': state.tajwidIkhfa,
              'idgham': state.tajwidIdgham,
              'iqlab': state.tajwidIqlab,
              'qalqalah': state.tajwidQalqalah,
              'madLazim': state.tajwidMadLazim,
            };
            Map<String, ValueChanged<bool>> toggleMap = {
              'ghunnah': cubit.toggleTajwidGhunnah,
              'ikhfa': cubit.toggleTajwidIkhfa,
              'idgham': cubit.toggleTajwidIdgham,
              'iqlab': cubit.toggleTajwidIqlab,
              'qalqalah': cubit.toggleTajwidQalqalah,
              'madLazim': cubit.toggleTajwidMadLazim,
            };

            return _BottomSheet(
              title: 'Tajwid Berwarna',
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: state.tajwidColored
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : AppColors.card(ctx),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: state.tajwidColored
                            ? AppColors.primary.withValues(alpha: 0.4)
                            : Colors.transparent,
                      ),
                    ),
                    child: SwitchListTile(
                      title: Text(
                        'Aktifkan Tajwid Berwarna',
                        style: AppTextStyles.bodyMedium(
                          ctx,
                        ).copyWith(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        'Warnai huruf sesuai hukum tajwid',
                        style: AppTextStyles.bodySmall(ctx),
                      ),
                      value: state.tajwidColored,
                      onChanged: cubit.toggleTajwidColored,
                      activeThumbColor: AppColors.primary,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                    ),
                  ),

                  AnimatedOpacity(
                    opacity: state.tajwidColored ? 1.0 : 0.35,
                    duration: const Duration(milliseconds: 200),
                    child: AbsorbPointer(
                      absorbing: !state.tajwidColored,
                      child: Column(
                        children: tajwidRules.map((rule) {
                          final key = rule['key'] as String;
                          final color = rule['color'] as Color;
                          final isOn = valueMap[key] ?? true;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: AppColors.card(ctx),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: color,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                ),
                              ),
                              title: Text(
                                rule['name'] as String,
                                style: AppTextStyles.bodyMedium(
                                  ctx,
                                ).copyWith(fontWeight: FontWeight.w500),
                              ),
                              subtitle: Text(
                                rule['desc'] as String,
                                style: AppTextStyles.bodySmall(ctx),
                              ),
                              trailing: Switch(
                                value: isOn,
                                onChanged: toggleMap[key]!,
                                activeThumbColor: color,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 2,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showFontTypeDialog(
    BuildContext context,
    SettingsCubit cubit,
    SettingsState settings,
  ) {
    final items = [
      {
        'key': 'IndoPak',
        'label': 'IndoPak',
        'sub': 'Dipakai di Asia Selatan & Tenggara',
        'preview': 'بِسْمِ اللّٰهِ',
      },
      {
        'key': 'Uthmani',
        'label': 'Utsmani',
        'sub': 'Standar Mushaf Madinah',
        'preview': 'بِسۡمِ ٱللَّهِ',
      },
    ];

    _showOptionDialog(
      context: context,
      title: 'Jenis Penulisan Arab',
      children: items.map((item) {
        final isSelected = settings.arabicFontType == item['key'];
        return _OptionTile(
          label: item['label'] as String,
          subtitle: item['sub'] as String,
          isSelected: isSelected,
          trailing: Text(
            item['preview'] as String,
            style: TextStyle(
              fontFamily: item['key'] == 'IndoPak'
                  ? 'Lateef'
                  : 'ScheherazadeNew',
              fontSize: 20,
              color: isSelected
                  ? AppColors.primary
                  : AppColors.textSecondary(context),
            ),
          ),
          onTap: () {
            cubit.setArabicFontType(item['key']!);
            Navigator.pop(context);
          },
        );
      }).toList(),
    );
  }

  void _showFontSizeDialog(
    BuildContext context,
    String title,
    List<int> sizes,
    int currentSize,
    ValueChanged<int> onSelect,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _BottomSheet(
        title: title,
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: sizes.map((size) {
            final isSelected = currentSize == size;
            return GestureDetector(
              onTap: () {
                onSelect(size);
                Navigator.pop(ctx);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 72,
                height: 56,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.card(ctx),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.dividerColor(ctx),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$size',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textPrimary(ctx),
                      ),
                    ),
                    Text(
                      'px',
                      style: TextStyle(
                        fontSize: 10,
                        color: isSelected
                            ? Colors.white70
                            : AppColors.textSecondary(ctx),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showReciterDialog(
    BuildContext context,
    SettingsCubit cubit,
    SettingsState settings,
  ) {
    _showOptionDialog(
      context: context,
      title: 'Pilih Qori Murattal',
      children: _reciters.map((r) {
        final isSelected = settings.selectedReciterId == r['id'];
        return _OptionTile(
          label: r['name'] as String,
          isSelected: isSelected,
          onTap: () {
            cubit.setReciterId(r['id'] as int);
            Navigator.pop(context);
          },
        );
      }).toList(),
    );
  }



  void _showOptionDialog({
    required BuildContext context,
    required String title,
    required List<Widget> children,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _BottomSheet(
        title: title,
        child: Column(mainAxisSize: MainAxisSize.min, children: children),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 8),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.sectionHeader(context).copyWith(fontSize: 11),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 56,
      color: AppColors.dividerColor(context),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _IconBox(icon: icon, color: iconColor),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium(
          context,
        ).copyWith(fontWeight: FontWeight.w500),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Text(subtitle, style: AppTextStyles.bodySmall(context)),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.primary,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}

class _SelectTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final IconData? valueIcon;
  final VoidCallback? onTap;
  final bool enabled;

  const _SelectTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    this.valueIcon,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _IconBox(
        icon: icon,
        color: enabled ? iconColor : AppColors.textSecondary(context),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium(context).copyWith(
          fontWeight: FontWeight.w500,
          color: enabled ? null : AppColors.textSecondary(context),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (valueIcon != null) ...[
            Icon(valueIcon, size: 16, color: AppColors.textSecondary(context)),
            const SizedBox(width: 4),
          ],
          Text(
            value,
            style: AppTextStyles.bodySmall(context).copyWith(
              color: enabled
                  ? AppColors.primary
                  : AppColors.textSecondary(context),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.chevron_right_rounded,
            size: 18,
            color: enabled
                ? AppColors.textSecondary(context)
                : AppColors.textSecondary(context).withValues(alpha: 0.4),
          ),
        ],
      ),
      onTap: enabled ? onTap : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}

class _TajwidTile extends StatelessWidget {
  final SettingsState settings;
  final SettingsCubit cubit;
  final VoidCallback onTap;

  const _TajwidTile({
    required this.settings,
    required this.cubit,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      const Color(0xFFFF7043),
      const Color(0xFF66BB6A),
      const Color(0xFF42A5F5),
      const Color(0xFFAB47BC),
      const Color(0xFFEF5350),
      const Color(0xFFFFA726),
    ];

    return Opacity(
      opacity: 0.5,
      child: ListTile(
        leading: _IconBox(
          icon: Icons.color_lens_outlined,
          color: const Color(0xFF7986CB),
        ),
        title: Row(
          children: [
            Text(
              'Tajwid Berwarna',
              style: AppTextStyles.bodyMedium(
                context,
              ).copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Text(
                'Segera Hadir',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              ...colors.map(
                (c) => Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    color: c.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          size: 18,
          color: AppColors.textSecondary(context),
        ),
        onTap: null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _IconBox({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 20, color: color),
    );
  }
}

class _BottomSheet extends StatelessWidget {
  final String title;
  final Widget child;

  const _BottomSheet({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final bottomPadding =
        MediaQuery.of(context).viewInsets.bottom +
        MediaQuery.of(context).padding.bottom +
        16;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle — selalu di atas
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.dividerColor(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Judul — selalu di atas
            Text(title, style: AppTextStyles.headingSmall(context)),
            const SizedBox(height: 16),
            // Konten — scrollable jika overflow
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(bottom: bottomPadding),
                  child: child,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData? icon;
  final String label;
  final String? subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget? trailing;

  const _OptionTile({
    this.icon,
    required this.label,
    this.subtitle,
    required this.isSelected,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.card(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.5)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20, color: AppColors.textSecondary(context)),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.bodyMedium(context).copyWith(
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary(context),
                    ),
                  ),
                  if (subtitle != null)
                    Text(subtitle!, style: AppTextStyles.bodySmall(context)),
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing!,
            ] else if (isSelected)
              Icon(Icons.check_rounded, color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}
