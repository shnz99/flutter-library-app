class Book {
  String title;
  String author;
  String isbn;
  String? imageUrl;
  int? publishedDate;
  String? description;
  double? myRating;
  double? averageRating;

  Book({
    required this.title,
    required this.author,
    required this.isbn,
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
      'imageUrl': imageUrl,
      'publishedDate': publishedDate,
      'description': description,
      'myRating': myRating,
      'averageRating': averageRating,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'isbn': isbn,
      'imageUrl': imageUrl,
      'publishedDate': publishedDate,
      'description': description,
      'myRating': myRating,
      'averageRating': averageRating,
    };
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      title: map['title'],
      author: map['author'],
      isbn: map['isbn'],
      imageUrl: map['imageUrl'],
      publishedDate: map['publishedDate'],
      description: map['description'],
      myRating: map['myRating']?.toDouble(),
      averageRating: map['averageRating']?.toDouble(),
    );
  }

  @override
  String toString() {
    return 'Book{title: $title, author: $author, isbn: $isbn, imageUrl: $imageUrl, publishedDate: $publishedDate, description: $description, myRating: $myRating, averageRating: $averageRating}';
  }
}
