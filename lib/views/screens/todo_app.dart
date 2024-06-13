import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:todoapp/database/todo_database.dart';
import 'package:todoapp/main.dart';
import 'package:todoapp/model/todo_model.dart';

class TodoApp extends StatefulWidget {
  const TodoApp({super.key});

  @override
  State<TodoApp> createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<TodoItem> _todoList = [];

  @override
  void initState() {
    super.initState();
    _loadTodoList();
  }

  void _loadTodoList() async {
    final List<TodoItem> items = await _dbHelper.getTodoItems();
    setState(() {
      _todoList = items;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: TodoSearchDelegate(todoList: _todoList),
              );
            },
          ),
          IconButton(
            icon: Icon(
                themeNotifier.isDarkTheme ? Icons.wb_sunny : Icons.nights_stay),
            onPressed: () {
              themeNotifier.toggleTheme();
            },
          ),
        ],
      ),
      body: _buildTodoList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewTask,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTodoList() {
    return ListView.builder(
      itemCount: _todoList.length,
      itemBuilder: (context, index) {
        return _buildTodoItem(_todoList[index], index);
      },
    );
  }

  Widget _buildTodoItem(TodoItem todoItem, int index) {
    return Slidable(
      key: ValueKey(todoItem.id),
      startActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => _editTask(index),
            icon: Icons.edit,
            label: 'Edit',
          ),
          SlidableAction(
            onPressed: (context) => _deleteTask(index),
            icon: Icons.delete,
            label: 'Delete',
            backgroundColor: Colors.red,
          ),
        ],
      ),
      child: CheckboxListTile(
        title: Text(todoItem.title),
        value: todoItem.isDone,
        onChanged: (bool? value) {
          setState(() {
            todoItem.isDone = value ?? false;
            _dbHelper.updateTodoItem(todoItem);
            if (todoItem.isDone) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('You have completed "${todoItem.title}"')),
              );
            }
          });
        },
      ),
    );
  }

  void _addNewTask() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController _textFieldController =
            TextEditingController();
        return AlertDialog(
          title: const Text('New Task'),
          content: TextField(
            controller: _textFieldController,
            decoration: const InputDecoration(hintText: 'Enter task title'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () async {
                final newItem = TodoItem(
                  id: DateTime.now().millisecondsSinceEpoch,
                  title: _textFieldController.text,
                );
                await _dbHelper.insertTodoItem(newItem);
                _loadTodoList();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _editTask(int index) {
    final TextEditingController _textFieldController = TextEditingController();
    _textFieldController.text = _todoList[index].title;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Task'),
          content: TextField(
            controller: _textFieldController,
            decoration: const InputDecoration(hintText: 'Enter task title'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                final updatedItem = TodoItem(
                  id: _todoList[index].id,
                  title: _textFieldController.text,
                  isDone: _todoList[index].isDone,
                );
                await _dbHelper.updateTodoItem(updatedItem);
                _loadTodoList();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteTask(int index) async {
    await _dbHelper.deleteTodoItem(_todoList[index].id);
    _loadTodoList();
  }
}

class TodoSearchDelegate extends SearchDelegate<TodoItem> {
  final List<TodoItem> todoList;

  TodoSearchDelegate({required this.todoList});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final List<TodoItem> results = todoList
        .where((todoItem) =>
            todoItem.title.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(results[index].title),
          onTap: () {
            close(context, results[index]);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final List<TodoItem> suggestions = todoList
        .where((todoItem) =>
            todoItem.title.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(suggestions[index].title),
          onTap: () {
            query = suggestions[index].title;
            showResults(context);
          },
        );
      },
    );
  }
}
