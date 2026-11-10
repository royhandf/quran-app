import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_tokens.dart';
import '../../../data/models/surah.dart';
import '../../blocs/quran/quran_cubit.dart';
import '../../blocs/quran/quran_state.dart';
import '../../blocs/audio/audio_cubit.dart';
import '../../widgets/star_icon_container.dart';
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

  void _closeSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
      context.read<QuranCubit>().searchSurahs('');
    });
  }

  void _showDeleteDialog(BuildContext context, int surahId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.homeSurface(context),
        title: Text(
          'Hapus Data Offline',
          style: TextStyle(
            fontFamily: AppTokens.fontLatin,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.homeInk(ctx),
          ),
        ),
        content: Text(
          'Hapus data surah yang sudah didownload?',
          style: TextStyle(
            fontFamily: AppTokens.fontLatin,
            fontSize: 14,
            color: AppColors.homeInkSecondary(ctx),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Batal',
              style: TextStyle(
                fontFamily: AppTokens.fontLatin,
                color: AppColors.homeInkSecondary(ctx),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<QuranCubit>().deleteSurah(surahId);
              Navigator.pop(ctx);
            },
            child: Text(
              'Hapus',
              style: TextStyle(
                fontFamily: AppTokens.fontLatin,
                color: AppColors.homeDanger(ctx),
                fontWeight: FontWeight.w600,
              ),
            ),
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
      backgroundColor: AppColors.homeBackground(context),
      appBar: AppBar(
        backgroundColor: AppColors.homeBackground(context),
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: AppColors.homeInk(context)),
        automaticallyImplyLeading: !_isSearching,
        leading: _isSearching
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: _closeSearch,
              )
            : null,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                cursorColor: AppColors.forest,
                style: TextStyle(
                  fontFamily: AppTokens.fontLatin,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.homeInk(context),
                ),
                decoration: InputDecoration(
                  hintText: 'Cari surah…',
                  hintStyle: TextStyle(
                    fontFamily: AppTokens.fontLatin,
                    fontSize: 16,
                    color: AppColors.homeInkSecondary(context),
                  ),
                  border: InputBorder.none,
                ),
                onChanged: (query) {
                  context.read<QuranCubit>().searchSurahs(query);
                  setState(() {});
                },
              )
            : Text("Baca Qur'an", style: AppTokens.pageTitle(context)),
        actions: [
          if (_isSearching)
            IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () {
                _searchController.clear();
                context.read<QuranCubit>().searchSurahs('');
                setState(() {});
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.search_rounded),
              onPressed: () => setState(() => _isSearching = true),
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
            return _buildEmptySearch(context);
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(AppTokens.pageMargin, 8, AppTokens.pageMargin, 32),
            itemCount: state.surahs.length,
            itemBuilder: (context, index) {
              final surah = state.surahs[index];
              final isDownloading = state.downloadingSurahId == surah.id;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppTokens.itemGap),
                child: _SurahCard(
                  surah: surah,
                  isDownloading: isDownloading,
                  isDownloaded: state.downloadedIds.contains(surah.id),
                  highlightQuery: _isSearching ? _searchController.text : '',
                  onTap: () => _openSurah(context, surah),
                  onDownload: () {
                    context.read<QuranCubit>().downloadSurah(surah.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Mengunduh ${surah.nameSimple}…'),
                      ),
                    );
                  },
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
      padding: const EdgeInsets.fromLTRB(AppTokens.pageMargin, 8, AppTokens.pageMargin, 32),
      itemCount: 12,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: AppTokens.itemGap),
        child: const _ShimmerCard(),
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          StarIconContainer(
            icon: Icons.wifi_off_rounded,
            containerColor: AppColors.homeStarSecondary(context),
            iconColor: AppColors.homeInkSecondary(context),
          ),
          const SizedBox(height: 20),
          Text(
            'Gagal memuat daftar surah',
            style: AppTokens.tileTitle(context),
          ),
          const SizedBox(height: 6),
          Text(
            'Periksa koneksi internet dan coba lagi',
            style: AppTokens.tileSubtitle(context),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTokens.pageMargin),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: () => context.read<QuranCubit>().loadSurahs(),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.forest,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTokens.buttonRadius),
                  ),
                ),
                child: Text(
                  'Coba Lagi',
                  style: TextStyle(
                    fontFamily: AppTokens.fontLatin,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySearch(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          StarIconContainer(
            icon: Icons.search_off_rounded,
            containerColor: AppColors.homeStarSecondary(context),
            iconColor: AppColors.homeInkSecondary(context),
          ),
          const SizedBox(height: 20),
          Text('Tidak ditemukan', style: AppTokens.tileTitle(context)),
          const SizedBox(height: 6),
          Text('Coba kata kunci lain', style: AppTokens.tileSubtitle(context)),
        ],
      ),
    );
  }
}

class _SurahCard extends StatefulWidget {
  final Surah surah;
  final bool isDownloading;
  final bool isDownloaded;
  final String highlightQuery;
  final VoidCallback onTap;
  final VoidCallback onDownload;
  final VoidCallback onDeleteOffline;

  const _SurahCard({
    required this.surah,
    required this.isDownloading,
    required this.isDownloaded,
    required this.highlightQuery,
    required this.onTap,
    required this.onDownload,
    required this.onDeleteOffline,
  });

  @override
  State<_SurahCard> createState() => _SurahCardState();
}

class _SurahCardState extends State<_SurahCard> {
  bool _pressed = false;

  List<TextSpan> _nameSpans(BuildContext context) {
    final base = AppTokens.tileTitle(context);
    final query = widget.highlightQuery.trim().toLowerCase();
    final name = widget.surah.nameSimple;
    if (query.isEmpty) return [TextSpan(text: name)];
    final idx = name.toLowerCase().indexOf(query);
    if (idx < 0) return [TextSpan(text: name)];
    return [
      TextSpan(text: name.substring(0, idx)),
      TextSpan(
        text: name.substring(idx, idx + query.length),
        style: base.copyWith(color: AppColors.forest),
      ),
      TextSpan(text: name.substring(idx + query.length)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.surah;
    final place = s.revelationPlace == 'makkah' ? 'MEKAH' : 'MADINAH';
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
            color: AppColors.homeSurface(context),
            borderRadius: BorderRadius.circular(AppTokens.cardRadius),
          ),
          child: Row(
            children: [
              StarIconContainer(
                label: '${s.id}',
                containerColor: AppColors.homeStarSecondary(context),
                iconColor: AppColors.homeArabicSecondary(context),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        children: _nameSpans(context),
                        style: AppTokens.tileTitle(context),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${s.translatedName} · ${s.versesCount} ayat',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTokens.tileSubtitle(context),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      place,
                      style: TextStyle(
                        fontFamily: AppTokens.fontLatin,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                        color: AppColors.homeInkSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    s.nameArabic,
                    style: TextStyle(
                      fontFamily: AppTokens.fontArabic,
                      fontSize: 20,
                      color: AppColors.homeInk(context),
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (widget.isDownloading)
                    const SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.sage,
                      ),
                    )
                  else if (widget.isDownloaded)
                    GestureDetector(
                      onLongPress: widget.onDeleteOffline,
                      child: Material(
                        color: AppColors.forest,
                        shape: const CircleBorder(),
                        clipBehavior: Clip.antiAlias,
                        child: SizedBox(
                          width: 32,
                          height: 32,
                          child: Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: widget.onDownload,
                      child: Material(
                        color: AppColors.homeStarSecondary(context),
                        shape: const CircleBorder(),
                        clipBehavior: Clip.antiAlias,
                        child: SizedBox(
                          width: 32,
                          height: 32,
                          child: Icon(
                            Icons.download_outlined,
                            color: AppColors.homeArabicSecondary(context),
                            size: 18,
                          ),
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

class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard();

  @override
  Widget build(BuildContext context) {
    final base = AppColors.homeDivider(context);
    return Container(
      height: 86,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.homeSurface(context),
        borderRadius: BorderRadius.circular(AppTokens.cardRadius),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: base, shape: BoxShape.circle),
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
