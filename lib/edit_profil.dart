import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hikemate/widgets/app_header.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:hikemate/services/toast_service.dart';

class EditProfilScreen extends StatefulWidget {
  const EditProfilScreen({super.key});

  @override
  State<EditProfilScreen> createState() => _EditProfilScreenState();
}

class _EditProfilScreenState extends State<EditProfilScreen> {
  final supabase = Supabase.instance.client;

  // ================= CONTROLLERS =================
  final usernameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();

  final emergencyName1 = TextEditingController();
  final emergencyPhone1 = TextEditingController();
  final emergencyName2 = TextEditingController();
  final emergencyPhone2 = TextEditingController();

  String? selectedGender;
  DateTime? selectedBirthDate;

  File? selectedImage;
  String? avatarUrl;

  bool isLoading = true;
  bool isSaving = false;

  // ================= INIT =================
  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  @override
  void dispose() {
    usernameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    emergencyName1.dispose();
    emergencyPhone1.dispose();
    emergencyName2.dispose();
    emergencyPhone2.dispose();
    super.dispose();
  }

  Future<void> pickContact(
      TextEditingController nameCtrl, TextEditingController phoneCtrl) async {
    // Request permission
    final permission = await Permission.contacts.request();
    if (!permission.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Izin akses kontak ditolak")),
      );
      return;
    }

    // Pick contact
    final contact = await FlutterContacts.openExternalPick();
    if (contact == null) return;

    if (contact.phones.isEmpty) return;

    String phone = contact.phones.first.number;

    // Bersihkan karakter selain angka
    phone = phone.replaceAll(RegExp(r'[^0-9]'), '');

    // Konversi 08xxxx → 628xxxx
    if (phone.startsWith('08')) {
      phone = phone.replaceFirst('08', '628');
    }

    setState(() {
      nameCtrl.text = contact.displayName;
      phoneCtrl.text = phone;
    });
  }

  // ================= FETCH PROFILE =================
  Future<void> fetchProfile() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final profile =
          await supabase.from('profiles').select().eq('id', user.id).single();

      final contacts = await supabase
          .from('emergency_contacts')
          .select('name, phone')
          .eq('user_id', user.id)
          .order('created_at', ascending: true)
          .limit(2);

      setState(() {
        usernameController.text = profile['username'] ?? '';
        phoneController.text = profile['phone'] ?? '';
        emailController.text = user.email ?? '';

        selectedGender = profile['gender'];
        avatarUrl = profile['avatar_url'];

        if (profile['birth_date'] != null) {
          selectedBirthDate = DateTime.parse(profile['birth_date']);
        }

        if (contacts.isNotEmpty) {
          emergencyName1.text = contacts[0]['name'];
          emergencyPhone1.text = contacts[0]['phone'];
        }

        if (contacts.length > 1) {
          emergencyName2.text = contacts[1]['name'];
          emergencyPhone2.text = contacts[1]['phone'];
        }
      });
    } catch (e, stackTrace) {
      debugPrint("fetchProfile error: $e");
      debugPrintStack(stackTrace: stackTrace);

      if (mounted) {
        ToastService.show(
          context,
          message: "Gagal memuat profil",
          type: ToastType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  // ================= IMAGE =================
  Future<void> pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => selectedImage = File(image.path));
    }
  }

  Future<XFile?> compressImage(File file) async {
    final targetPath = file.path.replaceFirst(
      RegExp(r'\.(jpg|jpeg|png)$'),
      '_c.jpg',
    );

    return await FlutterImageCompress.compressAndGetFile(
      file.path,
      targetPath,
      quality: 60,
    );
  }

  Future<String?> uploadToCloudinary(File image) async {
    const cloudName = 'dm3ccqxl7';
    const uploadPreset = 'avatars';

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload'),
    )
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', image.path));

    final res = await request.send();
    if (res.statusCode == 200) {
      final body = await res.stream.bytesToString();
      return json.decode(body)['secure_url'];
    }
    return null;
  }

  // ================= SAVE =================
  Future<void> saveProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    setState(() => isSaving = true);

    try {
      String? imageUrl = avatarUrl;

      if (selectedImage != null) {
        final compressed = await compressImage(selectedImage!);
        if (compressed != null) {
          imageUrl = await uploadToCloudinary(File(compressed.path));
        }
      }

      await supabase.from('profiles').update({
        'username': usernameController.text,
        'phone': phoneController.text,
        'gender': selectedGender,
        'birth_date': selectedBirthDate?.toIso8601String().split('T').first,
        'avatar_url': imageUrl,
      }).eq('id', user.id);

      await supabase.from('emergency_contacts').upsert([
        {
          'user_id': user.id,
          'name': emergencyName1.text,
          'phone': emergencyPhone1.text,
        },
        {
          'user_id': user.id,
          'name': emergencyName2.text,
          'phone': emergencyPhone2.text,
        }
      ]);

      if (emergencyName1.text.isNotEmpty) {
        await supabase.from('emergency_contacts').insert({
          'user_id': user.id,
          'name': emergencyName1.text,
          'phone': emergencyPhone1.text,
        });
      }

      if (emergencyName2.text.isNotEmpty) {
        await supabase.from('emergency_contacts').insert({
          'user_id': user.id,
          'name': emergencyName2.text,
          'phone': emergencyPhone2.text,
        });
      }

      if (!mounted) return;

      ToastService.show(
        context,
        message: "Profil berhasil diperbarui",
        type: ToastType.success,
      );

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.pop(context);
      });
    } catch (e, stackTrace) {
      debugPrint("saveProfile error: $e");
      debugPrintStack(stackTrace: stackTrace);

      if (mounted) {
        ToastService.show(
          context,
          message: "Gagal menyimpan profil",
          type: ToastType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      body: Column(
        children: [
          _header(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _avatar(),
                  const SizedBox(height: 25),
                  _sectionCard(
                    title: "Informasi Pendaki",
                    icon: Icons.person,
                    children: [
                      _field("Username", usernameController, Icons.person),
                      _field("Nomor Telepon", phoneController, Icons.phone),
                      _genderField(),
                      _dateField(),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _sectionCard(
                    title: "Kontak Darurat",
                    icon: Icons.warning_amber_rounded,
                    children: [
                      _field("Nama Kontak 1", emergencyName1,
                          Icons.person_outline),
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
                      _emergencyFieldWithButton(
                        emergencyPhone1,
                        () => pickContact(emergencyName1, emergencyPhone1),
                      ),
                      _field("Nama Kontak 2", emergencyName2,
                          Icons.person_outline),
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
                      _emergencyFieldWithButton(
                        emergencyPhone2,
                        () => pickContact(emergencyName2, emergencyPhone2),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  _saveButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= WIDGETS =================

  Widget _emergencyFieldWithButton(
      TextEditingController c, VoidCallback onPick) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: c,
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.contact_phone),
          hintText: "Nomor Kontak",
          suffixIcon: IconButton(
            icon: const Icon(Icons.contacts),
            onPressed: onPick,
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return AppHeader(
      title: "Edit Profil",
      showBack: true,
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color.fromARGB(255, 0, 0, 0)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _avatar() => Center(
        child: Stack(
          children: [
            CircleAvatar(
              radius: 55,
              backgroundColor: Colors.green.shade200,
              backgroundImage: selectedImage != null
                  ? FileImage(selectedImage!)
                  : avatarUrl != null
                      ? NetworkImage(avatarUrl!) as ImageProvider
                      : null,
              child: selectedImage == null && avatarUrl == null
                  ? const Icon(Icons.person, size: 60, color: Colors.white)
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: InkWell(
                onTap: pickImage,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 165, 164, 164),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit, size: 18, color: Colors.white),
                ),
              ),
            )
          ],
        ),
      );

  Widget _field(String hint, TextEditingController c, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _emergencyField(TextEditingController c) => Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: TextField(
          controller: c,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.contact_phone),
            hintText: "Nomor Kontak",
          ),
        ),
      );

  Widget _genderField() => DropdownButtonFormField<String>(
        value: selectedGender,
        items: const [
          DropdownMenuItem(value: 'laki-laki', child: Text('Laki-laki')),
          DropdownMenuItem(value: 'perempuan', child: Text('Perempuan')),
        ],
        onChanged: (v) => setState(() => selectedGender = v),
        decoration: const InputDecoration(hintText: "Jenis Kelamin"),
      );

  Widget _dateField() => GestureDetector(
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: selectedBirthDate ?? DateTime(2000),
            firstDate: DateTime(1950),
            lastDate: DateTime.now(),
          );
          if (date != null) setState(() => selectedBirthDate = date);
        },
        child: AbsorbPointer(
          child: TextField(
            decoration: InputDecoration(
              hintText: selectedBirthDate == null
                  ? "Tanggal Lahir"
                  : selectedBirthDate!.toIso8601String().split('T').first,
            ),
          ),
        ),
      );

  Widget _saveButton() => SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: isSaving ? null : saveProfile,
          icon: const Icon(Icons.save, color: Colors.white),
          label: isSaving
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text("SIMPAN PERUBAHAN",
                  style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF0097B2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      );
}
