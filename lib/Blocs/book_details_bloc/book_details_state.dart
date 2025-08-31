import 'package:bookfinder/model/book.dart';


abstract class BookDetailsState {}

class BookDetailsInitial extends BookDetailsState {}

class BookDetailsLoading extends BookDetailsState {}

class BookDetailsLoaded extends BookDetailsState {
  final Book book;
  final bool isSaved;

  BookDetailsLoaded({required this.book, this.isSaved = false});
}

class BookDetailsError extends BookDetailsState {
  final String message;

  BookDetailsError(this.message);
}

class BookSaved extends BookDetailsState {}

class BookRemoved extends BookDetailsState {}