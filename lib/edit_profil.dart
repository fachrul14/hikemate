import 'package:flutter/material.dart';

class EditProfilScreen extends StatefulWidget {
  const EditProfilScreen({super.key});

  @override
  State<EditProfilScreen> createState() => _EditProfilScreenState();
}

class _EditProfilScreenState extends State<EditProfilScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 1. Header Biru Cyan (Sama dengan Journal & Tambah Catatan)
          Container(
            padding:
                const EdgeInsets.only(top: 30, bottom: 5, left: 10, right: 15),
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
                    "Edit Profil",
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
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Bagian Foto Profil
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 1.5),
                          ),
                          child: const CircleAvatar(
                            radius: 50,
                            backgroundColor: Color(0xFFE0E0E0),
                            child: Icon(Icons.camera_alt_outlined,
                                size: 50, color: Colors.black54),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Tombol Tambahkan Foto
                        Container(
                          decoration: BoxDecoration(
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black, offset: Offset(0, 3)),
                            ],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              elevation: 0,
                              side: const BorderSide(
                                  color: Colors.black, width: 1.5),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 0),
                            ),
                            child: const Text("+ Tambahkan Foto",
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 3. Bagian Informasi Dasar
                  const Text("Informasi Dasar",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 15),
                  _buildTextField("Username"),
                  const SizedBox(height: 15),
                  _buildTextField("Nomor Telepon"),
                  const SizedBox(height: 15),
                  _buildTextField("Email"),
                  const SizedBox(height: 15),
                  _buildTextField("Jenis Kelamin"),
                  const SizedBox(height: 15),
                  _buildTextField("Tanggal Lahir"),

                  const SizedBox(height: 30),

                  // 4. Bagian Kontak Darurat
                  const Text("Kontak Darurat",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 15),
                  _buildTextField("Nama Kontak"),
                  const SizedBox(height: 15),
                  _buildEmergencyField(),
                  const SizedBox(height: 15),
                  _buildTextField("Nama Kontak"),
                  const SizedBox(height: 15),
                  _buildEmergencyField(),

                  const SizedBox(height: 40),

                  // 5. Tombol Simpan Perubahan
                  Center(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        boxShadow: const [
                          BoxShadow(color: Colors.black, offset: Offset(0, 4)),
                        ],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0097B2),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          side:
                              const BorderSide(color: Colors.black, width: 1.5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        child: const Text(
                          "SIMPAN PERUBAHAN",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget Input Biasa
  Widget _buildTextField(String hint) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: Colors.black, offset: Offset(0, 4)),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.black, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF0097B2), width: 2),
          ),
        ),
      ),
    );
  }

  // Widget Input Khusus Kontak (dengan icon buku kontak di kiri)
  Widget _buildEmergencyField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: Colors.black, offset: Offset(0, 4)),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          prefixIcon:
              const Icon(Icons.contact_phone_outlined, color: Colors.black),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.black, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF0097B2), width: 2),
          ),
        ),
      ),
    );
  }
}
