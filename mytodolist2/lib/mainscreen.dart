import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mytodolist2/edittodoscreen.dart';
import 'package:mytodolist2/myconfig.dart';
import 'package:mytodolist2/todo.dart';
import 'package:mytodolist2/todoscreen.dart';
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
  String status = "Loading todos...";
  final df = DateFormat('dd-MM-yyyy hh:mm a');
  int numberofResult = 0;
  int numberOfPage = 0;
  int currentPage = 1;
  var color;

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
            todoList.isEmpty
                ? Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 50, color: Colors.red),
                        Text(
                          status,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  )
                : Expanded(
                    child: ListView(
                      children: todoList.map((todo) {
                        return ListTile(
                          leading: Icon(
                            todo.todoCompleted == 'true'
                                ? Icons.check_box
                                : Icons.square,
                            color: todo.todoCompleted == 'true'
                                ? Colors.green
                                : Colors.red,
                          ),
                          title: Text(todo.todoTitle.toString()),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(todo.todoDesc.toString()),
                              Text(
                                'Due: ${df.format(DateTime.parse(todo.todoDate.toString()))}',
                              ),
                            ],
                          ),
                          trailing: Column(
                            children: [
                              GestureDetector(
                                child: Icon(Icons.delete, color: Colors.red),
                                onTap: () {
                                  deleteDialog(todo);
                                },
                              ),
                              const SizedBox(height: 4),
                              GestureDetector(
                                child: Icon(Icons.edit, color: Colors.blue),
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditTodoScreen(
                                        userId: widget.userId.toString(),
                                        userEmail: widget.userEmail.toString(),
                                        todo: todo,
                                      ),
                                    ),
                                  );
                                  loadTodos(); // Reload todos after editing
                                },
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
            SizedBox(
              height: 60,
              // height: screenHeight * 0.05,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: numberOfPage,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  color = (currentPage - 1) == index
                      ? Colors.red
                      : Colors.black;
                  return TextButton(
                    onPressed: () {
                      currentPage = index + 1;
                      loadTodos();
                    },
                    child: Text(
                      (index + 1).toString(),
                      style: TextStyle(color: color, fontSize: 18),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TodoScreen(
                userEmail: widget.userEmail.toString(),
                userId: widget.userId.toString(),
              ),
            ),
          );
          loadTodos(); // Reload todos after adding a new one
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
          Uri.parse(
            '${MyConfig.apiUrl}load_todos.php?userid=${widget.userId}&pageno=$currentPage',
          ),
        )
        .then((response) {
          if (response.statusCode == 200) {
            var data = jsonDecode(response.body);
            log(data.toString());
            todoList.clear();
            if (data['status'] == 'success') {
              for (var item in data['data']) {
                // print(item.toString());
                //add each todo item to the todoList array object
                todoList.add(
                  MyTodo.fromJson(item),
                ); // Convert JSON to MyTodo object
                status = "Todos loaded successfully";
                numberofResult = data['number_of_result'];
                numberOfPage = data['number_of_page'];
                currentPage = data['current_page'];
              }
            } else {
              print('Failed to load todos: ${data['message']}');
              status = "'No todos found\nPlease add some todos'";
            }
            setState(() {}); // Refresh the UI
            // Handle the response data
          }
        })
        .catchError((error) {
          print('Error loading todos: $error');
        });
  }

  void deleteDialog(MyTodo todo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete this Todo?'),
          content: Text('Are you sure you want to delete "${todo.todoTitle}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                deleteTodo(todo);
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void deleteTodo(MyTodo todo) {
    http
        .post(
          Uri.parse('${MyConfig.apiUrl}delete_todo.php'),
          body: {'todo_id': todo.todoId, 'user_id': todo.userId},
        )
        .then((response) {
          if (response.statusCode == 200) {
            var data = jsonDecode(response.body);
            log(data.toString());
            if (data['status'] == 'success') {
              // Remove the todo from the list
              todoList.remove(todo);
              status = "Todo deleted successfully";
              loadTodos(); // Reload todos after deletion
            } else {
              print('Failed to delete todo: ${data['message']}');
              status = "Failed to delete todo";
            }
            setState(() {}); // Refresh the UI
          } else {
            print('Error deleting todo: ${response.statusCode}');
          }
        });
  }
}
