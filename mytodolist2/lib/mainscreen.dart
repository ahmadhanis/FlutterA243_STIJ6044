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
  bool isLoading = false; // Add to your state class
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;
  final searchController = TextEditingController();
  late double screenWidth, screenHeight;
  @override
  void initState() {
    super.initState();
    loadTodos(month: selectedMonth, year: selectedYear);
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: Colors.blueAccent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      todo.todoTitle ?? 'No Title',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow("Description", todo.todoDesc ?? 'N/A'),
                    _buildInfoRow("Category", todo.todoCategory ?? 'N/A'),
                    _buildInfoRow("Priority", todo.todoPriority ?? 'N/A'),
                    _buildInfoRow(
                      "Due Date",
                      df.format(
                        DateTime.tryParse(todo.todoDate ?? '') ??
                            DateTime.now(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Divider(),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text("Mark as Completed"),
                      value: localCompleted,
                      activeColor: Theme.of(context).colorScheme.primary,
                      onChanged: (val) async {
                        if (val != null) {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Confirm Completion'),
                              content: const Text(
                                'Are you sure you want to mark this task as completed?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Yes, Confirm'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            setStateDialog(() => localCompleted = val);
                            await updateTodoCompleted(todo, val);
                            loadTodos();
                            Navigator.pop(context);
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton.icon(
                  icon: Icon(Icons.close),
                  label: const Text('Close'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100, // Adjust width to align all labels
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  Future<void> updateTodoCompleted(MyTodo todo, bool isCompleted) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await http.post(
        Uri.parse('${MyConfig.apiUrl}update_todo_completed.php'),
        body: {
          'todo_id': todo.todoId,
          'user_id': todo.userId,
          'completed': isCompleted.toString(),
        },
      );

      Navigator.pop(context); // Close loading dialog

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("✅ Completed status updated.")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("❌ Failed to update: ${data['status']}")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Server error while updating.")),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Ensure dialog is closed on exception
      log("Error updating completed: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("⚠️ Error updating: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 600;
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF90CAF9), Color(0xFF0D47A1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'MyTodoList',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actionsIconTheme: const IconThemeData(color: Colors.black87),
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          Tooltip(
            message: 'Refresh',
            child: IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                loadTodos(month: selectedMonth, year: selectedYear);
              },
            ),
          ),
          Tooltip(
            message: 'Search Todo',
            child: IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                showTodoDialogSearch();
              },
            ),
          ),
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
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
              child: Center(
                child: SizedBox(
                  width: isWideScreen ? 600 : double.infinity,
                  child: Column(
                    children: [
                      Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 12.0,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                color: Colors.blue,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: DropdownButtonFormField<int>(
                                  decoration: const InputDecoration(
                                    labelText: "Month",
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                  ),
                                  value: selectedMonth,
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() {
                                        selectedMonth = val;
                                        currentPage = 1;
                                      });
                                      loadTodos(
                                        month: selectedMonth,
                                        year: selectedYear,
                                      );
                                    }
                                  },
                                  items: List.generate(12, (index) {
                                    final month = index + 1;
                                    return DropdownMenuItem(
                                      value: month,
                                      child: Text(
                                        DateFormat.MMMM().format(
                                          DateTime(0, month),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: DropdownButtonFormField<int>(
                                  decoration: const InputDecoration(
                                    labelText: "Year",
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                  ),
                                  value: selectedYear,
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() {
                                        selectedYear = val;
                                        currentPage = 1;
                                      });
                                      loadTodos(
                                        month: selectedMonth,
                                        year: selectedYear,
                                      );
                                    }
                                  },
                                  items: List.generate(6, (index) {
                                    final year =
                                        DateTime.now().year - 2 + index;
                                    return DropdownMenuItem(
                                      value: year,
                                      child: Text('$year'),
                                    );
                                  }),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

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
                          child: isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : ListView.separated(
                                  itemCount: todoList.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final todo = todoList[index];
                                    final isCompleted =
                                        todo.todoCompleted == 'true';

                                    return GestureDetector(
                                      onTap: () => showDetailsDialog(todo),
                                      child: Card(
                                        elevation: 3,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(
                                                    isCompleted
                                                        ? Icons.check_circle
                                                        : Icons
                                                              .radio_button_unchecked,
                                                    color: isCompleted
                                                        ? Colors.green
                                                        : Colors.orange,
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Expanded(
                                                    child: Text(
                                                      todo.todoTitle ??
                                                          'No Title',
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
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
                                                                builder: (_) => EditTodoScreen(
                                                                  userId: widget
                                                                      .userId!,
                                                                  userEmail: widget
                                                                      .userEmail!,
                                                                  todo: todo,
                                                                ),
                                                              ),
                                                            );
                                                            loadTodos(
                                                              month:
                                                                  selectedMonth,
                                                              year:
                                                                  selectedYear,
                                                            );
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
                                                              deleteDialog(
                                                                todo,
                                                              ),
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
                      SizedBox(height: 10),
                      if (numberOfPage > 1)
                        SizedBox(
                          height: 48,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: numberOfPage,
                            itemBuilder: (context, index) {
                              final isSelected = currentPage == index + 1;
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
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
                                    loadTodos(
                                      month: selectedMonth,
                                      year: selectedYear,
                                    );
                                  },
                                  child: Text('${index + 1}'),
                                ),
                              );
                            },
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
          loadTodos(month: selectedMonth, year: selectedYear);
        },
        icon: const Icon(Icons.add),
        label: const Text("Add Todo"),
      ),
    );
  }

  void loadTodos({int? month, int? year}) async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
      status = "Loading todos...";
    });

    try {
      // Optional query params for filtering by month/year
      String url =
          '${MyConfig.apiUrl}load_todos.php?userid=${widget.userId}&pageno=$currentPage';

      if (month != null && year != null) {
        url += '&month=$month&year=$year';
      }

      final response = await http.get(Uri.parse(url));

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
          status = "No todos found for selected month.";
        }
      } else {
        status = "Server error ${response.statusCode}";
      }
    } catch (e) {
      log("Error loading todos: $e");
      status = "Failed to load todos.";
    }

    setState(() {
      isLoading = false;
    });
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
          loadTodos(month: selectedMonth, year: selectedYear);
        } else {
          status = "Failed to delete todo.";
          setState(() {});
        }
      }
    } catch (e) {
      log("Delete error: $e");
    }
  }

  void showTodoDialogSearch() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.search, color: Colors.blue),
            SizedBox(width: 8),
            Text('Search Todo'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: TextField(
            controller: searchController,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Todo title',
              hintText: 'Enter a keyword...',
              prefixIcon: const Icon(Icons.title),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          searchController.clear();
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
            ),
            onChanged: (_) =>
                setState(() {}), // Needed to update suffixIcon dynamically
            onSubmitted: (value) {
              Navigator.pop(context);
              final searchTerm = value.trim();
              if (searchTerm.isNotEmpty) {
                searchTodos(searchTerm);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please enter a search term")),
                );
              }
            },
          ),
        ),
        actionsPadding: const EdgeInsets.only(right: 16, bottom: 8),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.search),
            label: const Text('Search'),
            onPressed: () {
              Navigator.pop(context);
              final searchTerm = searchController.text.trim();
              if (searchTerm.isNotEmpty) {
                searchTodos(searchTerm);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please enter a search term")),
                );
              }
            },
          ),
          TextButton.icon(
            icon: const Icon(Icons.cancel_outlined),
            label: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void searchTodos(String searchTerm) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${MyConfig.apiUrl}load_todos.php'
          '?userid=${widget.userId}&search=$searchTerm&month=$selectedMonth&year=$selectedYear&current_page=$currentPage',
        ),
      );
      log("Search Response: ${response.body}");
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
          status = "No todos found for search term.";
        }
      } else {
        status = "Server error ${response.statusCode}";
      }
    } catch (e) {
      log("Error searching todos: $e");
      status = "Failed to search todos.";
    }

    setState(() {
      isLoading = false;
      if (todoList.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No results found for '$searchTerm'")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Found ${todoList.length} results")),
        );
      }
    });
  }
}
