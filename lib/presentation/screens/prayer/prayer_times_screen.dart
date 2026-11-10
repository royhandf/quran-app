import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_tokens.dart';
import '../../../data/models/prayer_time.dart';
import '../../blocs/prayer/prayer_cubit.dart';
import '../../blocs/prayer/prayer_state.dart';
import '../../widgets/home/prayer_card.dart';
import '../../widgets/sheet_shell.dart';
import '../../widgets/star_icon_container.dart';
import 'prayer_settings_screen.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  DateTime? _viewedDate;

  bool get _isToday {
    final v = _viewedDate;
    if (v == null) return true;
    final now = DateTime.now();
    return v.year == now.year && v.month == now.month && v.day == now.day;
  }

  void _refreshToday() {
    setState(() => _viewedDate = null);
    context.read<PrayerCubit>().loadPrayerTimes();
  }

  void _openDateSheet() {
    final cubit = context.read<PrayerCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) =>
          _DateSheet(initialDate: _viewedDate ?? DateTime.now()),
    ).then((picked) {
      if (picked is! DateTime) return;
      if (!mounted) return;
      setState(() => _viewedDate = picked);
      cubit.loadPrayerTimesByDate(picked);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PrayerCubit>();

    return Scaffold(
      backgroundColor: AppColors.homeBackground(context),
      appBar: AppBar(
        backgroundColor: AppColors.homeBackground(context),
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: AppColors.homeInk(context)),
        title: Text('Jadwal Sholat', style: AppTokens.pageTitle(context)),
        actions: [
          IconButton(
            tooltip: 'Pilih tanggal',
            icon: const Icon(Icons.calendar_month_rounded, size: 22),
            onPressed: _openDateSheet,
          ),
          IconButton(
            tooltip: 'Perbarui lokasi',
            icon: const Icon(Icons.my_location_rounded, size: 22),
            onPressed: _refreshToday,
          ),
          IconButton(
            tooltip: 'Pengaturan jadwal',
            icon: const Icon(Icons.tune_rounded, size: 22),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrayerSettingsScreen()),
              );
              if (context.mounted) setState(() {});
            },
          ),
        ],
      ),
      body: BlocBuilder<PrayerCubit, PrayerState>(
        builder: (context, state) {
          if (state is PrayerLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.forest),
            );
          }
          if (state is PrayerError) {
            return _buildError(context);
          }
          if (state is PrayerLoaded) {
            return _buildLoaded(context, state, cubit);
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StarIconContainer(
              icon: Icons.location_off_outlined,
              size: 72,
              containerColor: AppColors.homeStarSecondary(context),
              iconColor: AppColors.homeArabicSecondary(context),
            ),
            const SizedBox(height: 20),
            Text(
              'Gagal mendapatkan lokasi',
              style: AppTokens.tileTitle(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Pastikan GPS aktif dan izin lokasi diberikan',
              style: AppTokens.tileSubtitle(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: () => context.read<PrayerCubit>().loadPrayerTimes(),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.forest,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                ),
                child: const Text(
                  'Coba Lagi',
                  style: TextStyle(
                    fontFamily: AppTokens.fontLatin,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoaded(
    BuildContext context,
    PrayerLoaded state,
    PrayerCubit cubit,
  ) {
    final use12h = cubit.use12HourFormat;
    final zone = PrayerTime.zoneLabelForNow();
    final times = state.prayerTime.toList();
    final nextIndex = state.prayerTime.getNextPrayerIndex();

    return RefreshIndicator(
      onRefresh: () => context.read<PrayerCubit>().loadPrayerTimes(),
      color: AppColors.forest,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTokens.pageMargin,
              4,
              AppTokens.pageMargin,
              AppTokens.itemGap,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_on_rounded,
                  size: 14,
                  color: AppColors.homeInkSecondary(context),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    state.locationName,
                    style: AppTokens.tileSubtitle(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  state.prayerTime.date,
                  style: AppTokens.tileSubtitle(context),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTokens.pageMargin,
            ),
            child: PrayerCard(
              data: state,
              use12h: use12h,
              zoneLabel: zone,
              showRemaining: _isToday,
              dateHeading: _isToday
                  ? null
                  : PrayerTime.formatDateId(_viewedDate!),
            ),
          ),
          const SizedBox(height: AppTokens.itemGap),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTokens.pageMargin,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.homeSurface(context),
                borderRadius: BorderRadius.circular(AppTokens.cardRadius),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: List.generate(times.length, (index) {
                  final p = times[index];
                  final isNext =
                      _isToday && nextIndex != -1 && index == nextIndex;
                  final isPassed =
                      _isToday && (nextIndex == -1 || index < nextIndex);
                  final isLast = index == times.length - 1;

                  return _PrayerRow(
                    prayer: p,
                    isNext: isNext,
                    isPassed: isPassed,
                    alarmEnabled: state.isAlarmEnabled(p.name),
                    isLast: isLast,
                    use12h: use12h,
                    onAlarmTap: () => cubit.togglePrayerAlarm(p),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _PrayerRow extends StatelessWidget {
  final dynamic prayer;
  final bool isNext;
  final bool isPassed;
  final bool alarmEnabled;
  final bool isLast;
  final bool use12h;
  final VoidCallback onAlarmTap;

  const _PrayerRow({
    required this.prayer,
    required this.isNext,
    required this.isPassed,
    required this.alarmEnabled,
    required this.isLast,
    required this.use12h,
    required this.onAlarmTap,
  });

  @override
  Widget build(BuildContext context) {
    final time = use12h ? PrayerTime.to12Hour(prayer.time) : prayer.time;

    return Column(
      children: [
        Container(
          color: isNext ? AppColors.homeStarSecondary(context) : null,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              _StatusDot(isNext: isNext, isPassed: isPassed),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  prayer.name,
                  style: TextStyle(
                    fontFamily: AppTokens.fontLatin,
                    fontSize: 14,
                    fontWeight: isNext ? FontWeight.w700 : FontWeight.w500,
                    color: isPassed
                        ? AppColors.homeInkSecondary(context)
                        : AppColors.homeInk(context),
                  ),
                ),
              ),
              Text(
                time,
                style: TextStyle(
                  fontFamily: AppTokens.fontLatin,
                  fontSize: 14,
                  fontWeight: isNext ? FontWeight.w700 : FontWeight.w500,
                  color: isPassed
                      ? AppColors.homeInkSecondary(context)
                      : AppColors.homeInk(context),
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 44,
                height: 44,
                child: InkWell(
                  onTap: onAlarmTap,
                  borderRadius: BorderRadius.circular(100),
                  child: Icon(
                    alarmEnabled
                        ? Icons.notifications_rounded
                        : Icons.notifications_off_rounded,
                    size: 20,
                    color: alarmEnabled
                        ? AppColors.homeArabicSecondary(context)
                        : AppColors.homeInkSecondary(context),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Padding(
            padding: const EdgeInsets.only(left: 40),
            child: Divider(height: 1, color: AppColors.homeDivider(context)),
          ),
      ],
    );
  }
}

class _StatusDot extends StatelessWidget {
  final bool isNext;
  final bool isPassed;

  const _StatusDot({required this.isNext, required this.isPassed});

  @override
  Widget build(BuildContext context) {
    if (isNext) {
      return Container(
        width: 10,
        height: 10,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.forest,
        ),
      );
    }
    if (isPassed) {
      return Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.homeInkSecondary(context).withValues(alpha: 0.4),
        ),
      );
    }
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.homeArabicSecondary(context),
          width: 1.5,
        ),
      ),
    );
  }
}

class _DateSheet extends StatefulWidget {
  final DateTime initialDate;

  const _DateSheet({required this.initialDate});

  @override
  State<_DateSheet> createState() => _DateSheetState();
}

class _DateSheetState extends State<_DateSheet> {
  static const _weekdayNames = [
    'Min',
    'Sen',
    'Sel',
    'Rab',
    'Kam',
    'Jum',
    'Sab',
  ];

  late DateTime _displayedMonth;
  late int? _selectedDay;

  @override
  void initState() {
    super.initState();
    final init = widget.initialDate;
    _displayedMonth = DateTime(init.year, init.month);
    _selectedDay = init.day;
  }

  int get _daysInMonth =>
      DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0).day;

  int get _leadingBlanks =>
      DateTime(_displayedMonth.year, _displayedMonth.month, 1).weekday % 7;

  void _shiftMonth(int delta) {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month + delta,
      );
      if (_selectedDay != null && _selectedDay! > _daysInMonth) {
        _selectedDay = _daysInMonth;
      }
    });
  }

  String get _selectedLabel {
    final day = _selectedDay;
    if (day == null) return '-';
    final date = DateTime(_displayedMonth.year, _displayedMonth.month, day);
    return PrayerTime.formatDateId(date);
  }

  DateTime get _pickedDate =>
      DateTime(_displayedMonth.year, _displayedMonth.month, _selectedDay ?? 1);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return SheetShell(
      title: 'Pilih Tanggal',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_selectedLabel, style: AppTokens.pageTitle(context)),
          const SizedBox(height: 16),
          Row(
            children: [
              IconButton(
                onPressed: () => _shiftMonth(-1),
                icon: const Icon(Icons.chevron_left_rounded),
                color: AppColors.homeInk(context),
              ),
              Expanded(
                child: Text(
                  '${PrayerTime.monthNamesId[_displayedMonth.month - 1]} '
                  '${_displayedMonth.year}',
                  style: AppTokens.tileTitle(context),
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                onPressed: () => _shiftMonth(1),
                icon: const Icon(Icons.chevron_right_rounded),
                color: AppColors.homeInk(context),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: _weekdayNames
                .map(
                  (w) => Expanded(
                    child: Text(
                      w,
                      style: AppTokens.cardLabel(context),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 4),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1,
            children: [
              for (var i = 0; i < _leadingBlanks; i++) const SizedBox(),
              for (var day = 1; day <= _daysInMonth; day++)
                _DayCell(
                  day: day,
                  isSelected: _selectedDay == day,
                  isToday:
                      today.day == day &&
                      today.month == _displayedMonth.month &&
                      today.year == _displayedMonth.year,
                  onTap: () => setState(() => _selectedDay = day),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: SheetButton(
                  label: 'Batal',
                  background: AppColors.homeOptionSurface(context),
                  foreground: AppColors.homeInk(context),
                  onTap: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SheetButton(
                  label: 'Pilih',
                  background: AppColors.forest,
                  foreground: Colors.white,
                  onTap: () => Navigator.pop(context, _pickedDate),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final int day;
  final bool isSelected;
  final bool isToday;
  final VoidCallback onTap;

  const _DayCell({
    required this.day,
    required this.isSelected,
    required this.isToday,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selected = isSelected;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: AspectRatio(
        aspectRatio: 1,
        child: Center(
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? AppColors.forest : Colors.transparent,
              border: isToday && !selected
                  ? Border.all(
                      color: AppColors.homeArabicSecondary(context),
                      width: 1.5,
                    )
                  : null,
            ),
            child: Text(
              '$day',
              style: TextStyle(
                fontFamily: AppTokens.fontLatin,
                fontSize: 14,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected
                    ? Colors.white
                    : AppColors.homeInkSecondary(context),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
