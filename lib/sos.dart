import 'package:flutter/material.dart';

class SosScreen extends StatelessWidget {
  const SosScreen({super.key});

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
                    "Mode SOS",
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
                  // 2. Tombol Kirim Sinyal Darurat (Neubrutalism Style)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.black, width: 1.5),
                      boxShadow: const [
                        BoxShadow(color: Colors.black, offset: Offset(4, 4)),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF2D2D), // Merah SOS
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          "KIRIM SINYAL DARURAT",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // 3. Card Lokasi Terakhir & Kontak
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Lokasi Terakhir Anda",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "JFP8+38P, Unnamed Road, Sembalun Lawang, Kec. Sembalun, Kabupaten Lombok Timur, Nusa Tenggara Barat 83656",
                          style: TextStyle(fontSize: 12, color: Colors.black87),
                        ),
                        
                        const SizedBox(height: 15),
                        
                        // Placeholder Peta Lokasi
                        Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Image.asset(
                            "assets/images/mini_map.png", // Ganti dengan gambar peta kecil Anda
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Center(child: Icon(Icons.map, size: 50, color: Colors.grey)),
                          ),
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          "Kontak Yang Bisa Dihubungi",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 15),
                        
                        // Daftar Kontak
                        _buildContactItem("Steven", "(+6285673840213)"),
                        const SizedBox(height: 10),
                        _buildContactItem("Gerry", "(+6285647639643)"),
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

  // Widget Pembantu untuk Baris Kontak
  Widget _buildContactItem(String name, String phone) {
    return Row(
      children: [
        const Icon(Icons.phone_in_talk, color: Colors.black, size: 28),
        const SizedBox(width: 15),
        Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
        ),
        const SizedBox(width: 5),
        Text(
          phone,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
      ],
    );
  }
}