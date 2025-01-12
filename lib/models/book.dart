class Book {
  String title;
  String author;
  String isbn;
  String? isbn10;
  String? imageUrl;
  int? publishedDate;
  String? description;
  double? myRating;
  double? averageRating;

  Book({
    required this.title,
    required this.author,
    required this.isbn,
    this.isbn10,
    this.imageUrl,
    this.publishedDate,
    this.description,
    this.myRating,
    this.averageRating,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      title: json['title'],
      author: json['author'],
      isbn: (json['industryIdentifiers'] as List<dynamic>?)
          ?.firstWhere((id) => id['type'] == 'ISBN_13', orElse: () => null)?['identifier'] ?? '',
      isbn10: (json['industryIdentifiers'] as List<dynamic>?)
          ?.firstWhere((id) => id['type'] == 'ISBN_10', orElse: () => null)?['identifier'] ?? '',
      imageUrl: json['imageUrl'],
      publishedDate: json['publishedDate'],
      description: json['description'],
      myRating: json['myRating']?.toDouble(),
      averageRating: json['averageRating']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'author': author,
      'isbn': isbn,
      'isbn10': isbn10,
      'imageUrl': imageUrl,
      'publishedDate': publishedDate,
      'description': description,
      'myRating': myRating,
      'averageRating': averageRating,
    };
  }

  @override
  String toString() {
    return 'Book{title: $title, author: $author, isbn: $isbn, isbn10: $isbn10, imageUrl: $imageUrl, publishedDate: $publishedDate, description: $description, myRating: $myRating, averageRating: $averageRating}';
  }
}
