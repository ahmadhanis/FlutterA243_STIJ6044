import 'package:flutter/material.dart';

enum Priority { important, notImportant }

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  DateTime? selectedDateTime;
  TextEditingController dateController = TextEditingController();
  Priority? _priority = Priority.important;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo Screen'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(height: 300, width: 600, color: Colors.red),
                SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Todo',
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: dateController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Select Date',
                  ),
                  onTap: () async {
                    await _pickDateTime();
                  },
                ),
                SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Description',
                  ),
                  maxLines: 5,
                ),
                Column(
                  children: [
                    ListTile(
                      title: const Text('Important'),
                      leading: Radio<Priority>(
                        value: Priority.important,
                        groupValue: _priority,
                        onChanged: (Priority? value) {
                          setState(() {
                            _priority = value;
                          });
                        },
                      ),
                    ),
                    ListTile(
                      title: const Text('Not Important'),
                      leading: Radio<Priority>(
                        value: Priority.notImportant,
                        groupValue: _priority,
                        onChanged: (Priority? value) {
                          setState(() {
                            _priority = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                ElevatedButton(onPressed: () {}, child: const Text('Submit')),
              ],
            ),
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
}
