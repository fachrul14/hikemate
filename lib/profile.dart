import 'package:flutter/material.dart';
import 'edit_profil.dart';
import 'informasi_akun.dart';
import 'tentang.dart';
import 'login.dart';
import 'kontak_darurat.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hikemate/widgets/app_header.dart';

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
  int totalGunung = 0;
  double totalJarak = 0;
  int totalLangkah = 0;

  @override
  void initState() {
    super.initState();
    fetchProfile();
    fetchTrackingStats();
  }

  Future<void> showLogoutDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text("Konfirmasi Keluar"),
          content: const Text(
            "Apakah kamu yakin ingin keluar dari akun?",
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text(
                "Batal",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Keluar"),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await supabase.auth.signOut();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    }
  }

  Future<void> onRefresh() async {
    await Future.wait([
      fetchProfile(),
      fetchTrackingStats(),
    ]);
  }

  Future<void> fetchTrackingStats() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final response = await supabase
        .from('tracking_sessions')
        .select('total_distance, steps')
        .eq('user_id', user.id);

    int gunung = response.length;
    double jarak = 0;
    int langkah = 0;

    for (final item in response) {
      jarak += (item['total_distance'] ?? 0).toDouble();
      langkah += (item['steps'] ?? 0) as int;
    }

    setState(() {
      totalGunung = gunung;
      totalJarak = jarak;
      totalLangkah = langkah;
    });
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
          const AppHeader(
            title: "Pengaturan dan Profil",
            showBack: false, // kalau mau ada panah back tinggal ubah jadi true
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: onRefresh,
              color: Colors.blue,
              backgroundColor: const Color.fromARGB(255, 255, 255, 255),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    // FOTO PROFIL & USERNAME
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (avatarUrl != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      FullScreenImage(url: avatarUrl!),
                                ),
                              );
                            }
                          },
                          child: Hero(
                            tag: 'profile-photo',
                            child: CircleAvatar(
                              radius: 40,
                              backgroundImage: avatarUrl != null
                                  ? NetworkImage(avatarUrl!)
                                  : null,
                              child: avatarUrl == null
                                  ? const Icon(Icons.person,
                                      size: 30, color: Colors.grey)
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        // USERNAME + BUTTON
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              username,
                              style: const TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            ElevatedButton.icon(
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const EditProfilScreen(),
                                  ),
                                );
                                fetchProfile();
                              },
                              icon: const Icon(Icons.edit,
                                  size: 16, color: Colors.black),
                              label: const Text(
                                "Edit Profil",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 12),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[300],
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatCard(
                          totalGunung.toString(),
                          "Jumlah Gunung",
                          Icons.terrain,
                        ),
                        _buildStatCard(
                          "${totalJarak.toStringAsFixed(1)} km",
                          "Jumlah Jarak",
                          Icons.map,
                        ),
                        _buildStatCard(
                          totalLangkah.toString(),
                          "Langkah",
                          Icons.directions_walk,
                        ),
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
                              Icons.contact_phone_outlined, "Kontak Darurat",
                              onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const KontakDaruratScreen()),
                            );
                          }),
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
                          _buildMenuItem(
                            Icons.logout,
                            "Keluar",
                            onTap: showLogoutDialog,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          )
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

class FullScreenImage extends StatelessWidget {
  final String url;
  const FullScreenImage({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Navigator.pop(context), // Klik layar untuk menutup
        child: Center(
          child: Hero(
            tag: 'profile-photo',
            child: InteractiveViewer(
              child: Image.network(url),
            ),
          ),
        ),
      ),
    );
  }
}
