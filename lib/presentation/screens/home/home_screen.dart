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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
              Color(0xFF0F3460),
              Color(0xFF1A1A2E),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Go Premium
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Text(
                    'Go Premium',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const Spacer(flex: 2),

              // Logo Al-Quran
              Column(
                children: [
                  Text(
                    'القرآن الكريم',
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 42,
                      color: AppColors.gold,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Icon(
                    Icons.menu_book_rounded,
                    color: AppColors.primary,
                    size: 36,
                  ),
                ],
              ),
              const Spacer(flex: 2),

              // Menu Buttons
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
