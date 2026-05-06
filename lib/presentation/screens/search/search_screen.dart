import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/repositories/quran_repository.dart';
import '../../../core/di/injection.dart';
import '../../blocs/audio/audio_cubit.dart';
import '../../blocs/quran/quran_cubit.dart';
import '../../blocs/quran/quran_state.dart';
import '../../blocs/settings/settings_cubit.dart';
import '../quran/surah_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  final _ctrl = TextEditingController();
  late final QuranCubit _quranCubit;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _quranCubit = context.read<QuranCubit>();
    if (_quranCubit.state is! SurahsLoaded) {
      _quranCubit.loadSurahs();
    }
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _fadeCtrl.dispose();
    _quranCubit.restoreSurahList();
    super.dispose();
  }

  void _onSearch(String q) {
    context.read<QuranCubit>().searchSurahs(q);
    if (q.isNotEmpty) {
      _fadeCtrl.forward();
    } else {
      _fadeCtrl.reverse();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.background(context),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('Pencarian', style: AppTextStyles.headingSmall(context)),
      ),
      body: Column(
        children: [
          // ── Search Bar ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.card(context),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _ctrl,
                autofocus: true,
                style: AppTextStyles.bodyMedium(context),
                decoration: InputDecoration(
                  hintText: 'Cari nama atau arti surah...',
                  hintStyle: AppTextStyles.bodyMedium(
                    context,
                  ).copyWith(color: AppColors.textSecondary(context)),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                  suffixIcon: _ctrl.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.close_rounded,
                            color: AppColors.textSecondary(context),
                            size: 20,
                          ),
                          onPressed: () {
                            _ctrl.clear();
                            _onSearch('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                onChanged: _onSearch,
              ),
            ),
          ),

          // ── Results ───────────────────────────────────────────
          Expanded(
            child: BlocBuilder<QuranCubit, QuranState>(
              builder: (context, state) {
                if (state is QuranLoading || state is VersesLoaded) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is QuranError) {
                  return _buildError(context);
                }
                if (state is SurahsLoaded) {
                  if (_ctrl.text.isEmpty) {
                    return _buildIdleState(context);
                  }
                  if (state.surahs.isEmpty) {
                    return _buildEmptyResult(context);
                  }
                  return FadeTransition(
                    opacity: _fadeAnim,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: state.surahs.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final s = state.surahs[i];
                        return _SurahResultCard(
                          surah: s,
                          query: _ctrl.text,
                          onTap: () => _openSurah(context, s),
                        );
                      },
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdleState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_rounded,
              size: 38,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Cari Surah',
            style: AppTextStyles.bodyLarge(
              context,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Ketik nama atau arti surah\ncontoh: "Al-Fatihah" atau "Pembuka"',
            style: AppTextStyles.bodySmall(context),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyResult(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.textSecondary(
                context,
              ).withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 38,
              color: AppColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Tidak ditemukan',
            style: AppTextStyles.bodyLarge(
              context,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            '"${_ctrl.text}" tidak cocok dengan surah manapun',
            style: AppTextStyles.bodySmall(context),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.wifi_off_rounded,
            size: 52,
            color: AppColors.textSecondary(context),
          ),
          const SizedBox(height: 12),
          Text('Gagal memuat data', style: AppTextStyles.bodyMedium(context)),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => context.read<QuranCubit>().loadSurahs(),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  void _openSurah(BuildContext context, dynamic s) {
    final reciterId =
        context.read<SettingsCubit>().state.selectedReciterId;
    final repo = getIt<QuranRepository>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) =>
                  QuranCubit(
                    context.read<QuranCubit>().repository,
                  )..loadVerses(s),
            ),
            BlocProvider(
              create: (_) =>
                  AudioCubit(repo)..loadSurahAudio(s.id, reciterId),
            ),
          ],
          child: SurahDetailScreen(
            surah: s,
            allSurahs: context.read<QuranCubit>().allSurahs,
          ),
        ),
      ),
    );
  }
}

// ── Surah result card ──────────────────────────────────────────────────────────
class _SurahResultCard extends StatefulWidget {
  final dynamic surah;
  final String query;
  final VoidCallback onTap;

  const _SurahResultCard({
    required this.surah,
    required this.query,
    required this.onTap,
  });

  @override
  State<_SurahResultCard> createState() => _SurahResultCardState();
}

class _SurahResultCardState extends State<_SurahResultCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.surah;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.card(context),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.dividerColor(context),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Nomor surah
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '${s.id}',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Nama & info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.nameSimple,
                      style: AppTextStyles.bodyMedium(
                        context,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${s.translatedName} · ${s.versesCount} ayat',
                      style: AppTextStyles.bodySmall(context),
                    ),
                  ],
                ),
              ),
              // Nama Arab
              Text(
                s.nameArabic,
                style: AppTextStyles.arabicMedium(context).copyWith(
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
