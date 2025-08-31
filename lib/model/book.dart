class Book {
  final String? key;
  final String title;
  final List<String> authors;
  final String? coverId;
  final int? firstPublishYear;
  final List<String>? isbn;
  final String? description;

  Book({
    this.key,
    required this.title,
    required this.authors,
    this.coverId,
    this.firstPublishYear,
    this.isbn,
    this.description,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      key: json['key'],
      title: json['title'] ?? '',
      authors: (json['author_name'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      coverId: json['cover_i']?.toString(),
      firstPublishYear: json['first_publish_year'],
      isbn: (json['isbn'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }

  factory Book.fromDatabase(Map<String, dynamic> map) {
    return Book(
      key: map['book_key'],
      title: map['title'],
      authors: map['authors'].split(','),
      coverId: map['cover_id'],
      firstPublishYear: map['first_publish_year'],
      isbn: map['isbn']?.split(','),
      description: map['description'],
    );
  }

  Map<String, dynamic> toDatabase() {
    return {
      'book_key': key,
      'title': title,
      'authors': authors.join(','),
      'cover_id': coverId,
      'first_publish_year': firstPublishYear,
      'isbn': isbn?.join(','),
      'description': description,
    };
  }

  String get coverUrl {
    if (coverId != null) {
      return 'https://covers.openlibrary.org/b/id/$coverId-L.jpg';
    }
    return '';
  }

  String get authorsString => authors.join(', ');
}