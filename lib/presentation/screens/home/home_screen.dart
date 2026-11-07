import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_tokens.dart';
import '../../../core/services/update_service.dart';
import '../../blocs/bookmark/bookmark_cubit.dart';
import '../../blocs/bookmark/bookmark_state.dart';
import '../../blocs/prayer/prayer_cubit.dart';
import '../../blocs/prayer/prayer_state.dart';
import '../../widgets/home/bookmark_banner.dart';
import '../../widgets/home/menu_card.dart';
import '../../widgets/home/prayer_card.dart';
import '../dzikir/dzikir_screen.dart';
import '../last_read/last_read_screen.dart';
import '../prayer/prayer_times_screen.dart';
import '../quran/surah_list_screen.dart';
import '../search/search_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _countdownTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final prayerState = context.read<PrayerCubit>().state;
        if (prayerState is PrayerInitial) {
          context.read<PrayerCubit>().loadPrayerTimes();
        }
        context.read<BookmarkCubit>().loadBookmarks();

        // Cek update dari Play Store, tampilkan dialog jika ada
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) UpdateService.checkAndShowDialog(context);
        });
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
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
      if (mounted) {
        context.read<BookmarkCubit>().loadBookmarks();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTokens.cream,
      body: SafeArea(
        child: MediaQuery.withClampedTextScaling(
          maxScaleFactor: 1.4,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppTokens.pageMargin,
              8,
              AppTokens.pageMargin,
              32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildPrayerSection(),
                _buildBookmarkSection(),
                const SizedBox(height: 20),
                MenuGrid(items: _buildMenuItems()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text("Assalamu'alaikum", style: AppTokens.greeting),
        const Spacer(),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
              style: AppTokens.bismillah,
              textDirection: TextDirection.rtl,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrayerSection() {
    return BlocBuilder<PrayerCubit, PrayerState>(
      builder: (context, state) {
        if (state is PrayerLoaded) {
          return PrayerCard(data: state);
        }
        if (state is PrayerError) {
          return GestureDetector(
            onTap: () => context.read<PrayerCubit>().loadPrayerTimes(),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTokens.pageMargin),
              decoration: BoxDecoration(
                color: AppTokens.forest,
                borderRadius: BorderRadius.circular(AppTokens.cardRadius),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Gagal memuat jadwal. Ketuk untuk mencoba lagi.',
                      style: AppTokens.prayerCity,
                    ),
                  ),
                  const Icon(Icons.refresh_rounded, color: Colors.white),
                ],
              ),
            ),
          );
        }
        return Container(
          width: double.infinity,
          height: 180,
          decoration: BoxDecoration(
            color: AppTokens.forest,
            borderRadius: BorderRadius.circular(AppTokens.cardRadius),
          ),
          child: const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }

  /// Banner hanya muncul bila ada bookmark; saat kosong tidak menyisakan celah.
  Widget _buildBookmarkSection() {
    return BlocBuilder<BookmarkCubit, BookmarkState>(
      builder: (context, state) {
        if (state is! BookmarkLoaded || state.bookmarks.isEmpty) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.only(top: AppTokens.itemGap),
          child: BookmarkBanner(
            bookmark: state.bookmarks.first,
            onTap: () => _navigate(const LastReadScreen()),
          ),
        );
      },
    );
  }

  List<MenuItem> _buildMenuItems() {
    return [
      MenuItem(
        label: "Baca Qur'an",
        arabic: 'القرآن',
        icon: Icons.auto_stories_rounded,
        onTap: () => _navigate(const SurahListScreen()),
      ),
      MenuItem(
        label: 'Pencarian',
        arabic: 'بحث',
        icon: Icons.search_rounded,
        onTap: () => _navigate(const SearchScreen()),
      ),
      MenuItem(
        label: 'Jadwal Sholat',
        arabic: 'مواقيت الصلاة',
        icon: Icons.access_time_rounded,
        onTap: () => _navigate(const PrayerTimesScreen()),
      ),
      MenuItem(
        label: 'Dzikir',
        arabic: 'أذكار',
        icon: Icons.adjust,
        onTap: () => _navigate(const DzikirScreen()),
      ),
      MenuItem(
        label: 'Penanda',
        arabic: 'العلامات',
        icon: Icons.bookmark_border_rounded,
        onTap: () => _navigate(const LastReadScreen()),
      ),
      MenuItem(
        label: 'Pengaturan',
        arabic: 'الإعدادات',
        icon: Icons.tune_rounded,
        onTap: () => _navigate(const SettingsScreen()),
      ),
    ];
  }
}
