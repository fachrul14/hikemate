import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hikemate/widgets/app_header.dart';

class SosScreen extends StatefulWidget {
  const SosScreen({super.key});

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> {
  final supabase = Supabase.instance.client;

  bool isLoading = true;
  List emergencyContacts = [];
  Position? lastPosition;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _getLastLocation();
    await _loadEmergencyContacts();
    setState(() => isLoading = false);
  }

  // ================= NORMALISASI NOMOR HP =================
  String normalizePhone(String phone) {
    phone = phone.replaceAll(RegExp(r'[^0-9+]'), '');

    if (phone.startsWith('0')) {
      phone = phone.replaceFirst('0', '62');
    }

    if (!phone.startsWith('62')) {
      phone = '62$phone';
    }

    return phone;
  }

  // ================= AMBIL KONTAK DARURAT =================
  Future<void> _loadEmergencyContacts() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final data = await supabase
        .from('emergency_contacts')
        .select()
        .eq('user_id', user.id);

    if (data is List) {
      emergencyContacts = data;
    }
  }

  // ================= AMBIL LOKASI =================
  Future<void> _getLastLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) return;

    lastPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  // ================= KIRIM SOS =================
  Future<void> _sendSos({required String method}) async {
    if (lastPosition == null || emergencyContacts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Lokasi atau kontak darurat belum tersedia")),
      );
      return;
    }

    final lat = lastPosition!.latitude;
    final lon = lastPosition!.longitude;

    final message = "🚨 SOS DARURAT!\n"
        "Saya membutuhkan bantuan segera.\n"
        "Lokasi terakhir:\n"
        "https://maps.google.com/?q=$lat,$lon";

    if (method == "sms") {
      // Kirim SMS ke semua kontak sekaligus
      final phones =
          emergencyContacts.map((c) => normalizePhone(c['phone'])).join(',');
      final uri = Uri.parse("sms:$phones?body=${Uri.encodeComponent(message)}");

      try {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Gagal membuka SMS")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error SMS: $e")),
        );
      }
    } else {
      // WhatsApp tetap looping satu per satu
      for (final contact in emergencyContacts) {
        final rawPhone = contact['phone'];
        final phone = normalizePhone(rawPhone);

        final uri = Uri.parse(
          "whatsapp://send?phone=$phone&text=${Uri.encodeComponent(message)}",
        );

        try {
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      "WhatsApp tidak ditemukan untuk ${contact['name']}")),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("Gagal WhatsApp untuk ${contact['name']}: $e")),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ===== Konten utama =====
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 80), // beri jarak agar tidak ketutup header
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                child: Column(
                  children: [
                    _sosButton(),
                    const SizedBox(height: 25),
                    _infoCard(),
                  ],
                ),
              ),
            ),
          ),

          // ===== Header =====
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _header(),
          ),
        ],
      ),
    );
  }

  // ================= UI =================

  Widget _header() {
    return AppHeader(
      title: "Mode SOS",
      showBack: true, // tampilkan panah back di kiri
      onBack: () => Navigator.pop(context),
    );
  }

  Widget _sosButton() {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (_) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.chat),
                  title: const Text("Kirim via WhatsApp"),
                  onTap: () {
                    Navigator.pop(context);
                    _sendSos(method: "whatsapp");
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.sms),
                  title: const Text("Kirim via SMS"),
                  onTap: () {
                    Navigator.pop(context);
                    _sendSos(method: "sms");
                  },
                ),
              ],
            );
          },
        );
      },
      child: Container(
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
              color: const Color(0xFFFF2D2D),
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
    );
  }

  Widget _infoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Kontak Yang Bisa Dihubungi",
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          if (emergencyContacts.isEmpty) const Text("Belum ada kontak darurat"),
          for (final c in emergencyContacts)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  const Icon(Icons.phone_in_talk),
                  const SizedBox(width: 10),
                  Text("${c['name']} (${c['phone']})"),
                ],
              ),
            ),
          if (lastPosition != null) ...[
            const SizedBox(height: 15),
            Text(
                "Lokasi terakhir: ${lastPosition!.latitude}, ${lastPosition!.longitude}"),
          ],
        ],
      ),
    );
  }
}
