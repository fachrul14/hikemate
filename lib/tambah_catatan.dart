import 'package:flutter/material.dart';

class TambahCatatanScreen extends StatelessWidget {
  const TambahCatatanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 1. Header Biru Cyan (LOGO TETAP ASLI)
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
                // LOGO TETAP MENGGUNAKAN IMAGE ASSET
                Image.asset(
                  "assets/images/logo.png",
                  width: 45,
                  height: 45,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.terrain, color: Colors.orange, size: 30),
                ),
                const Expanded(
                  child: Text(
                    "Tambah Catatan Baru",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const Icon(Icons.search, color: Colors.black, size: 28),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Field Nama Gunung
                  _buildLabel("Nama Gunung"),
                  _buildTextField("Nama Gunung"),

                  const SizedBox(height: 15),

                  // Field Tanggal
                  _buildLabel("Tanggal"),
                  _buildTextField("DD/MM/YYYY"),

                  const SizedBox(height: 15),

                  // Field Waktu
                  _buildLabel("Waktu"),
                  SizedBox(
                    width: 100,
                    child: _buildTextField("00.00"),
                  ),

                  const SizedBox(height: 15),

                  // Field Catatan
                  _buildLabel("Catatan"),
                  _buildTextField("", maxLines: 5),

                  const SizedBox(height: 20),

                  // Tombol Pilih Dari Galeri
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0097B2),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black, width: 1.5),
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.black, size: 24),
                      ),
                      const SizedBox(width: 15),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.black, width: 1.5),
                        ),
                        child: const Text(
                          "Pilih Dari Galeri",
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Tombol Simpan Catatan
                  Center(
                    child: Container(
                      width: 200,
                      decoration: BoxDecoration(
                        boxShadow: const [
                          BoxShadow(color: Colors.black, offset: Offset(0, 4)),
                        ],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          // NAVIGASI KEMBALI KE JOURNAL.DART
                          Navigator.pop(context);

                          // Menampilkan pesan sukses singkat
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Catatan berhasil disimpan!"),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0097B2),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: Colors.black, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "SIMPAN CATATAN",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
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

  // Widget Pembantu untuk Label
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  // Widget Pembantu untuk Input Field Gaya Neubrutalism
  Widget _buildTextField(String hint, {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.black, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF0097B2), width: 2),
          ),
        ),
      ),
    );
  }
}