import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hikemate/widgets/app_header.dart';
import 'package:hikemate/services/toast_service.dart';
import 'tambah_kontak_darurat.dart';

class KontakDaruratScreen extends StatefulWidget {
  const KontakDaruratScreen({super.key});

  @override
  State<KontakDaruratScreen> createState() => _KontakDaruratScreenState();
}

class _KontakDaruratScreenState extends State<KontakDaruratScreen> {
  List<Map<String, dynamic>> contacts = [];
  bool isLoading = true;

  /// ⬅️ UUID = String
  String? selectedContactId;

  @override
  void initState() {
    super.initState();
    fetchContacts();
  }

  Future<void> fetchContacts() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final response = await Supabase.instance.client
        .from('emergency_contacts')
        .select()
        .eq('user_id', user.id)
        .order('created_at');

    setState(() {
      contacts = List<Map<String, dynamic>>.from(response);
      isLoading = false;
    });
  }

  /// ⬅️ id = String
  Future<void> deleteContact(String id) async {
    await Supabase.instance.client
        .from('emergency_contacts')
        .delete()
        .eq('id', id);

    ToastService.show(
      context,
      message: "Kontak darurat dihapus",
      type: ToastType.success,
    );

    fetchContacts();
  }

  /// ⬅️ id = String
  void confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hapus Kontak"),
        content: const Text("Yakin ingin menghapus kontak darurat ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              deleteContact(id);
            },
            child: const Text(
              "Hapus",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Column(
        children: [
          /// HEADER
          AppHeader(
            title: "Kontak Darurat",
            showBack: true,
            onBack: () => Navigator.pop(context),
          ),

          /// CONTENT
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : contacts.isEmpty
                    ? const Center(
                        child: Text(
                          "Belum ada kontak darurat",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: contacts.length,
                        itemBuilder: (context, index) {
                          final contact = contacts[index];
                          final isSelected = selectedContactId == contact['id'];

                          return Card(
                            elevation: isSelected ? 3 : 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isSelected
                                    ? const Color(0xFF0097B2)
                                    : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: ListTile(
                              leading: const Icon(Icons.person),
                              title: Text(contact['name']),
                              subtitle: Text(contact['phone']),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () =>
                                    confirmDelete(contact['id'] as String),
                              ),
                              onTap: () {
                                setState(() {
                                  selectedContactId = contact['id'] as String;
                                });

                                ToastService.show(
                                  context,
                                  message:
                                      "${contact['name']} dipilih sebagai kontak darurat",
                                  type: ToastType.success,
                                );
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),

      /// FAB TAMBAH KONTAK
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0097B2),
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const TambahKontakDaruratScreen(),
            ),
          );
          fetchContacts();
        },
      ),
    );
  }
}
