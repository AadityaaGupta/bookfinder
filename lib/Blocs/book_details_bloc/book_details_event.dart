import 'package:bookfinder/model/book.dart';


abstract class BookDetailsEvent {}

class LoadBookDetails extends BookDetailsEvent {
  final Book book;

  LoadBookDetails(this.book);
}

class SaveBook extends BookDetailsEvent {
  final Book book;

  SaveBook(this.book);
}

class RemoveBook extends BookDetailsEvent {
  final String bookKey;

  RemoveBook(this.bookKey);
}

class CheckBookSaved extends BookDetailsEvent {
  final String bookKey;

  CheckBookSaved(this.bookKey);
}