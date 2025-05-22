class Note {
  final String id;
  final String title;
  final String content;
  final DateTime timestamp;
  final String? eventId;
  final bool displayOnHome;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.timestamp,
    this.eventId,
    this.displayOnHome = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'content': content,
    'timestamp': timestamp.toIso8601String(),
    'eventId': eventId,
    'displayOnHome': displayOnHome,
  };

  factory Note.fromMap(String id, Map<String, dynamic> data) => Note(
    id: id,
    title: data['title'],
    content: data['content'],
    timestamp: DateTime.parse(data['timestamp']),
    eventId: data['eventId'],
    displayOnHome: data['displayOnHome'] ?? false,
  );
}
