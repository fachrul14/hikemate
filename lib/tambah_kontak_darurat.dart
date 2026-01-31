import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hikemate/widgets/app_header.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:hikemate/services/toast_service.dart';

class TambahKontakDaruratScreen extends StatefulWidget {
  const TambahKontakDaruratScreen({super.key});

  @override
  State<TambahKontakDaruratScreen> createState() =>
      _TambahKontakDaruratScreenState();
}

class _TambahKontakDaruratScreenState extends State<TambahKontakDaruratScreen> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _teleponController = TextEditingController();
  bool isSaving = false;

  Future<void> pickContact() async {
    final permission = await Permission.contacts.request();
    if (!permission.isGranted) {
      ToastService.show(
        context,
        message: "Izin akses kontak ditolak",
        type: ToastType.error,
      );
      return;
    }

    final contact = await FlutterContacts.openExternalPick();
    if (contact == null || contact.phones.isEmpty) return;

    String phone = contact.phones.first.number;

    // Bersihkan karakter non-angka
    phone = phone.replaceAll(RegExp(r'[^0-9]'), '');

    // Konversi 08xxxx → 628xxxx
    if (phone.startsWith('08')) {
      phone = phone.replaceFirst('08', '628');
    }

    setState(() {
      _namaController.text = contact.displayName;
      _teleponController.text = phone;
    });
  }

  Future<void> simpanKontak() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final nama = _namaController.text.trim();
    final telepon = _teleponController.text.trim();

    if (nama.isEmpty || telepon.isEmpty) {
      ToastService.show(
        context,
        message: "Nama dan nomor telepon wajib diisi",
        type: ToastType.warning,
      );
      return;
    }

    setState(() => isSaving = true);

    await Supabase.instance.client.from('emergency_contacts').insert({
      'user_id': user.id,
      'name': nama,
      'phone': telepon,
    });

    setState(() => isSaving = false);

    ToastService.show(
      context,
      message: "Kontak darurat berhasil ditambahkan",
      type: ToastType.success,
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header pakai AppHeader
          AppHeader(
            title: "Tambah Kontak Darurat",
            showBack: true,
            onBack: () => Navigator.pop(context),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  TextField(
                    controller: _namaController,
                    decoration: const InputDecoration(
                      labelText: "Nama Kontak",
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _teleponController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: "Nomor Telepon",
                      prefixIcon: const Icon(Icons.phone),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.contacts),
                        onPressed: pickContact,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Ambil langsung dari kontak perangkat",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSaving ? null : simpanKontak,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0097B2),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "SIMPAN PERUBAHAN",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
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
}
