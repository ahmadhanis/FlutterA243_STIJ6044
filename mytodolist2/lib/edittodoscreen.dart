import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:mytodolist2/myconfig.dart';
import 'package:mytodolist2/todo.dart';

class EditTodoScreen extends StatefulWidget {
  final String userId; // Optional user ID
  final String userEmail; // Optional user email
  final MyTodo todo;

  const EditTodoScreen({
    super.key,
    required this.userId,
    required this.userEmail,
    required this.todo,
  });

  @override
  State<EditTodoScreen> createState() => _EditTodoScreenState();
}

class _EditTodoScreenState extends State<EditTodoScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  DateTime? selectedDateTime;
  String? selectedCategory = 'Work'; // Default category
  bool isCompleted = false;
  bool isReminderEnabled = false;
  final List<String> priorities = ['Important', 'Normal', 'Not Important'];
  String? _selectedPriority = 'Important'; // default selected
  final List<String> categories = [
    'Work',
    'Personal',
    'Home',
    'Shopping',
    'Study',
    'Others',
    'Health',
    'Fitness',
    'Travel',
    'Entertainment',
    'Learning',
    'Family',
  ];

  @override
  void initState() {
    super.initState();
    titleController.text = widget.todo.todoTitle ?? ''; // Set initial value
    descController.text = widget.todo.todoDesc ?? ''; // Set initial value
    dateController.text = widget.todo.todoDate ?? ''; // Set initial value
    selectedCategory = widget.todo.todoCategory ?? 'Work'; // Set initial value
    _selectedPriority =
        widget.todo.todoPriority ?? 'Important'; // Set initial value
    isCompleted =
        bool.parse(widget.todo.todoCompleted.toString()) ??
        false; // Set initial value
    isReminderEnabled =
        bool.parse(widget.todo.todoReminder.toString()) ??
        false; // Set initial value
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Todo'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Todo Title',
                ),
              ),
              const SizedBox(height: 10),

              TextField(
                controller: dateController,
                readOnly: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Select Date & Time',
                ),
                onTap: () async {
                  await _pickDateTime();
                },
              ),
              const SizedBox(height: 10),

              TextField(
                controller: descController,
                maxLines: 4,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Description',
                ),
              ),
              const SizedBox(height: 10),

              DropdownButtonFormField<String>(
                value: selectedCategory,
                items: categories
                    .map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                  });
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Category',
                ),
              ),
              const SizedBox(height: 10),

              const Text(
                'Priority:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Column(
                children: priorities.map((priority) {
                  return ListTile(
                    title: Text(priority),
                    leading: Radio<String>(
                      value: priority,
                      groupValue: _selectedPriority,
                      onChanged: (String? value) {
                        setState(() {
                          _selectedPriority = value;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),

              CheckboxListTile(
                title: const Text('Mark as Completed'),
                value: isCompleted,
                onChanged: (value) {
                  setState(() {
                    isCompleted = value ?? false;
                  });
                },
              ),

              SwitchListTile(
                title: const Text('Enable Reminder'),
                value: isReminderEnabled,
                onChanged: (value) {
                  setState(() {
                    isReminderEnabled = value;
                  });
                },
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _handleSubmit,
                  child: const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDateTime() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDateTime ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate == null) return;

    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedDateTime ?? DateTime.now()),
    );

    if (pickedTime == null) return;

    final newDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    setState(() {
      selectedDateTime = newDateTime;
      dateController.text = newDateTime.toString();
    });
  }

  void _handleSubmit() {
    if (titleController.text.isEmpty || dateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in the title and date.')),
      );
      return;
    }
    //show a confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Submission'),
        content: const Text('Are you sure you want to submit your todo?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              submitTodo();
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void submitTodo() {
    //submit the todo data to tbl_todos table
    String title = titleController.text.trim();
    String description = descController.text.trim();
    String date = dateController.text.trim();
    String category = selectedCategory ?? 'Work';
    String priority = _selectedPriority ?? 'Important';
    bool completed = isCompleted;
    bool reminderEnabled = isReminderEnabled;
    //send the data to the server using http post request insert_todo.php
    http
        .post(
          Uri.parse('${MyConfig.apiUrl}update_todo.php'),
          body: {
            'todo_id': widget.todo.todoId, // Replace with actual todo ID
            'userid': widget.userId, // Replace with actual user ID
            'useremail': widget.userEmail, // Replace with actual user email
            'title': title,
            'description': description,
            'date': date,
            'category': category,
            'priority': priority,
            'completed': completed.toString(),
            'reminder_enabled': reminderEnabled.toString(),
          },
        )
        .then((response) {
          print(response.body);
          if (response.statusCode == 200) {
            var jsonResponse = jsonDecode(response.body);
            if (jsonResponse['status'] == 'success') {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Todo updated successfully')),
              );
              Navigator.pop(context); // Close the TodoScreen
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${jsonResponse['status']}')),
              );
            }
          }
        });
  }
}
