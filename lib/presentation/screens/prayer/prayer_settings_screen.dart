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

  // Daftar metode dari API Aladhan
  static const List<Map<String, dynamic>> _methods = [
    {'id': 20, 'name': 'Kemenag - Indonesia'},
    {'id': 3, 'name': 'Muslim World League (MWL)'},
    {'id': 5, 'name': 'Egyptian General Authority'},
    {'id': 4, 'name': 'Umm Al-Qura University, Makkah'},
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
    return Scaffold(
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
        children: [
          // === PERHITUNGAN JADWAL SHOLAT ===
          _section(context, 'Perhitungan Jadwal Sholat'),

          _tile(
            context,
            'Metode Perhitungan',
            _getMethodName(_hiveService.getPrayerMethod()),
            onTap: () => _showMethodDialog(),
          ),

          _tile(
            context,
            'Madzhab Ashar',
            _hiveService.getPrayerSchool() == 0
                ? "Syafi'i / Maliki / Hanbali"
                : 'Hanafi',
            onTap: () => _showSchoolDialog(),
          ),

          _divider(context),

          // === TANGGAL HIJRIAH ===
          _section(context, 'Tanggal Hijriah'),

          _buildHijriSlider(context),

          _divider(context),

          // === LAINNYA ===
          _section(context, 'Lainnya'),

          _tile(
            context,
            'Format Waktu',
            _hiveService.getUse12HourFormat() ? '12 Jam (AM/PM)' : '24 Jam',
            onTap: () => _showTimeFormatDialog(),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, String title) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
    child: Text(title, style: AppTextStyles.sectionHeader(context)),
  );

  Widget _divider(BuildContext context) =>
      Divider(height: 1, thickness: 6, color: AppColors.background(context));

  Widget _tile(
    BuildContext context,
    String title,
    String subtitle, {
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
    trailing: onTap != null
        ? Icon(Icons.chevron_right, color: AppColors.textSecondary(context))
        : null,
    onTap: onTap,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
  );

  Widget _buildHijriSlider(BuildContext context) {
    final adjustment = _hiveService.getHijriAdjustment();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Penyesuaian Tanggal Hijriah',
            style: AppTextStyles.bodyLarge(
              context,
            ).copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            adjustment == 0
                ? 'Tidak ada penyesuaian'
                : '${adjustment > 0 ? "+" : ""}$adjustment hari',
            style: AppTextStyles.bodySmall(context),
          ),
          Slider(
            value: adjustment.toDouble(),
            min: -2,
            max: 2,
            divisions: 4,
            label: adjustment == 0
                ? '0'
                : '${adjustment > 0 ? "+" : ""}$adjustment',
            activeColor: AppColors.primary,
            onChanged: (v) {
              _hiveService.setHijriAdjustment(v.toInt());
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  void _showMethodDialog() {
    final currentMethod = _hiveService.getPrayerMethod();
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Metode Perhitungan'),
        children: _methods.map((m) {
          final isSelected = currentMethod == m['id'];
          return ListTile(
            leading: Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? AppColors.primary : null,
            ),
            title: Text(
              m['name'] as String,
              style: const TextStyle(fontSize: 14),
            ),
            onTap: () {
              _hiveService.setPrayerMethod(m['id'] as int);
              Navigator.pop(ctx);
              setState(() {});
              _reloadPrayerTimes();
            },
          );
        }).toList(),
      ),
    );
  }

  void _showSchoolDialog() {
    final currentSchool = _hiveService.getPrayerSchool();
    final schools = [
      {'id': 0, 'name': "Syafi'i / Maliki / Hanbali"},
      {'id': 1, 'name': 'Hanafi'},
    ];
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Madzhab Ashar'),
        children: schools.map((s) {
          final isSelected = currentSchool == s['id'];
          return ListTile(
            leading: Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? AppColors.primary : null,
            ),
            title: Text(s['name'] as String),
            onTap: () {
              _hiveService.setPrayerSchool(s['id'] as int);
              Navigator.pop(ctx);
              setState(() {});
              _reloadPrayerTimes();
            },
          );
        }).toList(),
      ),
    );
  }

  void _showTimeFormatDialog() {
    final current = _hiveService.getUse12HourFormat();
    final formats = [
      {'value': false, 'name': '24 Jam (14:30)'},
      {'value': true, 'name': '12 Jam (2:30 PM)'},
    ];
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Format Waktu'),
        children: formats.map((f) {
          final isSelected = current == f['value'];
          return ListTile(
            leading: Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? AppColors.primary : null,
            ),
            title: Text(f['name'] as String),
            onTap: () {
              _hiveService.setUse12HourFormat(f['value'] as bool);
              Navigator.pop(ctx);
              setState(() {});
            },
          );
        }).toList(),
      ),
    );
  }

  void _reloadPrayerTimes() {
    context.read<PrayerCubit>().loadPrayerTimes();
  }
}
