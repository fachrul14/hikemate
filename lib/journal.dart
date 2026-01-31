import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'tambah_catatan.dart';
import 'models/journal.dart';
import 'detail_journal_screen.dart';
import 'package:hikemate/widgets/app_header.dart';
import 'package:hikemate/services/toast_service.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final supabase = Supabase.instance.client;

  List<Journal> journals = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchJournals();
  }

  // ================= FETCH JOURNALS =================
  Future<void> fetchJournals() async {
    setState(() => isLoading = true);

    final user = supabase.auth.currentUser;
    if (user == null) return;

    final data = await supabase
        .from('journals')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    setState(() {
      journals = (data as List).map((e) => Journal.fromMap(e)).toList();
      isLoading = false;
    });
  }

  // ================= DELETE JOURNAL =================
  Future<void> deleteJournal(String journalId) async {
    await supabase.from('journals').delete().eq('id', journalId);

    ToastService.show(
      context,
      message: "Jurnal berhasil dihapus",
      type: ToastType.success,
    );

    fetchJournals();
  }

  // ================= ALERT KONFIRMASI HAPUS =================
  Future<void> showDeleteConfirmation(Journal journal) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Hapus Jurnal"),
          content: const Text("Apakah kamu yakin ingin menghapus jurnal ini?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Hapus"),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await deleteJournal(journal.id);
    } else {
      ToastService.show(
        context,
        message: "Penghapusan dibatalkan",
        type: ToastType.warning,
      );
    }
  }

  // ================= BOTTOM SHEET ACTION =================
  void showJournalAction(Journal journal) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text("Edit Jurnal"),
                onTap: () async {
                  Navigator.pop(context);
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TambahCatatanScreen(journal: journal),
                    ),
                  );
                  fetchJournals();
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text("Hapus Jurnal"),
                onTap: () async {
                  Navigator.pop(context);
                  await showDeleteConfirmation(journal);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: fetchJournals,
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : journals.isEmpty
                      ? const Center(child: Text("Belum ada catatan"))
                      : ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: journals.length,
                          itemBuilder: (context, index) {
                            final journal = journals[index];

                            return Column(
                              children: [
                                _buildJournalCard(journal),
                                const SizedBox(height: 20),
                              ],
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding:
            const EdgeInsets.only(bottom: 70), // sesuaikan tinggi bottom nav
        child: FloatingActionButton(
          backgroundColor: const Color(0xFF0097B2),
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const TambahCatatanScreen(),
              ),
            );
            fetchJournals();
          },
          child: const Icon(Icons.add, color: Colors.black),
        ),
      ),
    );
  }

  // ================= HEADER =================
  Widget _buildHeader() {
    return const AppHeader(
      title: "Jurnal Perjalanan",
      showBack: false, // kalau mau ada panah back tinggal ubah jadi true
    );
  }

  // ================= JOURNAL CARD =================
  Widget _buildJournalCard(Journal journal) {
    final imageUrl =
        journal.imageUrls.isNotEmpty ? journal.imageUrls.first : null;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailJournalScreen(journal: journal),
          ),
        );
      },
      onLongPress: () {
        showJournalAction(journal);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.black),
          boxShadow: const [
            BoxShadow(color: Colors.black45, offset: Offset(4, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(15)),
              child: imageUrl != null
                  ? Image.network(
                      imageUrl,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 180,
                      color: Colors.grey[200],
                      child: const Center(child: Text("Tidak ada gambar")),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              color: Colors.red, size: 18),
                          const SizedBox(width: 5),
                          Text(
                            journal.mountainName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        _formatDate(journal.createdAt),
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    journal.note,
                    style: const TextStyle(fontSize: 12, height: 1.4),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= FORMAT DATE =================
  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}
