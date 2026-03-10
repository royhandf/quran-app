import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/local/hive_service.dart';
import '../../../core/di/injection.dart';
import '../../blocs/quran/quran_cubit.dart';
import '../quran/surah_detail_screen.dart';

class LastReadScreen extends StatefulWidget {
  const LastReadScreen({super.key});

  @override
  State<LastReadScreen> createState() => _LastReadScreenState();
}

class _LastReadScreenState extends State<LastReadScreen> {
  Map<String, dynamic>? _lastRead;

  @override
  void initState() {
    super.initState();
    _loadLastRead();
  }

  void _loadLastRead() {
    setState(() {
      _lastRead = getIt<HiveService>().getLastRead();
    });
  }

  void _clearLastRead() async {
    await getIt<HiveService>().clearLastRead();
    _loadLastRead();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Riwayat terakhir baca dihapus')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Flexible(
              child: Text(
                'Terakhir Baca',
                style: AppTextStyles.headingSmall(context),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _lastRead != null
            ? Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    final surahId = _lastRead!['surahId'] as int;
                    final ayahNumber = _lastRead!['ayahNumber'] as int;
                    final surah = context.read<QuranCubit>().findSurahById(
                      surahId,
                    );
                    if (surah != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider(
                            create: (_) => QuranCubit(
                              context.read<QuranCubit>().repository,
                            )..loadVerses(surah),
                            child: SurahDetailScreen(
                              surah: surah,
                              initialAyah: ayahNumber,
                              allSurahs: context.read<QuranCubit>().allSurahs,
                            ),
                          ),
                        ),
                      ).then((_) {
                        if (!context.mounted) return;
                        context.read<QuranCubit>().refreshDownloadStatus();
                        _loadLastRead();
                      });
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isDark ? Colors.white24 : Colors.black12,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      color: isDark
                          ? const Color(0xFF1E1E1E)
                          : const Color(0xFFF9F9F9),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: const Icon(
                        Icons.menu_book,
                        color: AppColors.primary,
                        size: 28,
                      ),
                      title: Text(
                        _lastRead!['surahName'] ?? 'Al-Fatihah',
                        style: AppTextStyles.bodyLarge(
                          context,
                        ).copyWith(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          'Ayat ${_lastRead!['ayahNumber'] ?? 1}',
                          style: AppTextStyles.bodySmall(context),
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Hapus Riwayat?'),
                              content: const Text(
                                'Anda yakin ingin menghapus data terakhir baca Anda?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('Batal'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    _clearLastRead();
                                  },
                                  child: const Text(
                                    'Hapus',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.menu_book,
                      color: AppColors.textSecondary(context),
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada riwayat bacaan',
                      style: AppTextStyles.bodyMedium(
                        context,
                      ).copyWith(color: AppColors.textSecondary(context)),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
