import 'package:flutter/material.dart';
import 'edit_profil.dart';
import 'informasi_akun.dart';
import 'tentang.dart';
import 'login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String username = '';
  String? avatarUrl;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final data = await supabase
        .from('profiles')
        .select('username, avatar_url')
        .eq('id', user.id)
        .single();

    setState(() {
      username = data['username'] ?? 'User';
      avatarUrl = data['avatar_url'];
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header
          Container(
            padding:
                const EdgeInsets.only(top: 30, bottom: 5, left: 15, right: 15),
            decoration: const BoxDecoration(
              color: Color(0xFF0097B2),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Image.asset(
                  "assets/images/logo.png",
                  width: 45,
                  height: 45,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.terrain, color: Colors.orange),
                ),
                const Expanded(
                  child: Text(
                    "Pengaturan dan Profil",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // FOTO PROFIL & USERNAME
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black, width: 1.5),
                        ),
                        child: CircleAvatar(
                          radius: 30,
                          backgroundImage: avatarUrl != null
                              ? NetworkImage(avatarUrl!)
                              : null,
                          child: avatarUrl == null
                              ? const Icon(Icons.person,
                                  size: 30, color: Colors.grey)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Text(
                        username,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const EditProfilScreen()),
                          );
                          fetchProfile(); // 🔥 refresh setelah edit
                        },
                        icon: const Icon(Icons.edit,
                            size: 16, color: Colors.black),
                        label: const Text("Edit Profil",
                            style:
                                TextStyle(color: Colors.black, fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // Statistik (dummy dulu)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatCard("12", "Jumlah Gunung", Icons.terrain),
                      _buildStatCard("350km", "Jumlah Jarak", Icons.map),
                      _buildStatCard("1.408", "Langkah", Icons.directions_walk),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // MENU
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 0.8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        _buildMenuItem(Icons.person_outline, "Informasi Akun",
                            onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const InformasiAkunScreen()),
                          );
                        }),
                        const Divider(height: 1),
                        _buildMenuItem(
                            Icons.contact_phone_outlined, "Kontak Darurat"),
                        const Divider(height: 1),
                        _buildMenuItem(Icons.translate, "Bahasa Indonesia"),
                        const Divider(height: 1),
                        _buildMenuItem(Icons.info_outline, "Tentang",
                            onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const TentangScreen()),
                          );
                        }),
                        const Divider(height: 1),
                        _buildMenuItem(Icons.logout, "Keluar", onTap: () async {
                          await supabase.auth.signOut();
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LoginScreen()),
                            (_) => false,
                          );
                        }),
                      ],
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

  Widget _buildMenuItem(IconData icon, String title, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      onTap: onTap,
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Container(
      width: 100,
      height: 110,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10)),
        ],
      ),
    );
  }
}
