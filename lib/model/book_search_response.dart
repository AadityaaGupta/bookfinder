class BookSearchResponse {
  final int numFound;
  final List<BookDto> docs;

  BookSearchResponse({
    required this.numFound,
    required this.docs,
  });

  factory BookSearchResponse.fromJson(Map<String, dynamic> json) {
    return BookSearchResponse(
      numFound: json['numFound'] ?? 0,
      docs: (json['docs'] as List<dynamic>?)
          ?.map((doc) => BookDto.fromJson(doc))
          .toList() ?? [],
    );
  }
}

class BookDto {
  final String? key;
  final String? title;
  final List<String>? authorName;
  final List<String>? isbn;
  final int? firstPublishYear;
  final int? numberOfPagesMedian;
  final List<String>? subject;

  BookDto({
    this.key,
    this.title,
    this.authorName,
    this.isbn,
    this.firstPublishYear,
    this.numberOfPagesMedian,
    this.subject,
  });

  factory BookDto.fromJson(Map<String, dynamic> json) {
    return BookDto(
      key: json['key'],
      title: json['title'],
      authorName: (json['author_name'] as List<dynamic>?)
          ?.map((name) => name.toString())
          .toList(),
      isbn: (json['isbn'] as List<dynamic>?)
          ?.map((isbn) => isbn.toString())
          .toList(),
      firstPublishYear: json['first_publish_year'],
      numberOfPagesMedian: json['number_of_pages_median'],
      subject: (json['subject'] as List<dynamic>?)
          ?.map((subject) => subject.toString())
          .toList(),
    );
  }

  String? get coverUrl {
    if (isbn != null && isbn!.isNotEmpty) {
      return 'https://covers.openlibrary.org/b/isbn/${isbn!.first}-M.jpg';
    }
    return null;
  }
}