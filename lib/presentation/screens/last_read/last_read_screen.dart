import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/local/hive_service.dart';
import '../../../core/di/injection.dart';
import '../../blocs/bookmark/bookmark_cubit.dart';
import '../../blocs/bookmark/bookmark_state.dart';

class LastReadScreen extends StatelessWidget {
  const LastReadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lastRead = getIt<HiveService>().getLastRead();

    return Scaffold(
      appBar: AppBar(title: const Text('Terakhir Baca'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Last Read Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: lastRead != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.menu_book,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Lanjutkan Membaca',
                              style: AppTextStyles.bodySmall(
                                context,
                              ).copyWith(color: Colors.white70),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          lastRead['surahName'] ?? 'Al-Fatihah',
                          style: AppTextStyles.headingMedium(
                            context,
                          ).copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ayat ${lastRead['ayahNumber'] ?? 1}',
                          style: AppTextStyles.bodyMedium(
                            context,
                          ).copyWith(color: Colors.white70),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Lanjut Baca'),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        const Icon(
                          Icons.menu_book,
                          color: Colors.white54,
                          size: 40,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Belum ada riwayat bacaan',
                          style: AppTextStyles.bodyMedium(
                            context,
                          ).copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 24),

            // Bookmark Section
            Text('Bookmark', style: AppTextStyles.sectionHeader(context)),
            const SizedBox(height: 12),
            BlocBuilder<BookmarkCubit, BookmarkState>(
              builder: (context, state) {
                if (state is BookmarkLoaded) {
                  if (state.bookmarks.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppColors.card(context),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.bookmark_border,
                            size: 48,
                            color: AppColors.textSecondary(context),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Belum ada bookmark',
                            style: AppTextStyles.bodyMedium(context),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.bookmarks.length,
                    itemBuilder: (context, i) {
                      final bm = state.bookmarks[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: AppColors.card(context),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: const Icon(
                            Icons.bookmark,
                            color: AppColors.primary,
                          ),
                          title: Text(
                            bm.surahName,
                            style: AppTextStyles.bodyLarge(context),
                          ),
                          subtitle: Text(
                            'Ayat ${bm.ayahNumber}',
                            style: AppTextStyles.bodySmall(context),
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {},
                        ),
                      );
                    },
                  );
                }
                return const SizedBox();
              },
            ),
          ],
        ),
      ),
    );
  }
}
