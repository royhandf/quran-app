import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_tokens.dart';
import '../../blocs/prayer/prayer_cubit.dart';
import '../../widgets/sheet_shell.dart';
import '../../widgets/star_icon_container.dart';

class PrayerSettingsScreen extends StatefulWidget {
  const PrayerSettingsScreen({super.key});

  @override
  State<PrayerSettingsScreen> createState() => _PrayerSettingsScreenState();
}

class _PrayerSettingsScreenState extends State<PrayerSettingsScreen> {
  static const List<Map<String, dynamic>> _methods = [
    {'id': 20, 'name': 'Kemenag - Indonesia'},
    {'id': 3, 'name': 'Muslim World League (MWL)'},
    {'id': 5, 'name': 'Egyptian General Authority'},
    {'id': 4, 'name': 'Umm al-Qura University, Makkah'},
    {'id': 2, 'name': 'ISNA - Islamic Society of North America'},
    {'id': 1, 'name': 'University of Islamic Sciences, Karachi'},
    {'id': 7, 'name': 'Institute of Geophysics, University of Tehran'},
    {'id': 8, 'name': 'Gulf Region'},
    {'id': 9, 'name': 'Kuwait'},
    {'id': 10, 'name': 'Qatar'},
    {'id': 11, 'name': 'Majlis Ugama Islam Singapura'},
    {'id': 14, 'name': 'JAKIM - Malaysia'},
    {'id': 15, 'name': 'MUIS - Tunisia'},
    {'id': 16, 'name': 'UOIF - France'},
  ];

  String _getMethodName(int id) {
    return _methods.firstWhere(
      (m) => m['id'] == id,
      orElse: () => _methods.first,
    )['name']
        as String;
  }

  void _reloadPrayerTimes() {
    context.read<PrayerCubit>().loadPrayerTimes();
  }

  void _showMethodSheet(int currentMethod) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => SheetShell(
        title: 'Metode Perhitungan',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _methods.map((m) {
            final id = m['id'] as int;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SheetOptionTile(
                label: m['name'] as String,
                selected: currentMethod == id,
                onTap: () {
                  context.read<PrayerCubit>().setPrayerMethod(id);
                  Navigator.pop(sheetContext);
                  _reloadPrayerTimes();
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showSchoolSheet(int currentSchool) {
    final schools = [
      {
        'id': 0,
        'name': "Syafi'i / Maliki / Hanbali",
        'sub': 'Waktu Ashar lebih awal',
      },
      {'id': 1, 'name': 'Hanafi', 'sub': 'Waktu Ashar lebih akhir'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => SheetShell(
        title: 'Madzhab Ashar',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: schools.map((s) {
            final id = s['id'] as int;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SheetOptionTile(
                label: s['name'] as String,
                subtitle: s['sub'] as String,
                selected: currentSchool == id,
                onTap: () {
                  context.read<PrayerCubit>().setPrayerSchool(id);
                  Navigator.pop(sheetContext);
                  _reloadPrayerTimes();
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showTimeFormatSheet(bool currentUse12h) {
    final formats = [
      {'value': false, 'name': '24 Jam', 'sub': 'Contoh: 14:30'},
      {'value': true, 'name': '12 Jam (AM/PM)', 'sub': 'Contoh: 2:30 PM'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => SheetShell(
        title: 'Format Waktu',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: formats.map((f) {
            final value = f['value'] as bool;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SheetOptionTile(
                label: f['name'] as String,
                subtitle: f['sub'] as String,
                selected: currentUse12h == value,
                onTap: () {
                  context.read<PrayerCubit>().setUse12HourFormat(value);
                  Navigator.pop(sheetContext);
                  setState(() {});
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PrayerCubit>();
    final adjustment = cubit.hijriAdjustment;
    final method = cubit.prayerMethod;
    final school = cubit.prayerSchool;
    final use12h = cubit.use12HourFormat;

    return Scaffold(
      backgroundColor: AppColors.homeBackground(context),
      appBar: AppBar(
        backgroundColor: AppColors.homeBackground(context),
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: AppColors.homeInk(context)),
        title: Text('Pengaturan Jadwal', style: AppTokens.pageTitle(context)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppTokens.pageMargin,
          4,
          AppTokens.pageMargin,
          32,
        ),
        children: [
          const _SectionLabel('Perhitungan Jadwal Sholat'),
          _SettingsCard(
            children: [
              _SelectRow(
                icon: Icons.calendar_month_rounded,
                title: 'Metode Perhitungan',
                value: _getMethodName(method),
                onTap: () => _showMethodSheet(method),
              ),
              const _TileDivider(),
              _SelectRow(
                icon: Icons.self_improvement_rounded,
                title: 'Madzhab Ashar',
                value: school == 0 ? "Syafi'i / Maliki / Hanbali" : 'Hanafi',
                onTap: () => _showSchoolSheet(school),
              ),
            ],
          ),
          const _SectionLabel('Tanggal Hijriah'),
          _SettingsCard(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        StarIconContainer(
                          icon: Icons.calendar_today_rounded,
                          containerColor:
                              AppColors.homeStarSecondary(context),
                          iconColor: AppColors.homeArabicSecondary(context),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Penyesuaian Tanggal Hijriah',
                                style: AppTokens.tileTitle(context),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                adjustment == 0
                                    ? 'Tidak ada penyesuaian'
                                    : '${adjustment > 0 ? "+" : ""}$adjustment hari dari tanggal asli',
                                style: AppTokens.tileSubtitle(context),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.homeStarSecondary(context),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            adjustment == 0
                                ? '±0'
                                : '${adjustment > 0 ? "+" : ""}$adjustment',
                            style: TextStyle(
                              fontFamily: AppTokens.fontLatin,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.homeInk(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 4,
                        activeTrackColor: AppColors.forest,
                        inactiveTrackColor:
                            AppColors.homeOptionSurface(context),
                        thumbColor: AppColors.forest,
                        overlayColor: AppColors.forest.withValues(alpha: 0.15),
                      ),
                      child: Slider(
                        value: adjustment.toDouble(),
                        min: -2,
                        max: 2,
                        divisions: 4,
                        label: adjustment == 0
                            ? '0'
                            : '${adjustment > 0 ? "+" : ""}$adjustment',
                        onChanged: (v) {
                          context
                              .read<PrayerCubit>()
                              .setHijriAdjustment(v.toInt());
                          setState(() {});
                          _reloadPrayerTimes();
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('-2', style: AppTokens.tileSubtitle(context)),
                        Text('+2', style: AppTokens.tileSubtitle(context)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const _SectionLabel('Lainnya'),
          _SettingsCard(
            children: [
              _SelectRow(
                icon: Icons.schedule_rounded,
                title: 'Format Waktu',
                value: use12h ? '12 Jam (AM/PM)' : '24 Jam',
                onTap: () => _showTimeFormatSheet(use12h),
              ),
            ],
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

class _SelectRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback? onTap;

  const _SelectRow({
    required this.icon,
    required this.title,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
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
                      value,
                      style: AppTokens.tileValue(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.homeInkSecondary(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
