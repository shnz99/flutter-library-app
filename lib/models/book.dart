class Book {
  String title;
  String author;
  String isbn;
  String? imageUrl;
  int? publishedDate;
  String? description;

  Book({
    required this.title,
    required this.author,
    required this.isbn,
    this.imageUrl,
    this.publishedDate,
    this.description,
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
    };
  }

  @override
  String toString() {
    return 'Book{title: $title, author: $author, isbn: $isbn, imageUrl: $imageUrl, publishedDate: $publishedDate, description: $description}';
  }
}
