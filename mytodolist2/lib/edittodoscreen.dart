import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mytodolist2/myconfig.dart';
import 'package:mytodolist2/todo.dart';

class EditTodoScreen extends StatefulWidget {
  final String userId;
  final String userEmail;
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
  final titleController = TextEditingController();
  final descController = TextEditingController();
  final dateController = TextEditingController();

  DateTime? selectedDateTime;
  String? selectedCategory = 'Work';
  bool isCompleted = false;
  bool isReminderEnabled = false;
  final priorities = ['Important', 'Normal', 'Not Important'];
  String? _selectedPriority = 'Important';

  final categories = [
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
    titleController.text = widget.todo.todoTitle ?? '';
    descController.text = widget.todo.todoDesc ?? '';
    selectedCategory = widget.todo.todoCategory ?? 'Work';
    _selectedPriority = widget.todo.todoPriority ?? 'Important';
    isCompleted = widget.todo.todoCompleted == 'true';
    isReminderEnabled = widget.todo.todoReminder == 'true';

    try {
      selectedDateTime = DateTime.parse(widget.todo.todoDate ?? '');
      dateController.text = DateFormat(
        'yyyy-MM-dd HH:mm',
      ).format(selectedDateTime!);
    } catch (_) {
      dateController.text = widget.todo.todoDate ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Todo'),
        backgroundColor: Colors.blue,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isWide ? 600 : double.infinity,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTextField(titleController, 'Todo Title'),
                  const SizedBox(height: 15),
                  _buildDateField(),
                  const SizedBox(height: 15),
                  _buildTextField(descController, 'Description', maxLines: 4),
                  const SizedBox(height: 15),
                  _buildDropdownCategory(),
                  const SizedBox(height: 15),
                  const Text(
                    'Priority:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...priorities.map(_buildPriorityRadio).toList(),
                  const SizedBox(height: 10),
                  CheckboxListTile(
                    title: const Text('Mark as Completed'),
                    value: isCompleted,
                    onChanged: (val) =>
                        setState(() => isCompleted = val ?? false),
                  ),
                  SwitchListTile(
                    title: const Text('Enable Reminder'),
                    value: isReminderEnabled,
                    onChanged: (val) => setState(() => isReminderEnabled = val),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text('Save Changes'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _handleSubmit,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildDateField() {
    return TextField(
      controller: dateController,
      readOnly: true,
      onTap: _pickDateTime,
      decoration: InputDecoration(
        labelText: 'Select Date & Time',
        prefixIcon: const Icon(Icons.calendar_today),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildDropdownCategory() {
    return DropdownButtonFormField<String>(
      value: selectedCategory,
      items: categories
          .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
          .toList(),
      onChanged: (val) => setState(() => selectedCategory = val),
      decoration: InputDecoration(
        labelText: 'Category',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildPriorityRadio(String priority) {
    return ListTile(
      title: Text(priority),
      leading: Radio<String>(
        value: priority,
        groupValue: _selectedPriority,
        onChanged: (val) => setState(() => _selectedPriority = val),
      ),
    );
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDateTime ?? now,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: DateTime(2101),
    );

    if (pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedDateTime ?? now),
    );

    if (pickedTime == null) return;

    final dateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    setState(() {
      selectedDateTime = dateTime;
      dateController.text = DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
    });
  }

  void _handleSubmit() {
    if (titleController.text.isEmpty || dateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in the title and date.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Update'),
        content: const Text('Are you sure you want to update this todo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              submitTodo();
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void submitTodo() async {
    final title = titleController.text.trim();
    final description = descController.text.trim();
    final date = dateController.text.trim();
    final category = selectedCategory ?? 'Work';
    final priority = _selectedPriority ?? 'Important';

    try {
      final response = await http.post(
        Uri.parse('${MyConfig.apiUrl}update_todo.php'),
        body: {
          'todo_id': widget.todo.todoId,
          'userid': widget.userId,
          'useremail': widget.userEmail,
          'title': title,
          'description': description,
          'date': date,
          'category': category,
          'priority': priority,
          'completed': isCompleted.toString(),
          'reminder_enabled': isReminderEnabled.toString(),
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Todo updated successfully')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${json['status']}')));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}
