import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_tokens.dart';
import '../../blocs/settings/settings_cubit.dart';
import '../../blocs/settings/settings_state.dart';
import '../../widgets/sheet_shell.dart';
import '../../widgets/star_icon_container.dart';

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

  static const tajwidDotColors = [
    Color(0xFFFF7043),
    Color(0xFF66BB6A),
    Color(0xFF42A5F5),
    Color(0xFFAB47BC),
    Color(0xFFEF5350),
    Color(0xFFFFA726),
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
      backgroundColor: AppColors.homeBackground(context),
      appBar: AppBar(
        backgroundColor: AppColors.homeBackground(context),
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: AppColors.homeInk(context)),
        title: Text('Pengaturan', style: AppTokens.pageTitle(context)),
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settings) {
          final cubit = context.read<SettingsCubit>();

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppTokens.pageMargin,
              4,
              AppTokens.pageMargin,
              32,
            ),
            children: [
              const _SectionLabel('Umum'),
              _SettingsCard(
                children: [
                  _SelectTile(
                    icon: Icons.palette_outlined,
                    title: 'Mode Tema',
                    value: _themeModeLabel(settings.themeMode),
                    valueIcon: _themeModeIcon(settings.themeMode),
                    onTap: () => _showThemeModeSheet(context, cubit, settings),
                  ),
                  const _TileDivider(),
                  _SwitchRow(
                    icon: Icons.screen_lock_portrait_outlined,
                    title: 'Layar Menyala',
                    subtitle: 'Layar tidak akan mati saat membaca',
                    value: settings.keepScreenOn,
                    onChanged: cubit.toggleKeepScreenOn,
                  ),
                  const _TileDivider(),
                  _SwitchRow(
                    icon: Icons.crop_free_rounded,
                    title: 'Layar Penuh',
                    subtitle: 'Sembunyikan status bar & navigasi',
                    value: settings.fullScreen,
                    onChanged: cubit.toggleFullScreen,
                  ),
                ],
              ),
              const _SectionLabel('Audio'),
              _SettingsCard(
                children: [
                  _SelectTile(
                    icon: Icons.mic_none_rounded,
                    title: 'Qori Murattal',
                    value: _getReciterName(settings.selectedReciterId),
                    onTap: () => _showReciterSheet(context, cubit, settings),
                  ),
                ],
              ),
              const _SectionLabel('Teks Arab'),
              _SettingsCard(
                children: [
                  _SelectTile(
                    icon: Icons.edit_outlined,
                    title: 'Jenis Penulisan',
                    value: settings.arabicFontType == 'IndoPak'
                        ? 'IndoPak (Asia)'
                        : 'Utsmani (Madinah)',
                    onTap: () => _showFontTypeSheet(context, cubit, settings),
                  ),
                  const _TileDivider(),
                  _SelectTile(
                    icon: Icons.text_fields_rounded,
                    title: 'Ukuran Font',
                    value: '${settings.arabicFontSize.toInt()} px',
                    onTap: () => _showFontSizeSheet(
                      context,
                      title: 'Ukuran Font Arab',
                      sizes: const [14, 16, 18, 20, 22, 24, 26, 28, 30, 32],
                      current: settings.arabicFontSize.toInt(),
                      arabic: true,
                      onApply: (v) => cubit.setArabicFontSize(v.toDouble()),
                    ),
                  ),
                  const _TileDivider(),
                  _SwitchRow(
                    icon: Icons.tag_rounded,
                    title: 'Nomor Ayat Arab',
                    subtitle: 'Tampilkan nomor ayat dengan angka Arab',
                    value: settings.showArabicNumbers,
                    onChanged: cubit.toggleArabicNumbers,
                  ),
                  const _TileDivider(),
                  const _TajwidRow(),
                ],
              ),
              const _SectionLabel('Latin (Transliterasi)'),
              _SettingsCard(
                children: [
                  _SwitchRow(
                    icon: Icons.abc_rounded,
                    title: 'Tampilkan Latin',
                    subtitle: "Transliterasi teks Al-Qur'an",
                    value: settings.showLatin,
                    onChanged: cubit.toggleLatin,
                  ),
                  const _TileDivider(),
                  _SelectTile(
                    icon: Icons.text_fields_rounded,
                    title: 'Ukuran Font Latin',
                    value: '${settings.latinFontSize.toInt()} px',
                    enabled: settings.showLatin,
                    onTap: settings.showLatin
                        ? () => _showFontSizeSheet(
                            context,
                            title: 'Ukuran Font Latin',
                            sizes: const [10, 12, 14, 16, 18, 20, 22, 24],
                            current: settings.latinFontSize.toInt(),
                            arabic: false,
                            latinSample: true,
                            onApply: (v) =>
                                cubit.setLatinFontSize(v.toDouble()),
                          )
                        : null,
                  ),
                ],
              ),
              const _SectionLabel('Terjemahan'),
              _SettingsCard(
                children: [
                  _SwitchRow(
                    icon: Icons.menu_book_rounded,
                    title: 'Tampilkan Terjemahan',
                    subtitle: 'Terjemahan Bahasa Indonesia',
                    value: settings.showTranslation,
                    onChanged: cubit.toggleTranslation,
                  ),
                  const _TileDivider(),
                  _SelectTile(
                    icon: Icons.text_fields_rounded,
                    title: 'Ukuran Font Terjemahan',
                    value: '${settings.translationFontSize.toInt()} px',
                    enabled: settings.showTranslation,
                    onTap: settings.showTranslation
                        ? () => _showFontSizeSheet(
                            context,
                            title: 'Ukuran Font Terjemahan',
                            sizes: const [10, 12, 14, 16, 18, 20, 22, 24],
                            current: settings.translationFontSize.toInt(),
                            arabic: false,
                            onApply: (v) =>
                                cubit.setTranslationFontSize(v.toDouble()),
                          )
                        : null,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  void _showThemeModeSheet(
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => SheetShell(
        title: 'Mode Tema',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: items.map((item) {
            final mode = item['mode'] as ThemeMode;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SheetOptionTile(
                icon: item['icon'] as IconData,
                label: item['label'] as String,
                selected: settings.themeMode == mode,
                onTap: () {
                  cubit.setThemeMode(mode);
                  Navigator.pop(sheetContext);
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showReciterSheet(
    BuildContext context,
    SettingsCubit cubit,
    SettingsState settings,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => SheetShell(
        title: 'Qori Murattal',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _reciters.map((r) {
            final id = r['id'] as int;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SheetOptionTile(
                label: r['name'] as String,
                selected: settings.selectedReciterId == id,
                onTap: () {
                  cubit.setReciterId(id);
                  Navigator.pop(sheetContext);
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showFontTypeSheet(
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
        'font': 'Lateef',
      },
      {
        'key': 'Uthmani',
        'label': 'Utsmani',
        'sub': 'Standar Mushaf Madinah',
        'preview': 'بِسۡمِ ٱللَّهِ',
        'font': 'ScheherazadeNew',
      },
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => SheetShell(
        title: 'Jenis Penulisan Arab',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: items.map((item) {
            final isSelected = settings.arabicFontType == item['key'];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SheetOptionTile(
                label: item['label'] as String,
                subtitle: item['sub'] as String,
                selected: isSelected,
                onTap: () {
                  cubit.setArabicFontType(item['key'] as String);
                  Navigator.pop(sheetContext);
                },
                trailingPreview: Text(
                  item['preview'] as String,
                  style: TextStyle(
                    fontFamily: item['font'] as String,
                    fontSize: 20,
                    color: isSelected
                        ? Colors.white
                        : AppColors.homeInk(context),
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showFontSizeSheet(
    BuildContext context, {
    required String title,
    required List<int> sizes,
    required int current,
    required bool arabic,
    required ValueChanged<int> onApply,
    bool latinSample = false,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _FontSizeSheet(
        title: title,
        sizes: sizes,
        current: current,
        arabic: arabic,
        latinSample: latinSample,
        onApply: onApply,
      ),
    );
  }
}

class _FontSizeSheet extends StatefulWidget {
  final String title;
  final List<int> sizes;
  final int current;
  final bool arabic;
  final bool latinSample;
  final ValueChanged<int> onApply;

  const _FontSizeSheet({
    required this.title,
    required this.sizes,
    required this.current,
    required this.arabic,
    required this.latinSample,
    required this.onApply,
  });

  @override
  State<_FontSizeSheet> createState() => _FontSizeSheetState();
}

class _FontSizeSheetState extends State<_FontSizeSheet> {
  late int _selected = widget.current;

  void _change(int newSize) {
    if (widget.sizes.contains(newSize)) {
      setState(() => _selected = newSize);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SheetShell(
      title: widget.title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PreviewBox(
            child: widget.arabic
                ? FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: _selected.toDouble(),
                        color: AppColors.homeArabicSecondary(context),
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  )
                : Text(
                    widget.latinSample
                        ? 'Bismillāhirraḥmānirraḥīm'
                        : 'Dengan nama Allah Yang Maha Pengasih, Maha Penyayang.',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: _selected.toDouble(),
                      color: AppColors.homeInk(context),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _StepButton(
                icon: Icons.remove_rounded,
                onTap: () {
                  final idx = widget.sizes.indexOf(_selected);
                  if (idx > 0) _change(widget.sizes[idx - 1]);
                },
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '$_selected px',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.homeInk(context),
                    ),
                  ),
                ),
              ),
              _StepButton(
                icon: Icons.add_rounded,
                onTap: () {
                  final idx = widget.sizes.indexOf(_selected);
                  if (idx < widget.sizes.length - 1) {
                    _change(widget.sizes[idx + 1]);
                  }
                },
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              activeTrackColor: AppColors.forest,
              inactiveTrackColor: AppColors.homeOptionSurface(context),
              thumbColor: AppColors.forest,
              overlayColor: AppColors.forest.withValues(alpha: 0.15),
              valueIndicatorColor: AppColors.forest,
            ),
            child: Slider(
              value: widget.sizes.indexOf(_selected).toDouble(),
              min: 0,
              max: (widget.sizes.length - 1).toDouble(),
              divisions: widget.sizes.length - 1,
              label: '$_selected px',
              onChanged: (v) => _change(widget.sizes[v.round()]),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${widget.sizes.first} px',
                style: AppTokens.tileSubtitle(context),
              ),
              Text(
                '${widget.sizes.last} px',
                style: AppTokens.tileSubtitle(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                widget.onApply(_selected);
                Navigator.pop(context);
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.forest,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTokens.buttonRadius),
                ),
              ),
              child: const Text(
                'Selesai',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 20, bottom: 8),
      child: Text(text.toUpperCase(), style: AppTokens.cardLabel(context)),
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
        color: AppColors.homeSurface(context),
        borderRadius: BorderRadius.circular(AppTokens.cardRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _TileDivider extends StatelessWidget {
  const _TileDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 74),
      child: Divider(height: 1, color: AppColors.homeDivider(context)),
    );
  }
}

class _SelectTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? value;
  final IconData? valueIcon;
  final bool enabled;
  final VoidCallback? onTap;

  const _SelectTile({
    required this.icon,
    required this.title,
    required this.value,
    this.valueIcon,
    this.enabled = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          child: Container(
            constraints: const BoxConstraints(minHeight: 72),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                StarIconContainer(
                  icon: icon,
                  containerColor: AppColors.homeStarSecondary(context),
                  iconColor: AppColors.homeArabicSecondary(context),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: AppTokens.tileTitle(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 10),
                if (valueIcon != null) ...[
                  Icon(
                    valueIcon,
                    size: 16,
                    color: AppColors.homeArabicSecondary(context),
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  value ?? '',
                  style: AppTokens.tileValue(context),
                  maxLines: 1,
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: AppColors.homeInkSecondary(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Container(
        constraints: const BoxConstraints(minHeight: 72),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            StarIconContainer(
              icon: icon,
              containerColor: AppColors.homeStarSecondary(context),
              iconColor: AppColors.homeArabicSecondary(context),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppTokens.tileTitle(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTokens.tileSubtitle(context),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: AppColors.forest,
            ),
          ],
        ),
      ),
    );
  }
}

class _TajwidRow extends StatelessWidget {
  const _TajwidRow();

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.55,
      child: Container(
        constraints: const BoxConstraints(minHeight: 72),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            StarIconContainer(
              icon: Icons.auto_awesome_outlined,
              containerColor: AppColors.homeStarSecondary(context),
              iconColor: AppColors.homeArabicSecondary(context),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          'Tajwid Berwarna',
                          style: AppTokens.tileTitle(context),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          'Segera Hadir',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.gold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: SettingsScreen.tajwidDotColors
                        .map(
                          (c) => Container(
                            width: 10,
                            height: 10,
                            margin: const EdgeInsets.only(right: 4),
                            decoration: BoxDecoration(
                              color: c,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewBox extends StatelessWidget {
  final Widget child;

  const _PreviewBox({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 130,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.homeOptionSurface(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _StepButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.homeOptionSurface(context),
      borderRadius: BorderRadius.circular(AppTokens.buttonRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTokens.buttonRadius),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(icon, size: 22, color: AppColors.homeInk(context)),
        ),
      ),
    );
  }
}
