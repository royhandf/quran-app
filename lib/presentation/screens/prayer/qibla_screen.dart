import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:quran_app/core/constants/app_colors.dart';

class QiblaScreen extends StatelessWidget {
  final double qiblaDirection;

  const QiblaScreen({super.key, required this.qiblaDirection});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Arah Kiblat')),
      body: StreamBuilder<CompassEvent>(
        stream: FlutterCompass.events,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.heading == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.compass_calibration_outlined,
                    size: 64,
                    color: AppColors.textSecondary(context),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Sensor kompas tidak tersedia',
                    style: TextStyle(color: AppColors.textSecondary(context)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Putar dan gerakkan HP Anda\nuntuk kalibrasi kompas',
                    style: TextStyle(
                      color: AppColors.textSecondary(context),
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final heading = snapshot.data!.heading ?? 0.0;
          // Angle between device north and qibla direction
          final qiblaAngle = (qiblaDirection - heading) * (math.pi / 180);

          // Consider "pointing to Mecca" if within ±5 degrees
          final diffDegrees = ((qiblaDirection - heading) % 360 + 360) % 360;
          final isAligned = diffDegrees < 5 || diffDegrees > 355;

          return Column(
            children: [
              const SizedBox(height: 32),

              // Status indicator
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isAligned
                      ? Colors.green.withValues(alpha: 0.15)
                      : AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isAligned ? Colors.green : AppColors.primary,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isAligned ? Icons.check_circle : Icons.explore_outlined,
                      color: isAligned ? Colors.green : AppColors.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isAligned
                          ? '🕋  Menghadap Kiblat!'
                          : 'Putar ke arah kiblat',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isAligned ? Colors.green : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Compass Rose
              SizedBox(
                width: 280,
                height: 280,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer ring
                    Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          width: 2,
                        ),
                        color: isDark
                            ? const Color(0xFF1A1A2E)
                            : const Color(0xFFF0F4FF),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            blurRadius: 20,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                    ),

                    // Compass direction labels (N, S, E, W) — they rotate with heading
                    Transform.rotate(
                      angle: -heading * (math.pi / 180),
                      child: SizedBox(
                        width: 280,
                        height: 280,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            _directionLabel('U', 0, isDark, isNorth: true),
                            _directionLabel('S', math.pi, isDark),
                            _directionLabel('T', math.pi / 2, isDark),
                            _directionLabel('B', -math.pi / 2, isDark),
                          ],
                        ),
                      ),
                    ),

                    // Qibla needle — always points to qibla
                    Transform.rotate(
                      angle: qiblaAngle,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Tip of needle
                          Container(
                            width: 10,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(10),
                              ),
                              color: isAligned
                                  ? Colors.green
                                  : AppColors.primary,
                            ),
                          ),
                          // Kaaba icon
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isAligned
                                  ? Colors.green
                                  : AppColors.primary,
                            ),
                            child: const Text(
                              '🕋',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          // Tail of needle
                          Container(
                            width: 6,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(6),
                              ),
                              color:
                                  (isAligned ? Colors.green : AppColors.primary)
                                      .withValues(alpha: 0.4),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Center dot
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark ? Colors.white : Colors.black,
                        border: Border.all(color: AppColors.primary, width: 2),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Info row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _infoTile(
                      context,
                      icon: Icons.navigation_outlined,
                      label: 'Arah Kiblat',
                      value: '${qiblaDirection.toStringAsFixed(1)}°',
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: AppColors.dividerColor(context),
                    ),
                    _infoTile(
                      context,
                      icon: Icons.explore_outlined,
                      label: 'Kompas',
                      value: '${heading.toStringAsFixed(1)}°',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              Text(
                'Gerakkan HP Anda agar kompas akurat',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary(context),
                ),
              ),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _directionLabel(
    String label,
    double angle,
    bool isDark, {
    bool isNorth = false,
  }) {
    const radius = 110.0;
    return Transform.translate(
      offset: Offset(math.sin(angle) * radius, -math.cos(angle) * radius),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: isNorth
              ? Colors.red
              : (isDark ? Colors.white70 : Colors.black54),
        ),
      ),
    );
  }

  Widget _infoTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary(context),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ],
    );
  }
}
