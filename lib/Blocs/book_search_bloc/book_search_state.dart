import 'package:bookfinder/model/book.dart';


abstract class BookSearchState {}

class BookSearchInitial extends BookSearchState {}

class BookSearchLoading extends BookSearchState {}

class BookSearchSuccess extends BookSearchState {
  final List<Book> books;
  final bool hasMore;
  final bool isLoadingMore;

  BookSearchSuccess({
    required this.books,
    this.hasMore = true,
    this.isLoadingMore = false,
  });
}

class BookSearchError extends BookSearchState {
  final String message;

  BookSearchError(this.message);
}