import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mytodolist2/myconfig.dart';
import 'package:url_launcher/url_launcher.dart';

class TodoScreen extends StatefulWidget {
  final String userId;
  final String userEmail;

  const TodoScreen({super.key, required this.userId, required this.userEmail});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final titleController = TextEditingController();
  final descController = TextEditingController();
  final dateController = TextEditingController();

  DateTime? selectedDateTime;
  String? selectedCategory = 'Work';
  bool isCompleted = false;
  bool isReminderEnabled = false;

  final List<String> priorities = ['Important', 'Normal', 'Not Important'];
  String? _selectedPriority = 'Important';

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
  void dispose() {
    titleController.dispose();
    descController.dispose();
    dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('📝 Create Todo'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF90CAF9), Color(0xFF0D47A1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isWide ? 600 : double.infinity,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSectionTitle("Title"),
                  _buildTextField(titleController, 'Enter todo title'),

                  _buildSectionTitle("Date & Time"),
                  _buildDateField(),

                  _buildSectionTitle("Description"),
                  _buildTextField(
                    descController,
                    'Describe your todo...',
                    maxLines: 4,
                  ),

                  _buildSectionTitle("Category"),
                  _buildDropdownCategory(),

                  _buildSectionTitle("Priority"),
                  ...priorities.map(_buildPriorityRadio).toList(),

                  const Divider(height: 30),
                  CheckboxListTile(
                    title: const Text('✔️ Mark as Completed'),
                    value: isCompleted,
                    onChanged: (val) =>
                        setState(() => isCompleted = val ?? false),
                  ),
                  SwitchListTile(
                    title: const Text('🔔 Enable Reminder'),
                    value: isReminderEnabled,
                    onChanged: (val) => setState(() => isReminderEnabled = val),
                  ),

                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.save_rounded),
                    label: const Text('Save Todo'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xFF0D47A1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _handleSubmit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 6),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
        labelText: 'Pick date & time',
        prefixIcon: const Icon(Icons.calendar_today_outlined),
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildPriorityRadio(String priority) {
    return RadioListTile<String>(
      title: Text(priority),
      value: priority,
      groupValue: _selectedPriority,
      onChanged: (val) => setState(() => _selectedPriority = val),
    );
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDateTime ?? now,
      firstDate: now,
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
    if (titleController.text.isEmpty || selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❗ Please fill in the title and date.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Save'),
        content: const Text('Are you sure you want to save this todo?'),
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
            child: const Text('Submit'),
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

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await http.post(
        Uri.parse('${MyConfig.apiUrl}insert_todo.php'),
        body: {
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

      Navigator.pop(context); // Dismiss loading dialog

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == 'success') {
          if (isReminderEnabled) {
            final parsedDate = DateTime.tryParse(date);
            if (parsedDate != null) {
              addToGoogleCalendar(
                title: title,
                description: description,
                startTime: parsedDate,
              );
            }
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Todo added successfully')),
          );
          Navigator.pop(context); // Close todo screen
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('❌ Error: ${json['status']}')));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Server error. Please try again.')),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Dismiss loading dialog if error occurs
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('⚠️ Error submitting: $e')));
    }
  }

  Future<void> addToGoogleCalendar({
    required String title,
    required String description,
    required DateTime startTime,
    Duration duration = const Duration(hours: 1),
  }) async {
    final DateTime endTime = startTime.add(duration);
    final String start = DateFormat("yyyyMMdd'T'HHmmss").format(startTime);
    final String end = DateFormat("yyyyMMdd'T'HHmmss").format(endTime);

    final Uri calendarUrl = Uri.parse(
      'https://www.google.com/calendar/render?action=TEMPLATE'
      '&text=${Uri.encodeComponent(title)}'
      '&details=${Uri.encodeComponent(description)}'
      '&dates=$start/$end',
    );

    // Use launchUrl with web-specific mode
    final bool launched = await launchUrl(
      calendarUrl,
      mode: LaunchMode.externalApplication,
    );

    if (!launched) {
      debugPrint('❌ Could not launch $calendarUrl');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Could not open Google Calendar')),
      );
    }
  }
}
