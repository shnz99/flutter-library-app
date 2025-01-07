class Book {
  String title;
  String author;
  String isbn;
  String notes;

  Book({this.title, this.author, this.isbn, this.notes});

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      title: json['title'],
      author: json['author'],
      isbn: json['isbn'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'author': author,
      'isbn': isbn,
      'notes': notes,
    };
  }
}
