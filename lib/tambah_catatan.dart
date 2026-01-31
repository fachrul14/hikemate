import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/journal.dart';
import 'package:hikemate/widgets/app_header.dart';
import 'package:hikemate/services/toast_service.dart';

const cloudName = "dm3ccqxl7";
const uploadPreset = "journals";

class TambahCatatanScreen extends StatefulWidget {
  final Journal? journal;

  const TambahCatatanScreen({super.key, this.journal});

  @override
  State<TambahCatatanScreen> createState() => _TambahCatatanScreenState();
}

class _TambahCatatanScreenState extends State<TambahCatatanScreen> {
  final supabase = Supabase.instance.client;
  final ImagePicker _picker = ImagePicker();

  final namaGunungC = TextEditingController();
  final tanggalC = TextEditingController();
  final waktuC = TextEditingController();
  final catatanC = TextEditingController();

  List<XFile> selectedImages = [];
  List<String> existingImages = [];

  bool isLoading = false;
  bool get isEdit => widget.journal != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      final j = widget.journal!;
      namaGunungC.text = j.mountainName;
      catatanC.text = j.note;
      tanggalC.text =
          "${j.date.day.toString().padLeft(2, '0')}/${j.date.month.toString().padLeft(2, '0')}/${j.date.year}";
      waktuC.text = j.time.substring(0, 5);
      existingImages = List.from(j.imageUrls);
    }
  }

  DateTime _parseTanggal() {
    try {
      final parts = tanggalC.text.split('/');
      return DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
      );
    } catch (_) {
      return DateTime.now();
    }
  }

  Future<void> pilihTanggal() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      tanggalC.text =
          "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
    }
  }

  Future<void> pilihWaktu() async {
    final picked =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) {
      waktuC.text =
          "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
    }
  }

  Future<void> pickImages() async {
    final images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        selectedImages.addAll(images);
        if (selectedImages.length > 6) {
          selectedImages = selectedImages.take(6).toList();
        }
      });
    }
  }

  // ======================= FUNGSI KOMPRESI =======================
  Future<Uint8List> compressImage(File file,
      {int quality = 70, int maxWidth = 1024}) async {
    final bytes = await file.readAsBytes();
    img.Image? image = img.decodeImage(bytes);
    if (image == null) return bytes;

    if (image.width > maxWidth) {
      image = img.copyResize(image, width: maxWidth);
    }

    final compressed = img.encodeJpg(image, quality: quality);
    return Uint8List.fromList(compressed);
  }

  // ======================= UPLOAD =======================
  Future<String?> uploadToCloudinary(XFile image) async {
    final file = File(image.path);

    // Kompres sebelum upload
    final compressedBytes =
        await compressImage(file, quality: 70, maxWidth: 1024);

    final request = http.MultipartRequest(
      'POST',
      Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload"),
    )
      ..fields['upload_preset'] = uploadPreset
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          compressedBytes,
          filename: image.name,
        ),
      );

    final response = await request.send();
    if (response.statusCode == 200) {
      final resStr = await response.stream.bytesToString();
      final data = jsonDecode(resStr);
      return data['secure_url'];
    }
    return null;
  }

  Future<List<String>> uploadMultipleImages() async {
    List<String> urls = [];

    for (final img in selectedImages) {
      final url = await uploadToCloudinary(img);
      if (url != null) urls.add(url);
    }

    return urls;
  }

  Future<void> simpanCatatan() async {
    if (namaGunungC.text.isEmpty ||
        catatanC.text.isEmpty ||
        tanggalC.text.isEmpty ||
        waktuC.text.isEmpty ||
        (!isEdit && selectedImages.isEmpty)) {
      ToastService.show(
        context,
        message: "Lengkapi semua data",
        type: ToastType.warning,
      );

      return;
    }

    final user = supabase.auth.currentUser;
    if (user == null) return;

    setState(() => isLoading = true);

    try {
      final newImages =
          selectedImages.isEmpty ? <String>[] : await uploadMultipleImages();

      final allImages = [...existingImages, ...newImages];

      if (isEdit) {
        await supabase.from('journals').update({
          'mountain_name': namaGunungC.text,
          'note': catatanC.text,
          'date': _parseTanggal().toIso8601String(),
          'time': "${waktuC.text}:00",
          'image_urls': allImages,
        }).eq('id', widget.journal!.id);
      } else {
        await supabase.from('journals').insert({
          'user_id': user.id,
          'mountain_name': namaGunungC.text,
          'note': catatanC.text,
          'date': _parseTanggal().toIso8601String(),
          'time': "${waktuC.text}:00",
          'image_urls': allImages,
        });
      }

      ToastService.show(
        context,
        message: isEdit
            ? "Catatan berhasil diperbarui"
            : "Catatan berhasil disimpan",
        type: ToastType.success,
      );

      if (!mounted) return;
      Navigator.pop(context);
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel("Nama Gunung"),
                  _buildTextField(namaGunungC, "Nama Gunung"),
                  const SizedBox(height: 15),
                  _buildLabel("Tanggal"),
                  _buildTextField(tanggalC, "DD/MM/YYYY",
                      readOnly: true, onTap: pilihTanggal),
                  const SizedBox(height: 15),
                  _buildLabel("Waktu"),
                  SizedBox(
                    width: 120,
                    child: _buildTextField(waktuC, "00:00",
                        readOnly: true, onTap: pilihWaktu),
                  ),
                  const SizedBox(height: 15),
                  _buildLabel("Catatan"),
                  _buildTextField(catatanC, "", maxLines: 5),
                  const SizedBox(height: 20),
                  _buildImagePicker(),
                  const SizedBox(height: 10),
                  _buildImagePreview(),
                  const SizedBox(height: 40),
                  Center(
                    child: ElevatedButton(
                      onPressed: isLoading ? null : simpanCatatan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0097B2),
                        foregroundColor: Colors.black,
                        side: const BorderSide(color: Colors.black, width: 1.5),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator()
                          : Text(
                              isEdit ? "UPDATE CATATAN" : "SIMPAN CATATAN",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
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

  // ================= IMAGE PREVIEW =================
  Widget _buildImagePreview() {
    if (existingImages.isEmpty && selectedImages.isEmpty) {
      return const Text("Belum ada foto dipilih");
    }

    return SizedBox(
      height: 110,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          ...existingImages.asMap().entries.map((entry) {
            final index = entry.key;
            final url = entry.value;
            return _buildImageItem(
              image: Image.network(
                url,
                fit: BoxFit.cover,
                cacheWidth: 300,
              ),
              onRemove: () => setState(() => existingImages.removeAt(index)),
            );
          }),
          ...selectedImages.asMap().entries.map((entry) {
            final index = entry.key;
            final file = entry.value;
            return _buildImageItem(
              image: Image.file(File(file.path), fit: BoxFit.cover),
              onRemove: () => setState(() => selectedImages.removeAt(index)),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildImageItem({
    required Widget image,
    required VoidCallback onRemove,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      width: 100,
      height: 100,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(width: 100, height: 100, child: image),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(4),
                child: const Icon(Icons.close, size: 14, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return AppHeader(
      title: isEdit ? "Edit Catatan" : "Tambah Catatan Baru",
      showBack: !isLoading,
      onBack: isLoading ? null : () => Navigator.pop(context),
    );
  }

  Widget _buildImagePicker() {
    return Row(
      children: [
        GestureDetector(
          onTap: pickImages,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF0097B2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 1.5),
            ),
            child: const Icon(Icons.camera_alt, color: Colors.black),
          ),
        ),
        const SizedBox(width: 15),
        const Text("Pilih Foto (bisa lebih dari satu)"),
      ],
    );
  }

  Widget _buildLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      );

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black, width: 1.5),
        ),
      ),
    );
  }

  @override
  void dispose() {
    namaGunungC.dispose();
    tanggalC.dispose();
    waktuC.dispose();
    catatanC.dispose();
    super.dispose();
  }
}
