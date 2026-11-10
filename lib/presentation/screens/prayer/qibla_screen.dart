import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_tokens.dart';
import '../../widgets/star_icon_container.dart';

const _directions = {'U': 0.0, 'T': 90.0, 'S': 180.0, 'B': 270.0};

class QiblaScreen extends StatefulWidget {
  final double qiblaDirection;

  const QiblaScreen({super.key, required this.qiblaDirection});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  double _displayHeading = 0;
  bool _hasHeading = false;
  StreamSubscription<CompassEvent>? _subscription;

  static const double _alignTolerance = 5;

  @override
  void initState() {
    super.initState();
    _subscription = FlutterCompass.events?.listen((event) {
      final heading = event.heading;
      if (heading == null || !mounted) return;
      final delta = ((heading - _displayHeading) % 360 + 540) % 360 - 180;
      if (delta.abs() < 0.2) return;
      setState(() {
        _displayHeading += delta;
        _hasHeading = true;
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  bool get _isAligned {
    final diff = ((widget.qiblaDirection - _displayHeading) % 360 + 360) % 360;
    return diff < _alignTolerance || diff > 360 - _alignTolerance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeBackground(context),
      appBar: AppBar(
        backgroundColor: AppColors.homeBackground(context),
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: AppColors.homeInk(context)),
        title: Text('Arah Kiblat', style: AppTokens.pageTitle(context)),
      ),
      body: !_hasHeading
          ? _buildNoSensor(context)
          : SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compassSize =
                      (constraints.maxWidth - 2 * AppTokens.pageMargin).clamp(
                        0.0,
                        340.0,
                      );
                  return Column(
                    children: [
                      const SizedBox(height: 12),
                      _StateChip(aligned: _isAligned),
                      Expanded(
                        child: Center(
                          child: _Compass(
                            size: compassSize,
                            displayHeading: _displayHeading,
                            qiblaDirection: widget.qiblaDirection,
                            aligned: _isAligned,
                          ),
                        ),
                      ),
                      _InfoCards(
                        qibla: widget.qiblaDirection,
                        heading: _displayHeading,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _isAligned
                            ? 'Tahan posisi ini agar tetap menghadap kiblat.'
                            : 'Gerakkan HP Anda agar kompas akurat.',
                        style: AppTokens.tileSubtitle(context),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                    ],
                  );
                },
              ),
            ),
    );
  }

  Widget _buildNoSensor(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          StarIconContainer(
            icon: Icons.compass_calibration_outlined,
            size: 72,
            containerColor: AppColors.homeStarSecondary(context),
            iconColor: AppColors.homeArabicSecondary(context),
          ),
          const SizedBox(height: 20),
          Text(
            'Sensor kompas tidak tersedia',
            style: AppTokens.tileTitle(context),
          ),
          const SizedBox(height: 8),
          Text(
            'Putar dan gerakkan HP Anda\nuntuk kalibrasi kompas',
            style: AppTokens.tileSubtitle(context),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _StateChip extends StatelessWidget {
  final bool aligned;

  const _StateChip({required this.aligned});

  @override
  Widget build(BuildContext context) {
    final forest = AppColors.forest;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: aligned ? forest : Colors.transparent,
        borderRadius: BorderRadius.circular(100),
        border: aligned ? null : Border.all(color: forest, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            aligned ? Icons.check_rounded : Icons.explore_rounded,
            size: 16,
            color: aligned ? Colors.white : forest,
          ),
          const SizedBox(width: 6),
          Text(
            aligned ? 'Anda menghadap kiblat' : 'Putar ke arah kiblat',
            style: TextStyle(
              fontFamily: AppTokens.fontLatin,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: aligned ? Colors.white : forest,
            ),
          ),
        ],
      ),
    );
  }
}

class _Compass extends StatelessWidget {
  final double size;
  final double displayHeading;
  final double qiblaDirection;
  final bool aligned;

  const _Compass({
    required this.size,
    required this.displayHeading,
    required this.qiblaDirection,
    required this.aligned,
  });

  @override
  Widget build(BuildContext context) {
    final ringColor = AppColors.homeArabicSecondary(context);
    final needleColor = aligned
        ? AppColors.homeInk(context)
        : AppColors.homeArabicSecondary(context);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.homeSurface(context),
              border: Border.all(color: ringColor, width: aligned ? 2.5 : 1.5),
            ),
          ),
          CustomPaint(
            size: Size(size * 0.52, size * 0.52),
            painter: _KhatamPainter(color: ringColor.withValues(alpha: 0.35)),
          ),
          AnimatedRotation(
            turns: -displayHeading / 360,
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            child: SizedBox(
              width: size,
              height: size,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: Size(size, size),
                    painter: _TickPainter(
                      color: AppColors.homeInkSecondary(context),
                    ),
                  ),
                  for (final entry in _directions.entries)
                    Transform.translate(
                      offset: Offset(
                        math.sin(entry.value * math.pi / 180) * size * 0.36,
                        -math.cos(entry.value * math.pi / 180) * size * 0.36,
                      ),
                      child: Text(
                        entry.key,
                        style: TextStyle(
                          fontFamily: AppTokens.fontLatin,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.homeArabicSecondary(context),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          AnimatedRotation(
            turns: (qiblaDirection - displayHeading) / 360,
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            child: SizedBox(
              width: size,
              height: size,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: size * 0.06,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _KabahMarker(size: 22),
                        const SizedBox(height: 4),
                        Container(
                          width: 4,
                          height: size * 0.3,
                          decoration: BoxDecoration(
                            color: needleColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.homeBackground(context),
              border: Border.all(color: needleColor, width: 2),
            ),
          ),
        ],
      ),
    );
  }
}

class _TickPainter extends CustomPainter {
  final Color color;

  _TickPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final minor = Paint()
      ..color = color.withValues(alpha: 0.35)
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;
    final major = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 60; i++) {
      final angle = i * 6 * math.pi / 180;
      final isMajor = i % 5 == 0;
      final paint = isMajor ? major : minor;
      final inner = radius - (isMajor ? 14 : 9);
      canvas.drawLine(
        Offset(
          center.dx + math.sin(angle) * inner,
          center.dy - math.cos(angle) * inner,
        ),
        Offset(
          center.dx + math.sin(angle) * (radius - 4),
          center.dy - math.cos(angle) * (radius - 4),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TickPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _KhatamPainter extends CustomPainter {
  final Color color;

  _KhatamPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final side = size.width * 0.72;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (final angle in [0.0, math.pi / 4]) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: side, height: side),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _KhatamPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _KabahMarker extends StatelessWidget {
  final double size;

  const _KabahMarker({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: AppColors.forest,
              borderRadius: BorderRadius.circular(3),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.7),
                width: 1,
              ),
            ),
          ),
          Positioned(
            top: size * 0.3,
            left: 0,
            right: 0,
            child: Container(height: size * 0.26, color: AppColors.gold),
          ),
        ],
      ),
    );
  }
}

class _InfoCards extends StatelessWidget {
  final double qibla;
  final double heading;

  const _InfoCards({required this.qibla, required this.heading});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTokens.pageMargin),
      child: Row(
        children: [
          Expanded(
            child: _InfoCard(
              icon: Icons.navigation_outlined,
              label: 'Arah Kiblat',
              value: '${qibla.toStringAsFixed(1)}°',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _InfoCard(
              icon: Icons.explore_outlined,
              label: 'Kompas',
              value: '${(heading % 360).toStringAsFixed(1)}°',
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.homeSurface(context),
        borderRadius: BorderRadius.circular(AppTokens.cardRadius),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: AppColors.homeArabicSecondary(context)),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTokens.tileSubtitle(context),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontFamily: AppTokens.fontLatin,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.homeInk(context),
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
