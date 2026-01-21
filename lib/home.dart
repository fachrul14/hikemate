import 'package:flutter/material.dart';
import 'dashboard.dart';
import 'checklist.dart';
import 'profile.dart';
import 'journal.dart';
import 'lokasi.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    LocationScreen(),
    ChecklistScreen(),
    JournalScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: index,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        height: 55,
        margin: const EdgeInsets.only(bottom: 10, left: 15, right: 15),
        decoration: BoxDecoration(
          color: const Color(0xFF424242),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navIcon(Icons.home_outlined, 0),
            _navIcon(Icons.location_on_outlined, 1),
            _navIcon(Icons.assignment_outlined, 2),
            _navIcon(Icons.edit_note_outlined, 3),
            _navIcon(Icons.person_outline, 4),
          ],
        ),
      ),
    );
  }

  Widget _navIcon(IconData icon, int i) {
    final isSelected = index == i;
    return GestureDetector(
      onTap: () => setState(() => index = i),
      child: Icon(
        icon,
        size: 28,
        color: isSelected ? const Color(0xFF00BCD4) : Colors.white60,
      ),
    );
  }
}
