import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:mytodolist2/edittodoscreen.dart';
import 'package:mytodolist2/myconfig.dart';
import 'package:mytodolist2/todo.dart';
import 'package:mytodolist2/todoscreen.dart';

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
  final df = DateFormat('dd MMM yyyy hh:mm a');
  int numberofResult = 0;
  int numberOfPage = 0;
  int currentPage = 1;

  @override
  void initState() {
    super.initState();
    loadTodos();
  }

  void showDetailsDialog(MyTodo todo) {
    final isCompleted = todo.todoCompleted == 'true';
    final df = DateFormat('dd MMM yyyy hh:mm a');

    showDialog(
      context: context,
      builder: (_) {
        bool localCompleted = isCompleted;

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(todo.todoTitle ?? 'No Title'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Description: ${todo.todoDesc ?? 'N/A'}"),
                  Text("Category: ${todo.todoCategory ?? 'N/A'}"),
                  Text("Priority: ${todo.todoPriority ?? 'N/A'}"),
                  Text(
                    "Due: ${df.format(DateTime.parse(todo.todoDate ?? ''))}",
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    title: const Text("Mark as Completed"),
                    value: localCompleted,
                    onChanged: (val) async {
                      if (val != null) {
                        setStateDialog(() => localCompleted = val);
                        await updateTodoCompleted(todo, val);
                        loadTodos(); // Refresh UI after update
                        Navigator.pop(context);
                      }
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text('Close'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> updateTodoCompleted(MyTodo todo, bool isCompleted) async {
    try {
      final response = await http.post(
        Uri.parse('${MyConfig.apiUrl}update_todo_completed.php'),
        body: {
          'todo_id': todo.todoId,
          'user_id': todo.userId,
          'completed': isCompleted.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] != 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to update: ${data['status']}")),
          );
        }
      }
    } catch (e) {
      log("Error updating completed: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error updating: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MyTodoList'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: loadTodos),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Welcome',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10.0,
              ),
              child: Column(
                children: [
                  if (todoList.isEmpty)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.inbox,
                              size: 70,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              status,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.separated(
                        itemCount: todoList.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final todo = todoList[index];
                          final isCompleted = todo.todoCompleted == 'true';

                          return GestureDetector(
                            onTap: () => showDetailsDialog(todo),
                            child: Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          isCompleted
                                              ? Icons.check_circle
                                              : Icons.radio_button_unchecked,
                                          color: isCompleted
                                              ? Colors.green
                                              : Colors.orange,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            todo.todoTitle ?? 'No Title',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Tooltip(
                                              message: "Edit",
                                              child: IconButton(
                                                icon: const Icon(
                                                  Icons.edit,
                                                  color: Colors.blue,
                                                ),
                                                onPressed: () async {
                                                  await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          EditTodoScreen(
                                                            userId:
                                                                widget.userId!,
                                                            userEmail: widget
                                                                .userEmail!,
                                                            todo: todo,
                                                          ),
                                                    ),
                                                  );
                                                  loadTodos();
                                                },
                                              ),
                                            ),
                                            Tooltip(
                                              message: "Delete",
                                              child: IconButton(
                                                icon: const Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                ),
                                                onPressed: () =>
                                                    deleteDialog(todo),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      todo.todoDesc ?? '',
                                      style: const TextStyle(
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Due: ${df.format(DateTime.parse(todo.todoDate ?? ""))}',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  if (numberOfPage > 1)
                    SizedBox(
                      height: 48,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: numberOfPage,
                        itemBuilder: (context, index) {
                          final isSelected = currentPage == index + 1;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isSelected
                                    ? Colors.blue
                                    : Colors.grey[300],
                                foregroundColor: isSelected
                                    ? Colors.white
                                    : Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  currentPage = index + 1;
                                });
                                loadTodos();
                              },
                              child: Text('${index + 1}'),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TodoScreen(
                userEmail: widget.userEmail!,
                userId: widget.userId!,
              ),
            ),
          );
          loadTodos();
        },
        icon: const Icon(Icons.add),
        label: const Text("Add Todo"),
      ),
    );
  }

  void loadTodos() async {
    try {
      final response = await http.get(
        Uri.parse(
          '${MyConfig.apiUrl}load_todos.php?userid=${widget.userId}&pageno=$currentPage',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        todoList.clear();
        if (data['status'] == 'success') {
          for (var item in data['data']) {
            todoList.add(MyTodo.fromJson(item));
          }
          status = "Todos loaded successfully";
          numberofResult = data['number_of_result'];
          numberOfPage = data['number_of_page'];
          currentPage = data['current_page'];
        } else {
          status = "No todos found.\nPlease add some todos.";
        }
        setState(() {});
      }
    } catch (e) {
      log("Error loading todos: $e");
      status = "Failed to load todos.";
      setState(() {});
    }
  }

  void deleteDialog(MyTodo todo) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Todo'),
        content: Text('Are you sure you want to delete "${todo.todoTitle}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              deleteTodo(todo);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void deleteTodo(MyTodo todo) async {
    try {
      final response = await http.post(
        Uri.parse('${MyConfig.apiUrl}delete_todo.php'),
        body: {'todo_id': todo.todoId, 'user_id': todo.userId},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          loadTodos();
        } else {
          status = "Failed to delete todo.";
          setState(() {});
        }
      }
    } catch (e) {
      log("Delete error: $e");
    }
  }
}
