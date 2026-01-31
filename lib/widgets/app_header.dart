import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final bool showBack;
  final VoidCallback? onBack;

  const AppHeader({
    super.key,
    required this.title,
    this.showBack = false,
    this.onBack,
  });

  static const double _sideWidth = 45;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        top: 30,
        bottom: 10,
        left: 15,
        right: 15,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF0097B2),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(15),
        ),
      ),
      child: Row(
        children: [
          // ================= LEFT =================
          SizedBox(
            width: _sideWidth,
            child: showBack
                ? IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                    onPressed: onBack ?? () => Navigator.pop(context),
                  )
                : Image.asset(
                    "assets/images/logo.png",
                    width: 40,
                    height: 40,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.terrain,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
          ),

          // ================= CENTER =================
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),

          // ================= RIGHT =================
          SizedBox(
            width: _sideWidth,
            child: showBack
                ? Image.asset(
                    "assets/images/logo.png",
                    width: 40,
                    height: 40,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.terrain,
                      color: Colors.white,
                      size: 36,
                    ),
                  )
                : const SizedBox(), // kosong kalau tidak ada back
          ),
        ],
      ),
    );
  }
}
