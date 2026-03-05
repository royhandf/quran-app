import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../blocs/quran/quran_cubit.dart';
import '../../blocs/quran/quran_state.dart';
import '../../blocs/bookmark/bookmark_cubit.dart';
import '../../blocs/bookmark/bookmark_state.dart';
import 'surah_detail_screen.dart';

class SurahListScreen extends StatefulWidget {
  const SurahListScreen({super.key});
  @override
  State<SurahListScreen> createState() => _SurahListScreenState();
}

class _SurahListScreenState extends State<SurahListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<QuranCubit>().loadSurahs();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
              child: const Icon(
                Icons.mosque,
                color: AppColors.primary,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
            Text("Baca Qur'an", style: AppTextStyles.headingSmall(context)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.format_color_text),
            onPressed: () {},
          ),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary(context),
          indicatorColor: AppColors.primary,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          tabs: const [
            Tab(text: 'SURAH'),
            Tab(text: 'JUZ'),
            Tab(text: 'BOOKMARK'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildSurahTab(), _buildJuzTab(), _buildBookmarkTab()],
      ),
    );
  }

  Widget _buildSurahNumber(BuildContext context, int number) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary, width: 1.5),
      ),
      child: Center(
        child: Text(
          '$number',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildSurahTab() {
    return BlocBuilder<QuranCubit, QuranState>(
      builder: (context, state) {
        if (state is QuranLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is QuranError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${state.message}'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => context.read<QuranCubit>().loadSurahs(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        if (state is SurahsLoaded) {
          return ListView.separated(
            itemCount: state.surahs.length,
            separatorBuilder: (_, _) => Divider(
              height: 1,
              indent: 70,
              color: AppColors.dividerColor(context),
            ),
            itemBuilder: (context, index) {
              final surah = state.surahs[index];
              final isFirst = index == 0;
              return Container(
                color: isFirst
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : null,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  leading: _buildSurahNumber(context, surah.id),
                  title: Text(
                    surah.nameSimple,
                    style: AppTextStyles.bodyLarge(
                      context,
                    ).copyWith(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '${surah.revelationPlace == 'makkah' ? 'Mekah' : 'Madinah'.toUpperCase()} | ${surah.versesCount} Ayat',
                    style: AppTextStyles.bodySmall(context),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        surah.nameArabic,
                        style: AppTextStyles.arabicMedium(context),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.download_outlined,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ],
                  ),
                  onTap: () {
                    context.read<QuranCubit>().loadVerses(surah);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<QuranCubit>(),
                          child: SurahDetailScreen(surah: surah),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildJuzTab() {
    return ListView.builder(
      itemCount: 30,
      itemBuilder: (context, index) => ListTile(
        leading: _buildSurahNumber(context, index + 1),
        title: Text(
          'Juz ${index + 1}',
          style: AppTextStyles.bodyLarge(context),
        ),
        subtitle: Text(
          'Halaman ${(index * 20) + 1}',
          style: AppTextStyles.bodySmall(context),
        ),
      ),
    );
  }

  Widget _buildBookmarkTab() {
    return BlocBuilder<BookmarkCubit, BookmarkState>(
      builder: (context, state) {
        if (state is BookmarkLoaded) {
          if (state.bookmarks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_border,
                    size: 64,
                    color: AppColors.textSecondary(context),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada bookmark',
                    style: AppTextStyles.bodyMedium(context),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            itemCount: state.bookmarks.length,
            separatorBuilder: (_, _) =>
                Divider(height: 1, color: AppColors.dividerColor(context)),
            itemBuilder: (context, index) {
              final bm = state.bookmarks[index];
              return ListTile(
                leading: const Icon(Icons.bookmark, color: AppColors.primary),
                title: Text(
                  bm.surahName,
                  style: AppTextStyles.bodyLarge(context),
                ),
                subtitle: Text(
                  'Ayat ${bm.ayahNumber}',
                  style: AppTextStyles.bodySmall(context),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => context.read<BookmarkCubit>().toggleBookmark(
                    surahId: bm.surahId,
                    surahName: bm.surahName,
                    ayahNumber: bm.ayahNumber,
                    ayahText: bm.ayahText,
                  ),
                ),
              );
            },
          );
        }
        return const SizedBox();
      },
    );
  }
}
