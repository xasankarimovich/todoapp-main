class TodoItem {
  final int id;
  String title;
  bool isDone;

  TodoItem({
    required this.id,
    required this.title,
    this.isDone = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isDone': isDone ? 1 : 0,
    };
  }

  @override
  String toString() {
    return 'TodoItem{id: $id, title: $title, isDone: $isDone}';
  }
}
