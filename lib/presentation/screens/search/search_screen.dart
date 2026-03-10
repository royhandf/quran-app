import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../blocs/quran/quran_cubit.dart';
import '../../blocs/quran/quran_state.dart';
import '../quran/surah_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (context.read<QuranCubit>().state is! SurahsLoaded) {
      context.read<QuranCubit>().loadSurahs();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _ctrl,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Cari surah...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: AppColors.textSecondary(context)),
          ),
          style: AppTextStyles.bodyLarge(context),
          onChanged: (q) => context.read<QuranCubit>().searchSurahs(q),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              _ctrl.clear();
              context.read<QuranCubit>().searchSurahs('');
            },
          ),
        ],
      ),
      body: BlocBuilder<QuranCubit, QuranState>(
        builder: (context, state) {
          if (state is QuranLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is SurahsLoaded) {
            if (_ctrl.text.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search,
                      size: 64,
                      color: AppColors.textSecondary(context),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Ketik untuk mencari surah',
                      style: AppTextStyles.bodyMedium(context),
                    ),
                  ],
                ),
              );
            }
            if (state.surahs.isEmpty) {
              return Center(
                child: Text(
                  'Tidak ditemukan',
                  style: AppTextStyles.bodyMedium(context),
                ),
              );
            }
            return ListView.separated(
              itemCount: state.surahs.length,
              separatorBuilder: (_, _) =>
                  Divider(height: 1, color: AppColors.dividerColor(context)),
              itemBuilder: (context, i) {
                final s = state.surahs[i];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                    child: Text(
                      '${s.id}',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    s.nameSimple,
                    style: AppTextStyles.bodyLarge(context),
                  ),
                  subtitle: Text(
                    s.translatedName,
                    style: AppTextStyles.bodySmall(context),
                  ),
                  trailing: Text(
                    s.nameArabic,
                    style: AppTextStyles.arabicMedium(context),
                  ),
                  onTap: () {
                    context.read<QuranCubit>().loadVerses(s);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<QuranCubit>(),
                          child: SurahDetailScreen(
                            surah: s,
                            allSurahs: context.read<QuranCubit>().allSurahs,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
