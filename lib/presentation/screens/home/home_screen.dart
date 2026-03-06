import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/menu_button.dart';
import '../quran/surah_list_screen.dart';
import '../prayer/prayer_times_screen.dart';
import '../settings/settings_screen.dart';
import '../search/search_screen.dart';
import '../last_read/last_read_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _navigate(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  Widget _buildOrnamentLine({required bool toRight}) {
    return Container(
      width: 60,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(color: AppColors.darkBackground),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),
              const Spacer(flex: 2),

              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildOrnamentLine(toRight: false),
                      const SizedBox(width: 12),
                      Icon(Icons.star, color: AppColors.gold, size: 14),
                      const SizedBox(width: 12),
                      _buildOrnamentLine(toRight: true),
                    ],
                  ),
                  const SizedBox(height: 12),

                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [
                        Color(0xFFF5D680),
                        Color(0xFFD4AF37),
                        Color(0xFFB8860B),
                        Color(0xFFD4AF37),
                        Color(0xFFF5D680),
                      ],
                      stops: [0.0, 0.25, 0.5, 0.75, 1.0],
                    ).createShader(bounds),
                    child: Text(
                      'القرآن الكريم',
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                        height: 1.4,
                        shadows: [
                          Shadow(
                            color: Color(0xFFD4AF37).withValues(alpha: 0.6),
                            blurRadius: 20,
                          ),
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.8),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildOrnamentLine(toRight: false),
                      const SizedBox(width: 12),
                      Icon(Icons.star, color: AppColors.gold, size: 14),
                      const SizedBox(width: 12),
                      _buildOrnamentLine(toRight: true),
                    ],
                  ),
                ],
              ),
              const Spacer(flex: 2),
              MenuButton(
                label: "BACA QUR'AN",
                onTap: () => _navigate(context, const SurahListScreen()),
              ),
              MenuButton(
                label: 'TERAKHIR BACA',
                onTap: () => _navigate(context, const LastReadScreen()),
              ),
              MenuButton(
                label: 'PENCARIAN',
                onTap: () => _navigate(context, const SearchScreen()),
              ),
              MenuButton(
                label: 'JADWAL SHOLAT',
                onTap: () => _navigate(context, const PrayerTimesScreen()),
              ),
              MenuButton(
                label: 'PENGATURAN',
                onTap: () => _navigate(context, const SettingsScreen()),
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}
