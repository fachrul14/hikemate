import 'package:flutter/material.dart';
import 'models/journal.dart';
import 'package:hikemate/widgets/app_header.dart';

class DetailJournalScreen extends StatefulWidget {
  final Journal journal;

  const DetailJournalScreen({
    super.key,
    required this.journal,
  });

  @override
  State<DetailJournalScreen> createState() => _DetailJournalScreenState();
}

class _DetailJournalScreenState extends State<DetailJournalScreen> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  _buildImages(),
                  _buildDots(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTitle(),
                        const SizedBox(height: 6),
                        _buildDate(),
                        const SizedBox(height: 20),
                        _buildNote(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= HEADER =================
  Widget _buildHeader(BuildContext context) {
    return AppHeader(
      title: "Detail Catatan",
      showBack: true, // tampilkan panah back di kiri
      onBack: () => Navigator.pop(context),
    );
  }

  // ================= IMAGES =================
  // ================= IMAGES =================
  Widget _buildImages() {
    if (widget.journal.imageUrls.isEmpty) {
      return Container(
        height: 240,
        color: Colors.grey[200],
        child: const Center(child: Text("Tidak ada gambar")),
      );
    }

    return SizedBox(
      height: 240,
      child: PageView.builder(
        itemCount: widget.journal.imageUrls.length,
        onPageChanged: (index) => setState(() => currentIndex = index),
        itemBuilder: (context, index) {
          final imageUrl = widget.journal.imageUrls[index];
          return GestureDetector(
            onTap: () {
              // buka fullscreen saat gambar ditekan
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FullscreenImageScreen(imageUrl: imageUrl),
                ),
              );
            },
            child: Container(
              color: Colors.grey[200],
              child: FittedBox(
                fit: BoxFit.contain, // 🔹 agar portrait/landscape proporsional
                child: Image.network(imageUrl),
              ),
            ),
          );
        },
      ),
    );
  }

  // ================= DOT INDICATOR =================
  Widget _buildDots() {
    if (widget.journal.imageUrls.length <= 1) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          widget.journal.imageUrls.length,
          (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: currentIndex == index ? 10 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: currentIndex == index
                  ? const Color(0xFF0097B2)
                  : Colors.grey[400],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }

  // ================= TITLE =================
  Widget _buildTitle() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.location_on, color: Colors.red),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            widget.journal.mountainName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
      ],
    );
  }

  // ================= DATE =================
  Widget _buildDate() {
    final d = widget.journal.createdAt;
    return Text(
      "${d.day}/${d.month}/${d.year}",
      style: const TextStyle(color: Colors.grey, fontSize: 12),
    );
  }

  // ================= NOTE =================
  Widget _buildNote() {
    return Text(
      widget.journal.note,
      style: const TextStyle(fontSize: 14, height: 1.7),
      textAlign: TextAlign.justify,
    );
  }
}

class FullscreenImageScreen extends StatelessWidget {
  final String imageUrl;

  const FullscreenImageScreen({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                panEnabled: true,
                minScale: 1,
                maxScale: 4,
                child: Image.network(imageUrl),
              ),
            ),
            Positioned(
              top: 20,
              left: 10,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
