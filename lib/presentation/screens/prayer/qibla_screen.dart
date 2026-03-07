import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:quran_app/core/constants/app_colors.dart';

class QiblaScreen extends StatelessWidget {
  final double qiblaDirection;

  const QiblaScreen({super.key, required this.qiblaDirection});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Arah Kiblat')),
      body: StreamBuilder<CompassEvent>(
        stream: FlutterCompass.events,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: Text('Sensor kompas tidak tersedia'));
          }

          final heading = snapshot.data!.heading ?? 0;
          final angle = (qiblaDirection - heading) * (math.pi / 180);

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.rotate(
                  angle: angle,
                  child: Icon(
                    Icons.navigation,
                    size: 120,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  '${qiblaDirection.toStringAsFixed(1)}°',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text('Arah Kiblat dari Utara'),
              ],
            ),
          );
        },
      ),
    );
  }
}
