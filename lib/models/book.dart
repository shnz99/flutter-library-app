class Book {
  String title;
  String author;
  String isbn;
  String? imageUrl;
  int? year;
  String? description;
  int? firstAppearanceYear; // Pc8c9

  Book({
    required this.title,
    required this.author,
    required this.isbn,
    this.imageUrl,
    this.year,
    this.description,
    this.firstAppearanceYear, // Pc8c9
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      title: json['title'],
      author: json['author'],
      isbn: json['isbn'],
      imageUrl: json['imageUrl'],
      year: json['year'],
      description: json['description'],
      firstAppearanceYear: json['firstAppearanceYear'], // P897a
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
      'firstAppearanceYear': firstAppearanceYear, // P7bf5
    };
  }
}
