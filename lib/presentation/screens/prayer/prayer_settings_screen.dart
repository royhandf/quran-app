import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/local/hive_service.dart';
import '../../blocs/prayer/prayer_cubit.dart';

class PrayerSettingsScreen extends StatefulWidget {
  const PrayerSettingsScreen({super.key});
  @override
  State<PrayerSettingsScreen> createState() => _PrayerSettingsScreenState();
}

class _PrayerSettingsScreenState extends State<PrayerSettingsScreen> {
  late final HiveService _hiveService;

  static const List<Map<String, dynamic>> _methods = [
    {'id': 20, 'name': 'Kemenag - Indonesia'},
    {'id': 3, 'name': 'Muslim World League (MWL)'},
    {'id': 5, 'name': 'Egyptian General Authority'},
    {'id': 4, 'name': "Umm Al-Qura University, Makkah"},
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

  @override
  void initState() {
    super.initState();
    _hiveService = GetIt.instance<HiveService>();
  }

  String _getMethodName(int id) {
    return _methods.firstWhere(
          (m) => m['id'] == id,
          orElse: () => _methods.first,
        )['name']
        as String;
  }

  @override
  Widget build(BuildContext context) {
    final adjustment = _hiveService.getHijriAdjustment();
    final method = _hiveService.getPrayerMethod();
    final school = _hiveService.getPrayerSchool();
    final use12h = _hiveService.getUse12HourFormat();

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: Text(
          'Pengaturan Jadwal',
          style: AppTextStyles.headingSmall(context),
        ),
        backgroundColor: AppColors.background(context),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _SectionLabel(label: 'Perhitungan Jadwal Sholat'),
          _SettingsCard(
            children: [
              _SelectTile(
                icon: Icons.calculate_outlined,
                iconColor: const Color(0xFF1E88E5),
                title: 'Metode Perhitungan',
                value: _getMethodName(method),
                onTap: () => _showMethodDialog(),
              ),
              _Divider(),
              _SelectTile(
                icon: Icons.access_time_rounded,
                iconColor: const Color(0xFF43A047),
                title: 'Madzhab Ashar',
                value: school == 0 ? "Syafi'i / Maliki / Hanbali" : 'Hanafi',
                onTap: () => _showSchoolDialog(),
              ),
            ],
          ),
          const SizedBox(height: 8),

          _SectionLabel(label: 'Tanggal Hijriah'),
          _SettingsCard(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _IconBox(
                          icon: Icons.calendar_today_outlined,
                          color: const Color(0xFF7C4DFF),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Penyesuaian Tanggal Hijriah',
                                style: AppTextStyles.bodyMedium(
                                  context,
                                ).copyWith(fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                adjustment == 0
                                    ? 'Tidak ada penyesuaian'
                                    : '${adjustment > 0 ? "+" : ""}$adjustment hari dari tanggal asli',
                                style: AppTextStyles.bodySmall(context)
                                    .copyWith(
                                      color: adjustment == 0
                                          ? AppColors.textSecondary(context)
                                          : AppColors.primary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            adjustment == 0
                                ? '±0'
                                : '${adjustment > 0 ? "+" : ""}$adjustment',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text('-2', style: AppTextStyles.bodySmall(context)),
                        Expanded(
                          child: Slider(
                            value: adjustment.toDouble(),
                            min: -2,
                            max: 2,
                            divisions: 4,
                            label: adjustment == 0
                                ? '0'
                                : '${adjustment > 0 ? "+" : ""}$adjustment',
                            activeColor: AppColors.primary,
                            inactiveColor: AppColors.primary.withValues(
                              alpha: 0.2,
                            ),
                            onChanged: (v) {
                              _hiveService.setHijriAdjustment(v.toInt());
                              setState(() {});
                              _reloadPrayerTimes();
                            },
                          ),
                        ),
                        Text('+2', style: AppTextStyles.bodySmall(context)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          _SectionLabel(label: 'Lainnya'),
          _SettingsCard(
            children: [
              _SelectTile(
                icon: Icons.schedule_rounded,
                iconColor: const Color(0xFFE53935),
                title: 'Format Waktu',
                value: use12h ? '12 Jam (AM/PM)' : '24 Jam',
                onTap: () => _showTimeFormatDialog(),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showMethodDialog() {
    final currentMethod = _hiveService.getPrayerMethod();
    _showOptionsBottomSheet(
      title: 'Metode Perhitungan',
      children: _methods.map((m) {
        final isSelected = currentMethod == m['id'];
        return _OptionTile(
          label: m['name'] as String,
          isSelected: isSelected,
          onTap: () {
            _hiveService.setPrayerMethod(m['id'] as int);
            Navigator.pop(context);
            setState(() {});
            _reloadPrayerTimes();
          },
        );
      }).toList(),
    );
  }

  void _showSchoolDialog() {
    final currentSchool = _hiveService.getPrayerSchool();
    final schools = [
      {
        'id': 0,
        'name': "Syafi'i / Maliki / Hanbali",
        'sub': 'Waktu Ashar lebih awal',
      },
      {'id': 1, 'name': 'Hanafi', 'sub': 'Waktu Ashar lebih akhir'},
    ];
    _showOptionsBottomSheet(
      title: 'Madzhab Ashar',
      children: schools.map((s) {
        final isSelected = currentSchool == s['id'];
        return _OptionTile(
          label: s['name'] as String,
          subtitle: s['sub'] as String,
          isSelected: isSelected,
          onTap: () {
            _hiveService.setPrayerSchool(s['id'] as int);
            Navigator.pop(context);
            setState(() {});
            _reloadPrayerTimes();
          },
        );
      }).toList(),
    );
  }

  void _showTimeFormatDialog() {
    final current = _hiveService.getUse12HourFormat();
    final formats = [
      {'value': false, 'name': '24 Jam', 'sub': 'Contoh: 14:30'},
      {'value': true, 'name': '12 Jam (AM/PM)', 'sub': 'Contoh: 2:30 PM'},
    ];
    _showOptionsBottomSheet(
      title: 'Format Waktu',
      children: formats.map((f) {
        final isSelected = current == f['value'];
        return _OptionTile(
          label: f['name'] as String,
          subtitle: f['sub'] as String,
          isSelected: isSelected,
          onTap: () {
            _hiveService.setUse12HourFormat(f['value'] as bool);
            Navigator.pop(context);
            setState(() {});
          },
        );
      }).toList(),
    );
  }

  void _showOptionsBottomSheet({
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

  void _reloadPrayerTimes() {
    context.read<PrayerCubit>().loadPrayerTimes();
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

class _SelectTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final VoidCallback? onTap;

  const _SelectTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    this.onTap,
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
        child: Text(
          value,
          style: AppTextStyles.bodySmall(context).copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        size: 18,
        color: AppColors.textSecondary(context),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
        padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            Text(title, style: AppTextStyles.headingSmall(context)),
            const SizedBox(height: 16),
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
  final String label;
  final String? subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionTile({
    required this.label,
    this.subtitle,
    required this.isSelected,
    required this.onTap,
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
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, style: AppTextStyles.bodySmall(context)),
                  ],
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_rounded, color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}
