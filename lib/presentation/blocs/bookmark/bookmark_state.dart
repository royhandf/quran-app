import 'package:equatable/equatable.dart';
import '../../../data/models/bookmark.dart';

abstract class BookmarkState extends Equatable {
  const BookmarkState();
  @override
  List<Object?> get props => [];
}

class BookmarkInitial extends BookmarkState {}

class BookmarkLoaded extends BookmarkState {
  final List<Bookmark> bookmarks;
  const BookmarkLoaded(this.bookmarks);
  @override
  List<Object?> get props => [bookmarks];
}
