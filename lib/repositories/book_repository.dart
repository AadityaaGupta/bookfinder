import 'dart:convert';
import 'package:bookfinder/model/book.dart';
import 'package:http/http.dart' as http;
import 'database_helper.dart';

class BookRepository {
  final String baseUrl = 'https://openlibrary.org';
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<List<Book>> searchBooks(String query, {int page = 1, int limit = 20}) async {
    try {
      final offset = (page - 1) * limit;
      final url = '$baseUrl/search.json?q=$query&limit=$limit&offset=$offset';
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> docs = data['docs'] ?? [];
        print("response----------------->> $data");
        return docs.map((json) => Book.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search books: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Book> getBookDetails(String bookKey) async {
    try {
      final url = '$baseUrl$bookKey.json';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Get description
        String? description;
        if (data['description'] != null) {
          if (data['description'] is String) {
            description = data['description'];
          } else if (data['description']['value'] != null) {
            description = data['description']['value'];
          }
        }
        
        return Book(
          key: bookKey,
          title: data['title'] ?? '',
          authors: (data['authors'] as List<dynamic>?)
              ?.map((author) => author['name'] ?? author.toString())
              .toList()
              .cast<String>() ?? [],
          coverId: data['covers']?.first?.toString(),
          firstPublishYear: data['first_publish_year'],
          description: description,
        );
      } else {
        throw Exception('Failed to get book details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<void> saveBook(Book book) async {
    await _databaseHelper.insertBook(book);
  }

  Future<List<Book>> getSavedBooks() async {
    return await _databaseHelper.getAllBooks();
  }

  Future<bool> isBookSaved(String bookKey) async {
    return await _databaseHelper.isBookSaved(bookKey);
  }

  Future<void> removeBook(String bookKey) async {
    await _databaseHelper.deleteBook(bookKey);
  }
}