import 'dart:async';
import 'package:bookfinder/model/book.dart';
import 'package:bookfinder/repositories/book_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'book_search_event.dart';
import 'book_search_state.dart';

class BookSearchBloc extends Bloc<BookSearchEvent, BookSearchState> {
  final BookRepository repository;
  String _currentQuery = '';
  int _currentPage = 1;
  List<Book> _allBooks = [];

  BookSearchBloc({required this.repository}) : super(BookSearchInitial()) {
    on<SearchBooks>(_onSearchBooks);
    on<LoadMoreBooks>(_onLoadMoreBooks);
    on<ClearSearch>(_onClearSearch);
  }

  Future<void> _onSearchBooks(
    SearchBooks event,
    Emitter<BookSearchState> emit,
  ) async {
    try {
      if (event.isRefresh) {
        _currentPage = 1;
        _allBooks.clear();
      } else if (event.query != _currentQuery) {
        _currentPage = 1;
        _allBooks.clear();
        emit(BookSearchLoading());
      }

      _currentQuery = event.query;

      final books = await repository.searchBooks(
        event.query,
        page: _currentPage,
      );

      if (event.isRefresh || _currentPage == 1) {
        _allBooks = books;
      } else {
        _allBooks.addAll(books);
      }

      emit(BookSearchSuccess(
        books: List.from(_allBooks),
        hasMore: books.length == 20,
      ));
    } catch (e) {
      emit(BookSearchError(e.toString()));
    }
  }

  Future<void> _onLoadMoreBooks(
    LoadMoreBooks event,
    Emitter<BookSearchState> emit,
  ) async {
    if (state is BookSearchSuccess && _currentQuery.isNotEmpty) {
      final currentState = state as BookSearchSuccess;
      if (!currentState.hasMore || currentState.isLoadingMore) return;

      emit(BookSearchSuccess(
        books: currentState.books,
        hasMore: currentState.hasMore,
        isLoadingMore: true,
      ));

      try {
        _currentPage++;
        final books = await repository.searchBooks(
          _currentQuery,
          page: _currentPage,
        );

        _allBooks.addAll(books);

        emit(BookSearchSuccess(
          books: List.from(_allBooks),
          hasMore: books.length == 20,
        ));
      } catch (e) {
        emit(BookSearchError(e.toString()));
      }
    }
  }

  void _onClearSearch(ClearSearch event, Emitter<BookSearchState> emit) {
    _currentQuery = '';
    _currentPage = 1;
    _allBooks.clear();
    emit(BookSearchInitial());
  }
}