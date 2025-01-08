class Book {
  String title;
  String author;
  String isbn;
  String? notes;
  double rating;
  double readingProgress;
  String? imageUrl;

  Book({
    required this.title,
    required this.author,
    required this.isbn,
    this.notes,
    required this.rating,
    required this.readingProgress,
    this.imageUrl,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      title: json['title'],
      author: json['author'],
      isbn: json['isbn'],
      notes: json['notes'],
      rating: json['rating'],
      readingProgress: json['readingProgress'],
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'author': author,
      'isbn': isbn,
      'notes': notes,
      'rating': rating,
      'readingProgress': readingProgress,
    };
  }
}
