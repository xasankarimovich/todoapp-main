import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todoapp/views/screens/todo_app.dart';

class ThemeNotifier extends ChangeNotifier {
  bool _isDarkTheme = false;

  bool get isDarkTheme => _isDarkTheme;

  ThemeData get currentTheme =>
      _isDarkTheme ? ThemeData.dark() : ThemeData.light();

  void toggleTheme() {
    _isDarkTheme = !_isDarkTheme;
    notifyListeners();
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeNotifier(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return MaterialApp(
      theme: themeNotifier.currentTheme,
      home: const TodoApp(),
      debugShowCheckedModeBanner: false,
    );
  }
}
