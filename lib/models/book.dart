class Book {
  String title;
  String author;
  String isbn;
  String? imageUrl;
  int? publishedDate;
  String? description;
  double? myRating;
  double? averageRating;
  String? category;
  DateTime? readDate;
  String? notes;

  Book({
    required this.title,
    required this.author,
    required this.isbn,
    this.imageUrl,
    this.publishedDate,
    this.description,
    this.myRating,
    this.averageRating,
    String? category,
    this.readDate,
    this.notes,
  }) : category = category?.isEmpty ?? true ? 'None' : category;

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
      category: (json['category'] as String?)?.isEmpty ?? true ? 'None' : json['category'],
      readDate: json['readDate'] != null ? DateTime.parse(json['readDate']) : null,
      notes: json['notes'],
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
      'category': category,
      'readDate': readDate?.toIso8601String(),
      'notes': notes,
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
      'category': category,
      'readDate': readDate?.toIso8601String(),
      'notes': notes,
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
      category: (map['category'] as String?)?.isEmpty ?? true ? 'None' : map['category'],
      readDate: map['readDate'] != null ? DateTime.parse(map['readDate']) : null,
      notes: map['notes'],
    );
  }

  @override
  String toString() {
    return 'Book{title: $title, author: $author, isbn: $isbn, imageUrl: $imageUrl, publishedDate: $publishedDate, description: $description, myRating: $myRating, averageRating: $averageRating, category: $category, readDate: $readDate, notes: $notes}';
  }
}
