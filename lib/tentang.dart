import 'package:flutter/material.dart';
import 'package:hikemate/widgets/app_header.dart';

class TentangScreen extends StatelessWidget {
  const TentangScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          AppHeader(
            title: "Tentang Aplikasi",
            showBack: true,
            onBack: () => Navigator.pop(context),
          ),

          const SizedBox(height: 30),

          // Kartu Informasi Tentang
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
                    offset: const Offset(4, 4),
                  ),
                ],
              ),
              child: const Text(
                "HikeMate adalah aplikasi mobile berbasis Flutter yang dirancang sebagai solusi terintegrasi bagi para pendaki gunung dalam merencanakan, memantau, dan mendokumentasikan aktivitas mereka.\n\n"
                "Aplikasi ini hadir untuk menjawab berbagai kendala pendakian, seperti minimnya informasi rute, cuaca yang tidak menentu, kurangnya panduan peralatan, serta absennya sistem darurat yang terdigitalisasi.\n\n"
                "Tujuannya adalah meningkatkan pengalaman serta keamanan para pendaki melalui satu platform yang mudah digunakan.",
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                  height: 1.6, // jarak antar baris lebih lega
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
