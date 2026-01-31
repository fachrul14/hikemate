import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:hikemate/widgets/app_header.dart';

class InformasiAkunScreen extends StatefulWidget {
  const InformasiAkunScreen({super.key});

  @override
  State<InformasiAkunScreen> createState() => _InformasiAkunScreenState();
}

class _InformasiAkunScreenState extends State<InformasiAkunScreen> {
  final supabase = Supabase.instance.client;

  bool isLoading = true;

  String username = '-';
  String phone = '-';
  String email = '-';
  String gender = '-';
  String birthDate = '-';
  String emergencyContacts = '-';

  @override
  void initState() {
    super.initState();
    fetchAccountInfo();
  }

  // ================= FETCH DATA =================
  Future<void> fetchAccountInfo() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final profile =
          await supabase.from('profiles').select().eq('id', user.id).single();

      final contacts = await supabase
          .from('emergency_contacts')
          .select('name, phone')
          .eq('user_id', user.id)
          .order('created_at', ascending: true)
          .limit(2);

      setState(() {
        username = profile['username'] ?? '-';
        phone = profile['phone'] ?? '-';
        email = user.email ?? '-';

        gender =
            profile['gender'] != null ? _formatGender(profile['gender']) : '-';

        if (profile['birth_date'] != null) {
          birthDate = DateFormat('dd-MM-yyyy')
              .format(DateTime.parse(profile['birth_date']));
        }

        if (contacts.isNotEmpty) {
          emergencyContacts =
              contacts.map((c) => "${c['name']} (${c['phone']})").join('\n');
        }

        isLoading = false;
      });
    } catch (e) {
      isLoading = false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal memuat data akun")),
      );
    }
  }

  // ================= FORMAT =================
  String _formatGender(String g) {
    if (g.toLowerCase() == 'laki-laki') return 'Laki-Laki';
    if (g.toLowerCase() == 'perempuan') return 'Perempuan';
    return g;
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _header(context),
          const SizedBox(height: 30),
          if (isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: const Color(0xFF0097B2), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoItem("Nama Pengguna", username),
                    const SizedBox(height: 15),
                    _buildInfoItem(
                      "Info Kontak",
                      "$phone\n$email",
                    ),
                    const SizedBox(height: 15),
                    _buildInfoItem("Jenis Kelamin", gender),
                    const SizedBox(height: 15),
                    _buildInfoItem("Tanggal Lahir", birthDate),
                    const SizedBox(height: 15),
                    _buildInfoItem("Kontak Darurat", emergencyContacts),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ================= HEADER =================
  Widget _header(BuildContext context) {
    return AppHeader(
      title: "Informasi Akun",
      showBack: true, // tampilkan panah back di kiri
      onBack: () => Navigator.pop(context),
    );
  }

  // ================= ITEM =================
  Widget _buildInfoItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.isEmpty ? '-' : value,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.grey,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}
