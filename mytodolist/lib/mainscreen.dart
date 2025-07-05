import 'package:flutter/material.dart';
import 'package:mytodolist/todoscreen.dart';

class MainScreen extends StatefulWidget {
  final String? userId;
  final String? userEmail;

  const MainScreen({super.key, required this.userId, required this.userEmail});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Screen'),
        backgroundColor: Colors.blue,
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
}
