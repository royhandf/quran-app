import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/local/hive_service.dart';
import '../../../data/models/surah.dart';
import '../../blocs/quran/quran_cubit.dart';
import '../../blocs/quran/quran_state.dart';
import '../../blocs/audio/audio_cubit.dart';
import 'surah_detail_screen.dart';

class SurahListScreen extends StatefulWidget {
  const SurahListScreen({super.key});
  @override
  State<SurahListScreen> createState() => _SurahListScreenState();
}

class _SurahListScreenState extends State<SurahListScreen> {
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    context.read<QuranCubit>().loadSurahs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showDeleteDialog(BuildContext context, int surahId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Data Offline'),
        content: const Text('Hapus data surah yang sudah didownload?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              context.read<QuranCubit>().deleteSurah(surahId);
              Navigator.pop(ctx);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _openSurah(BuildContext context, Surah surah) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) =>
                  QuranCubit(
                    context.read<QuranCubit>().repository,
                  )..loadVerses(surah),
            ),
            BlocProvider(
              create: (_) => AudioCubit(
                context.read<QuranCubit>().repository,
              ),
            ),
          ],
          child: SurahDetailScreen(
            surah: surah,
            allSurahs: context.read<QuranCubit>().allSurahs,
          ),
        ),
      ),
    ).then((_) {
      if (!context.mounted) return;
      context.read<QuranCubit>().refreshDownloadStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.background(context),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: AppTextStyles.bodyMedium(context),
                decoration: InputDecoration(
                  hintText: 'Cari surah...',
                  hintStyle: AppTextStyles.bodyMedium(
                    context,
                  ).copyWith(color: AppColors.textSecondary(context)),
                  border: InputBorder.none,
                ),
                onChanged: (query) {
                  context.read<QuranCubit>().searchSurahs(query);
                },
              )
            : Text("Baca Qur'an", style: AppTextStyles.headingSmall(context)),
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close_rounded : Icons.search_rounded,
            ),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  context.read<QuranCubit>().searchSurahs('');
                }
              });
            },
          ),
        ],
      ),
      body: _buildSurahList(),
    );
  }

  Widget _buildSurahList() {
    return BlocConsumer<QuranCubit, QuranState>(
      listener: (context, state) {
        if (state is SurahsLoaded && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      builder: (context, state) {
        if (state is QuranLoading) {
          return _buildLoading();
        }
        if (state is QuranError) {
          return _buildError(context);
        }
        if (state is SurahsLoaded) {
          if (state.surahs.isEmpty) {
            return _buildEmptySearch();
          }
          final lastRead = GetIt.I<HiveService>().getLastRead();
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            itemCount: state.surahs.length,
            itemBuilder: (context, index) {
              final surah = state.surahs[index];
              final isLastRead =
                  lastRead != null && lastRead['surahId'] == surah.id;
              final isDownloading = state.downloadingSurahId == surah.id;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _SurahCard(
                  surah: surah,
                  isLastRead: isLastRead,
                  isDownloading: isDownloading,
                  isDownloaded: state.downloadedIds.contains(surah.id),
                  onTap: () => _openSurah(context, surah),
                  onDownload: () =>
                      context.read<QuranCubit>().downloadSurah(surah.id),
                  onDeleteOffline: () =>
                      _showDeleteDialog(context, surah.id),
                ),
              );
            },
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildLoading() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: 12,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: _ShimmerCard(context: context),
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.textSecondary(context).withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.wifi_off_rounded,
              size: 34,
              color: AppColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Gagal memuat daftar surah',
            style: AppTextStyles.bodyLarge(
              context,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            'Periksa koneksi internet dan coba lagi',
            style: AppTextStyles.bodySmall(context),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => context.read<QuranCubit>().loadSurahs(),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySearch() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.textSecondary(context).withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 34,
              color: AppColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ditemukan',
            style: AppTextStyles.bodyLarge(
              context,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            'Coba kata kunci lain',
            style: AppTextStyles.bodySmall(context),
          ),
        ],
      ),
    );
  }
}

// ── Surah card ─────────────────────────────────────────────────────────────────
class _SurahCard extends StatefulWidget {
  final Surah surah;
  final bool isLastRead;
  final bool isDownloading;
  final bool isDownloaded;
  final VoidCallback onTap;
  final VoidCallback onDownload;
  final VoidCallback onDeleteOffline;

  const _SurahCard({
    required this.surah,
    required this.isLastRead,
    required this.isDownloading,
    required this.isDownloaded,
    required this.onTap,
    required this.onDownload,
    required this.onDeleteOffline,
  });

  @override
  State<_SurahCard> createState() => _SurahCardState();
}

class _SurahCardState extends State<_SurahCard> {
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
            color: widget.isLastRead
                ? AppColors.primary.withValues(alpha: 0.06)
                : AppColors.card(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isLastRead
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : AppColors.dividerColor(context),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Nomor surah
              Container(
                width: 42,
                height: 42,
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
              // Info surah
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          s.nameSimple,
                          style: AppTextStyles.bodyMedium(
                            context,
                          ).copyWith(fontWeight: FontWeight.w700),
                        ),
                        if (widget.isLastRead) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Terakhir',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${s.translatedName} · ${s.revelationPlace == 'makkah' ? 'Mekah' : 'Madinah'} · ${s.versesCount} Ayat',
                      style: AppTextStyles.bodySmall(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Nama Arab + status download
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    s.nameArabic,
                    style: AppTextStyles.arabicMedium(context).copyWith(
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (widget.isDownloading)
                    const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else if (widget.isDownloaded)
                    GestureDetector(
                      onLongPress: widget.onDeleteOffline,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: widget.onDownload,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.download_outlined,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Shimmer placeholder saat loading ──────────────────────────────────────────
class _ShimmerCard extends StatelessWidget {
  final BuildContext context;
  const _ShimmerCard({required this.context});

  @override
  Widget build(BuildContext context) {
    final base = AppColors.dividerColor(context);
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: base, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: base,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 13,
                  width: 120,
                  decoration: BoxDecoration(
                    color: base,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 11,
                  width: 180,
                  decoration: BoxDecoration(
                    color: base,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
