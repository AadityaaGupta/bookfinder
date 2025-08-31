import 'dart:async';
import 'package:bookfinder/model/book.dart';
import 'package:bookfinder/repositories/book_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'book_details_event.dart';
import 'book_details_state.dart';

class BookDetailsBloc extends Bloc<BookDetailsEvent, BookDetailsState> {
  final BookRepository repository;

  BookDetailsBloc({required this.repository}) : super(BookDetailsInitial()) {
    on<LoadBookDetails>(_onLoadBookDetails);
    on<SaveBook>(_onSaveBook);
    on<RemoveBook>(_onRemoveBook);
    on<CheckBookSaved>(_onCheckBookSaved);
  }

  Future<void> _onLoadBookDetails(
    LoadBookDetails event,
    Emitter<BookDetailsState> emit,
  ) async {
    emit(BookDetailsLoading());
    
    try {
      Book detailedBook = event.book;
      
      // If we have a key, fetch detailed information
      if (event.book.key != null) {
        try {
          detailedBook = await repository.getBookDetails(event.book.key!);
          print(" detailedBook----------------->> $detailedBook");
        } catch (e) {
          // If detailed fetch fails, use the original book data
          detailedBook = event.book;
        }
      }

      // Check if book is saved
      bool isSaved = false;
      if (detailedBook.key != null) {
        isSaved = await repository.isBookSaved(detailedBook.key!);
      }

      emit(BookDetailsLoaded(book: detailedBook, isSaved: isSaved));
    } catch (e) {
      emit(BookDetailsError(e.toString()));
    }
  }

  Future<void> _onSaveBook(SaveBook event, Emitter<BookDetailsState> emit) async {
    try {
      await repository.saveBook(event.book);
      emit(BookSaved());
      
      // Reload the current state with updated save status
      if (event.book.key != null) {
        final isSaved = await repository.isBookSaved(event.book.key!);
        emit(BookDetailsLoaded(book: event.book, isSaved: isSaved));
      }
    } catch (e) {
      emit(BookDetailsError(e.toString()));
    }
  }

  Future<void> _onRemoveBook(RemoveBook event, Emitter<BookDetailsState> emit) async {
    try {
      await repository.removeBook(event.bookKey);
      emit(BookRemoved());
    } catch (e) {
      emit(BookDetailsError(e.toString()));
    }
  }

  Future<void> _onCheckBookSaved(
    CheckBookSaved event,
    Emitter<BookDetailsState> emit,
  ) async {
    try {
      final isSaved = await repository.isBookSaved(event.bookKey);
      if (state is BookDetailsLoaded) {
        final currentState = state as BookDetailsLoaded;
        emit(BookDetailsLoaded(book: currentState.book, isSaved: isSaved));
      }
    } catch (e) {
      emit(BookDetailsError(e.toString()));
    }
  }
}