abstract class BookSearchEvent {}

class SearchBooks extends BookSearchEvent {
  final String query;
  final bool isRefresh;

  SearchBooks(this.query, {this.isRefresh = false});
}

class LoadMoreBooks extends BookSearchEvent {}

class ClearSearch extends BookSearchEvent {}