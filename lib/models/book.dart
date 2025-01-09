class Book {
  String title;
  String author;
  String isbn;
  String? imageUrl;
  int? year;
  String? description;

  Book({
    required this.title,
    required this.author,
    required this.isbn,
    this.imageUrl,
    this.year,
    this.description,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      title: json['title'],
      author: json['author'],
      isbn: json['isbn'],
      imageUrl: json['imageUrl'],
      year: json['year'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'author': author,
      'isbn': isbn,
      'imageUrl': imageUrl,
      'year': year,
      'description': description,
    };
  }
}
