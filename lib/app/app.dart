import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../core/di/injection.dart';
import '../presentation/blocs/quran/quran_cubit.dart';
import '../presentation/blocs/prayer/prayer_cubit.dart';
import '../presentation/blocs/bookmark/bookmark_cubit.dart';
import '../presentation/blocs/settings/settings_cubit.dart';
import '../presentation/blocs/settings/settings_state.dart';
import '../presentation/screens/home/home_screen.dart';

class QuranApp extends StatelessWidget {
  const QuranApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<QuranCubit>()),
        BlocProvider(create: (_) => getIt<PrayerCubit>()),
        BlocProvider(create: (_) => getIt<BookmarkCubit>()..loadBookmarks()),
        BlocProvider(create: (_) => getIt<SettingsCubit>()),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settings) {
          return MaterialApp(
            title: 'Al-Quran',
            debugShowCheckedModeBanner: false,
            themeMode: settings.themeMode,
            theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.light,
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.primary,
                brightness: Brightness.light,
              ),
              scaffoldBackgroundColor: AppColors.lightBackground,
              appBarTheme: const AppBarTheme(
                backgroundColor: AppColors.lightAppBar,
                foregroundColor: AppColors.lightTextPrimary,
                elevation: 0,
              ),
              cardTheme: CardThemeData(
                color: AppColors.lightCard,
                elevation: 0.5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              dividerColor: AppColors.lightDivider,
              textTheme: GoogleFonts.poppinsTextTheme(),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.primary,
                brightness: Brightness.dark,
              ),
              scaffoldBackgroundColor: AppColors.darkBackground,
              appBarTheme: const AppBarTheme(
                backgroundColor: AppColors.darkAppBar,
                foregroundColor: AppColors.darkTextPrimary,
                elevation: 0,
              ),
              cardTheme: CardThemeData(
                color: AppColors.darkCard,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              dividerColor: AppColors.darkDivider,
              textTheme: GoogleFonts.poppinsTextTheme(
                ThemeData.dark().textTheme,
              ),
            ),
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
