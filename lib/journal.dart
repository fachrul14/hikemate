import 'package:flutter/material.dart';
import 'tambah_catatan.dart'; // Pastikan file tujuan sudah di-import

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 1. Header Biru (LOGO TETAP ASLI)
          Container(
            padding: const EdgeInsets.only(top: 30, bottom: 5, left: 15, right: 15),
            decoration: const BoxDecoration(
              color: Color(0xFF0097B2), 
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Row(
              children: [
                // LOGO TETAP MENGGUNAKAN IMAGE ASSET SESUAI CODING ANDA
                Image.asset(
                  "assets/images/logo.png", 
                  width: 45,
                  height: 45,
                  errorBuilder: (context, error, stackTrace) => 
                    const Icon(Icons.terrain, color: Colors.orange, size: 30),
                ),
                const Expanded(
                  child: Text(
                    "Jurnal Perjalanan",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Memanggil fungsi tombol dengan menyertakan context
                  _buildAddNoteButton(context),
                  const SizedBox(height: 20),
                  _buildJournalHeaderItem(
                    title: "Pendakian Gn. Gede",
                    date: "10 Mei 2024, 07.00",
                  ),
                  const SizedBox(height: 20),
                  _buildJournalCard(
                    title: "Gunung Rinjani",
                    date: "10 Mei 2024, 07.00",
                    description: "Momen tak terlupakan, saat menikmati alam yang indah di Gunung Rinjani. Rasa lelah perjalanan dari pos 1 sampai puncak ini semua fair dengan keindahan alam Rinjani ini.",
                    imagePath: "assets/images/rinjani.png",
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Fungsi Tombol yang sekarang bisa diklik
  Widget _buildAddNoteButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigasi ke halaman TambahCatatanScreen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TambahCatatanScreen()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: const Color(0xFF90CAF9),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.black, width: 1),
          boxShadow: const [
            BoxShadow(color: Colors.black45, offset: Offset(4, 4)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(color: Color(0xFF0097B2), shape: BoxShape.circle),
              child: const Icon(Icons.edit, color: Colors.black, size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              "+ Tambah Catatan Baru",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  // Widget lainnya tetap sama...
  Widget _buildJournalHeaderItem({required String title, required String date}) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black, width: 1),
        boxShadow: const [
          BoxShadow(color: Colors.black45, offset: Offset(4, 4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.camera_alt, size: 16, color: Colors.black),
            label: const Text("Unggah Dari Galeri", style: TextStyle(color: Colors.black, fontSize: 10)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[300],
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJournalCard({
    required String title,
    required String date,
    required String description,
    required String imagePath,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black, width: 1),
        boxShadow: const [
          BoxShadow(color: Colors.black45, offset: Offset(4, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: Image.asset(
              imagePath,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 180,
                color: Colors.grey[200],
                child: const Center(child: Text("Gambar tidak ditemukan")),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.red, size: 18),
                        const SizedBox(width: 5),
                        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    Text(date, style: const TextStyle(color: Colors.grey, fontSize: 10)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12, height: 1.4),
                  textAlign: TextAlign.justify,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}