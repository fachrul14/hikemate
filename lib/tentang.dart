import 'package:flutter/material.dart';

class TentangScreen extends StatelessWidget {
  const TentangScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 1. Header Biru Cyan (Sesuai Desain HikeMate)
          Container(
            padding: const EdgeInsets.only(top: 30, bottom: 10, left: 10, right: 15),
            decoration: const BoxDecoration(
              color: Color(0xFF0097B2), // Warna Biru Cyan HikeMate
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
                    "Tentang Aplikasi",
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

          // 2. Kartu Informasi Tentang
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.black, width: 0.8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(4, 4), // Shadow tegas sesuai gambar
                  ),
                ],
              ),
              child: RichText(
                textAlign: TextAlign.start,
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                    height: 1.5, // Jarak antar baris
                  ),
                  children: [
                    TextSpan(
                      text: "HikeMate ",
                      style: TextStyle(fontWeight: FontWeight.bold,),
                    ),
                    TextSpan(
                      text: "adalah aplikasi mobile berbasis Flutter yang dirancang sebagai solusi terintegrasi bagi para pendaki gunung dalam merencanakan, memantau, dan mendokumentasikan aktivitas mereka. Aplikasi ini hadir untuk menjawab berbagai kendala pendakian, seperti minimnya informasi rute, cuaca yang tidak menentu, kurangnya panduan peralatan, serta absennya sistem darurat yang terdigitalisasi. Guna untuk meningkatkan pengalaman serta keamanan para pendaki melalui satu platform yang mudah digunakan.",
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}