import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/di/injection.dart';
import '../../../data/local/hive_service.dart';
import '../../blocs/prayer/prayer_cubit.dart';
import '../../blocs/prayer/prayer_state.dart';
import '../quran/surah_list_screen.dart';
import '../prayer/prayer_times_screen.dart';
import '../settings/settings_screen.dart';
import '../search/search_screen.dart';
import '../last_read/last_read_screen.dart';
import '../dzikir/dzikir_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerCtrl;
  Map<String, dynamic>? _lastRead;

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _loadLastRead();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final prayerState = context.read<PrayerCubit>().state;
        if (prayerState is PrayerInitial) {
          context.read<PrayerCubit>().loadPrayerTimes();
        }
      }
    });
  }

  void _loadLastRead() {
    setState(() {
      _lastRead = getIt<HiveService>().getLastRead();
    });
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    super.dispose();
  }

  void _navigate(Widget screen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, anim, _) => screen,
        transitionsBuilder: (_, anim, _, child) {
          return FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    ).then((_) {
      if (mounted) _loadLastRead();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    const Color(0xFF1A3A2A),
                    const Color(0xFF0F2218),
                    AppColors.darkBackground,
                  ]
                : [
                    const Color(0xFFE8F5F0),
                    const Color(0xFFF0F7F4),
                    AppColors.lightBackground,
                  ],
            stops: const [0.0, 0.35, 0.7],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -60,
              top: 40,
              child: _buildGeometricOrnament(220, opacity: 0.06),
            ),
            Positioned(
              left: -40,
              top: 320,
              child: _buildGeometricOrnament(180, opacity: 0.04),
            ),
            Positioned(
              right: -40,
              top: 600,
              child: _buildGeometricOrnament(160, opacity: 0.04),
            ),
            Positioned(
              left: -30,
              bottom: 100,
              child: _buildGeometricOrnament(150, opacity: 0.035),
            ),

            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 10),
                  _buildPrayerCard(),
                  const SizedBox(height: 24),
                  if (_lastRead != null) ...[
                    _buildLastReadBanner(),
                    const SizedBox(height: 24),
                  ],
                  _buildMenuSection(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        child: Center(
          child: Column(
            children: [
              _buildOrnamentRow(),
              const SizedBox(height: 14),
              AnimatedBuilder(
                animation: _shimmerCtrl,
                builder: (_, _) {
                  return ShaderMask(
                    shaderCallback: (bounds) {
                      final dx = _shimmerCtrl.value * 3 - 1;
                      return LinearGradient(
                        begin: Alignment(dx - 1, 0),
                        end: Alignment(dx + 0.5, 0),
                        colors: const [
                          Color(0xFFD4AF37),
                          Color(0xFFF5E77A),
                          Color(0xFFD4AF37),
                          Color(0xFFB8860B),
                          Color(0xFFD4AF37),
                        ],
                        stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
                      ).createShader(bounds);
                    },
                    child: const Text(
                      'ٱلْقُرْآنُ ٱلْكَرِيمُ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 46,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
                        height: 1.3,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),
              _buildOrnamentRow(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGeometricOrnament(double size, {double opacity = 0.1}) {
    return Opacity(
      opacity: opacity,
      child: CustomPaint(
        size: Size(size, size),
        painter: _GeometricPatternPainter(),
      ),
    );
  }

  Widget _buildOrnamentRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ornamentLine(toRight: false),
        const SizedBox(width: 10),
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: AppColors.gold,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        const Icon(Icons.star, color: AppColors.gold, size: 12),
        const SizedBox(width: 6),
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: AppColors.gold,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        _ornamentLine(toRight: true),
      ],
    );
  }

  Widget _ornamentLine({required bool toRight}) {
    return Container(
      width: 65,
      height: 1.5,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: toRight ? Alignment.centerLeft : Alignment.centerRight,
          end: toRight ? Alignment.centerRight : Alignment.centerLeft,
          colors: [AppColors.gold, AppColors.gold.withValues(alpha: 0.0)],
        ),
      ),
    );
  }

  Widget _buildPrayerCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: BlocBuilder<PrayerCubit, PrayerState>(
        builder: (context, state) {
          if (state is PrayerLoaded) {
            final nextPrayer = state.prayerTime.getNextPrayer();
            final remaining = state.prayerTime.getTimeUntilNextPrayer();
            String remainingText = '';
            if (remaining != null) {
              final h = remaining.inHours;
              final m = remaining.inMinutes % 60;
              remainingText = h > 0 ? '$h jam $m menit lagi' : '$m menit lagi';
            }

            return GestureDetector(
              onTap: () => _navigate(const PrayerTimesScreen()),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0F9B8E), Color(0xFF065F57)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                color: Colors.white70,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                state.locationName.isNotEmpty
                                    ? state.locationName
                                    : 'Lokasi',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            nextPrayer != null
                                ? 'Waktu ${nextPrayer.name}'
                                : 'Jadwal Sholat',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          if (nextPrayer != null)
                            Text(
                              nextPrayer.time,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          if (remainingText.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                remainingText,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 11,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.mosque_outlined,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.prayerTime.hijriDate,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10,
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }
          if (state is PrayerLoading || state is PrayerInitial) {
            return _buildPrayerCardSkeleton();
          }
          return _buildPrayerCardError();
        },
      ),
    );
  }

  Widget _buildPrayerCardSkeleton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isDark ? const Color(0xFF1E2E2A) : const Color(0xFFE0EFEA),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildPrayerCardError() {
    return GestureDetector(
      onTap: () => context.read<PrayerCubit>().loadPrayerTimes(),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFF0F9B8E), Color(0xFF065F57)],
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Ketuk untuk memuat jadwal',
              style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
            ),
            Icon(Icons.refresh, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildLastReadBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => _navigate(const LastReadScreen()),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF1C1C1C).withValues(alpha: 0.8)
                : Colors.white.withValues(alpha: 0.9),
            border: Border.all(
              color: AppColors.gold.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.menu_book_outlined,
                  color: AppColors.gold,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Lanjut Membaca',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: AppColors.gold,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _lastRead!['surahName'] ?? 'Al-Fatihah',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Ayat ${_lastRead!['ayahNumber'] ?? 1}',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: AppColors.textSecondary(context),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.textSecondary(context).withValues(alpha: 0.5),
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Menu Utama',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary(context),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMenuCard(
                  icon: Icons.auto_stories_rounded,
                  label: "Baca Qur'an",
                  subtitle: '114 Surah',
                  accentColor: const Color(0xFF4A9BD9),
                  onTap: () => _navigate(const SurahListScreen()),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMenuCard(
                  icon: Icons.search_rounded,
                  label: 'Pencarian',
                  subtitle: 'Cari Surat',
                  accentColor: const Color(0xFF9B6DD7),
                  onTap: () => _navigate(const SearchScreen()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMenuCard(
                  icon: Icons.access_time_rounded,
                  label: 'Jadwal Sholat',
                  subtitle: 'Waktu Sholat',
                  accentColor: const Color(0xFF0F9B8E),
                  onTap: () => _navigate(const PrayerTimesScreen()),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMenuCard(
                  icon: Icons.self_improvement,
                  label: 'Dzikir & Doa',
                  subtitle: 'Doa Harian',
                  accentColor: const Color(0xFFE8A87C),
                  onTap: () => _navigate(const DzikirScreen()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMenuCard(
                  icon: Icons.history,
                  label: 'Terakhir Baca',
                  subtitle: 'Riwayat',
                  accentColor: const Color(0xFFD4AF37),
                  onTap: () => _navigate(const LastReadScreen()),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMenuCard(
                  icon: Icons.tune_rounded,
                  label: 'Pengaturan',
                  subtitle: 'Konfigurasi',
                  accentColor: const Color(0xFF7B8CDE),
                  onTap: () => _navigate(const SettingsScreen()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return _AnimatedMenuCard(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.04),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.06),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accentColor, size: 22),
            ),
            const SizedBox(height: 14),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary(context),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                color: AppColors.textSecondary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedMenuCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _AnimatedMenuCard({required this.child, required this.onTap});

  @override
  State<_AnimatedMenuCard> createState() => _AnimatedMenuCardState();
}

class _AnimatedMenuCardState extends State<_AnimatedMenuCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.94,
      upperBound: 1.0,
    )..value = 1.0;
    _scale = _ctrl;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp: (_) {
        _ctrl.forward();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}

class _GeometricPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    canvas.drawCircle(center, r, paint);
    final path = Path();
    for (int i = 0; i < 8; i++) {
      final outer = Offset(
        center.dx + r * math.cos((i * 2 * math.pi / 8) - math.pi / 2),
        center.dy + r * math.sin((i * 2 * math.pi / 8) - math.pi / 2),
      );
      final inner = Offset(
        center.dx +
            (r * 0.45) * math.cos(((i + 0.5) * 2 * math.pi / 8) - math.pi / 2),
        center.dy +
            (r * 0.45) * math.sin(((i + 0.5) * 2 * math.pi / 8) - math.pi / 2),
      );
      if (i == 0) path.moveTo(outer.dx, outer.dy);
      path.lineTo(inner.dx, inner.dy);
      path.lineTo(outer.dx, outer.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
    final hexPath = Path();
    for (int i = 0; i < 6; i++) {
      final pt = Offset(
        center.dx + (r * 0.5) * math.cos((i * math.pi / 3) - math.pi / 6),
        center.dy + (r * 0.5) * math.sin((i * math.pi / 3) - math.pi / 6),
      );
      if (i == 0) {
        hexPath.moveTo(pt.dx, pt.dy);
      } else {
        hexPath.lineTo(pt.dx, pt.dy);
      }
    }
    hexPath.close();
    canvas.drawPath(hexPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
