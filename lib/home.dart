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

  // ===== CONSTANTS =====
  static const double _navHeight = 70;
  static const double _navRadius = 30;
  static const double _itemRadius = 20;

  static const Color _navBg = Color(0xFF2C2C2C);
  static const Color _primary = Color(0xFF00E5FF);
  static const Color _primarySoft = Color(0x3300BCD4); // 20% opacity

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
      extendBody: true,
      body: IndexedStack(
        index: index,
        children: _screens,
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: _navHeight,
          margin: const EdgeInsets.only(bottom: 12, left: 12, right: 12),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: _navBg,
            borderRadius: BorderRadius.circular(_navRadius),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _navItem(Icons.home_rounded, "Home", 0),
              _navItem(Icons.location_on_rounded, "Lokasi", 1),
              _navItem(Icons.assignment_rounded, "Checklist", 2),
              _navItem(Icons.edit_note_rounded, "Jurnal", 3),
              _navItem(Icons.person_rounded, "Profil", 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int i) {
    final isSelected = index == i;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(_itemRadius),
        onTap: () => setState(() => index = i),
        child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: isSelected ? _primarySoft : Colors.transparent,
              borderRadius: BorderRadius.circular(_itemRadius),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedSlide(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  offset: isSelected ? const Offset(0, -0.15) : Offset.zero,
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    scale: isSelected ? 1.15 : 1.0,
                    child: Icon(
                      icon,
                      size: 26,
                      color: isSelected ? _primary : Colors.white60,
                    ),
                  ),
                ),
                if (label.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: isSelected ? 1 : 0.7,
                    child: Text(
                      label,
                      style: TextStyle(
                        color: isSelected ? _primary : Colors.white60,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            )),
      ),
    );
  }
}
