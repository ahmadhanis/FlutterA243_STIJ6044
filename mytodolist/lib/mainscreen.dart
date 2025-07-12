import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mytodolist/myconfig.dart';
import 'package:mytodolist/todo.dart';
import 'package:mytodolist/todoscreen.dart';
import 'package:http/http.dart' as http;

class MainScreen extends StatefulWidget {
  final String? userId;
  final String? userEmail;

  const MainScreen({super.key, required this.userId, required this.userEmail});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<MyTodo> todoList = [];

  @override
  void initState() {
    super.initState();
    loadTodos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Screen'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              loadTodos();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text('Welcome, ${widget.userEmail ?? 'User'}!'),
            const SizedBox(height: 20),
            Text('Your User ID: ${widget.userId ?? 'N/A'}'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => TodoScreen(
                    userEmail: widget.userEmail.toString(),
                    userId: widget.userId.toString(),
                  ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: const [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('Drawer Header'),
            ),
            ListTile(title: Text('Item 1'), onTap: null),
            ListTile(title: Text('Item 2'), onTap: null),
          ],
        ),
      ),
    );
  }

  void loadTodos() {
    http
        .get(
          Uri.parse('${MyConfig.apiUrl}load_todos.php?userid=${widget.userId}'),
        )
        .then((response) {
          if (response.statusCode == 200) {
            var data = jsonDecode(response.body);
            if (data['status'] == 'success') {
              todoList.clear();
              for (var item in data['data']) {
                // print(item.toString());
                todoList.add(
                  MyTodo.fromJson(item),
                ); // Convert JSON to MyTodo object
              }
              setState(() {}); // Refresh the UI
            } else {
              print('Failed to load todos: ${data['message']}');
            }

            // Handle the response data
          }
        })
        .catchError((error) {
          print('Error loading todos: $error');
        });
  }
}
