import 'package:flutter/material.dart';

class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({super.key});

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  // Path gambar disesuaikan dengan nama file di folder assets kamu
  final List<Map<String, dynamic>> items = [
    {"name": "Baju trekking (dry-fit)", "img": "assets/images/baju.png", "isChecked": false},
    {"name": "Celana gunung", "img": "assets/images/celana.png", "isChecked": false},
    {"name": "Jaket gunung", "img": "assets/images/jaket.png", "isChecked": false},
    {"name": "Kaos kaki gunung", "img": "assets/images/kaos_kaki.png", "isChecked": false},
    {"name": "Sarung tangan", "img": "assets/images/sarung_tangan.png", "isChecked": false},
    {"name": "Penutup kepala (kupluk)", "img": "assets/images/kupluk.png", "isChecked": false},
    {"name": "Sepatu gunung (boots)", "img": "assets/images/sepatu.png", "isChecked": false},
    {"name": "Carrier/Tas Gunung", "img": "assets/images/tas.png", "isChecked": false},
    {"name": "Jas hujan Poncho", "img": "assets/images/jas_hujan.png", "isChecked": false},
    {"name": "Headlamp/Senter", "img": "assets/images/senter.png", "isChecked": false},
    {"name": "Matras/Sleeping Bag", "img": "assets/images/sleeping_bag.png", "isChecked": false},
    {"name": "Kotak P3K", "img": "assets/images/p3k.png", "isChecked": false},
    {"name": "Pisau lipat", "img": "assets/images/pisau.png", "isChecked": false},
    {"name": "Trekking Pole", "img": "assets/images/tongkat.png", "isChecked": false},
    {"name": "Tenda", "img": "assets/images/tenda.png", "isChecked": false},
    {"name": "Kompor portable", "img": "assets/images/kompor.png", "isChecked": false},
    {"name": "Tabung gas", "img": "assets/images/gas.png", "isChecked": false},
    {"name": "Nesting/cooking set", "img": "assets/images/cooking.png", "isChecked": false},
    {"name": "Korek api", "img": "assets/images/korek.png", "isChecked": false},
    {"name": "Powerbank", "img": "assets/images/powerbank.png", "isChecked": false},
    {"name": "HT (Opsional)", "img": "assets/images/ht.png", "isChecked": false},
    {"name": "Air minum cukup", "img": "assets/images/air.png", "isChecked": false},
    {"name": "Makanan pokok", "img": "assets/images/makanan.png", "isChecked": false},
    {"name": "Cemilan (sesuai selera)", "img": "assets/images/cemilan.png", "isChecked": false},
    {"name": "Minuman saset seduh (sesuai selera)", "img": "assets/images/kopi.png", "isChecked": false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header Biru
          Container(
            padding: const EdgeInsets.only(top: 30, left: 16, right: 16, bottom: 5),
            decoration: const BoxDecoration(
              color: Color(0xFF0097B2),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
            ),
            
            child: Row(
              children: [
                Image.asset(
                  "assets/images/logo.png",
                  width: 45,
                  height: 45,
                  errorBuilder: (context, error, stackTrace) => 
                    const Icon(Icons.terrain, color: Colors.orange, size: 30),
                ),
                const Spacer(),
                const Text(
                  "Checklist Peralatan",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const Spacer(),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return _buildChecklistItem(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(int index) {
    final item = items[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black, width: 0.8),
        boxShadow: const [
          BoxShadow(color: Colors.black54, offset: Offset(4, 4)),
        ],
      ),
      child: Row(
        children: [
          // MENGGUNAKAN GAMBAR SEBAGAI IKON
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                item["img"],
                fit: BoxFit.contain,
                // Menampilkan icon error jika gambar tidak ditemukan
                errorBuilder: (context, error, stackTrace) => 
                  const Icon(Icons.image_not_supported, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 15),
          
          Expanded(
            child: Text(
              item["name"],
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 14,
                decoration: item["isChecked"] ? TextDecoration.lineThrough : null,
                color: item["isChecked"] ? Colors.grey : Colors.black,
              ),
            ),
          ),

          Transform.scale(
            scale: 1.2,
            child: Checkbox(
              value: item["isChecked"],
              activeColor: const Color(0xFF0097B2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              onChanged: (bool? value) {
                setState(() {
                  items[index]["isChecked"] = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}