class Journal {
  final String id;
  final String mountainName;
  final String note;
  final List<String> imageUrls;
  final DateTime createdAt;
  final DateTime date;
  final String time;

  Journal({
    required this.id,
    required this.mountainName,
    required this.note,
    required this.imageUrls,
    required this.createdAt,
    required this.date,
    required this.time,
  });

  factory Journal.fromMap(Map<String, dynamic> map) {
    return Journal(
      id: map['id'],
      mountainName: map['mountain_name'],
      note: map['note'],
      imageUrls: List<String>.from(map['image_urls'] ?? []),
      createdAt: DateTime.parse(map['created_at']),
      date: DateTime.parse(map['date']),
      time: map['time'],
    );
  }
}
