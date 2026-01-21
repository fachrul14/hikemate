import 'package:flutter/material.dart';

class InformasiAkunScreen extends StatelessWidget {
  const InformasiAkunScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 1. Header Biru Cyan
          Container(
            padding: const EdgeInsets.only(top: 30, bottom: 5, left: 10, right: 15),
            decoration: const BoxDecoration(
              color: Color(0xFF0097B2),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                Image.asset(
                  "assets/images/logo.png",
                  width: 45,
                  height: 45,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.terrain, color: Colors.orange, size: 30),
                ),
                const Expanded(
                  child: Text(
                    "Informasi Akun",
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

          const SizedBox(height: 30),

          // 2. Kartu Informasi Akun
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xFF0097B2), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoItem("Nama Pengguna", "Hemachandra"),
                  const SizedBox(height: 15),
                  _buildInfoItem("Info Kontak", "+6285652130476\nhema234@gmail.com"),
                  const SizedBox(height: 15),
                  _buildInfoItem("Jenis Kelamin", "Laki-Laki"),
                  const SizedBox(height: 15),
                  _buildInfoItem("Tanggal Lahir", "13-09-2003"),
                  const SizedBox(height: 15),
                  _buildInfoItem("Kontak Darurat", "Rania (+6285693547261)\nNathan (+6285735217098)"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget Helper untuk item informasi
  Widget _buildInfoItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.grey,
            height: 1.3, // Memberikan jarak antar baris jika teks multiline
          ),
        ),
      ],
    );
  }
}