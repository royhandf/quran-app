import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/bookmark.dart';
import '../../../data/local/hive_service.dart';
import 'bookmark_state.dart';

class BookmarkCubit extends Cubit<BookmarkState> {
  final HiveService _hiveService;
  BookmarkCubit(this._hiveService) : super(BookmarkInitial());

  void loadBookmarks() {
    final bookmarks = _hiveService.getBookmarks();
    emit(BookmarkLoaded(bookmarks));
  }

  Future<void> toggleBookmark({
    required int surahId,
    required String surahName,
    required int ayahNumber,
    required String ayahText,
  }) async {
    final id = '${surahId}_$ayahNumber';
    if (_hiveService.isBookmarked(id)) {
      await _hiveService.removeBookmark(id);
    } else {
      await _hiveService.addBookmark(
        Bookmark(
          id: id,
          surahId: surahId,
          surahName: surahName,
          ayahNumber: ayahNumber,
          ayahText: ayahText,
          createdAt: DateTime.now(),
        ),
      );
    }
    loadBookmarks();
  }

  bool isBookmarked(int surahId, int ayahNumber) =>
      _hiveService.isBookmarked('${surahId}_$ayahNumber');
}
