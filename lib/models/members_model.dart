class Member {
  String id;
  String name;
  String position;
  String contact;
  DateTime timestampJoined;
  String emergencyContact;
  String emergencyContactRelation;
  String playerStatus;
  String? avatarURL;

  //Member Statistics
  int scores;
  int assists;
  int totalGames;
  int lifetimeInjuries;

  Member({
    required this.id,
    required this.name,
    required this.position,
    required this.contact,
    required this.emergencyContact,
    required this.emergencyContactRelation,
    required this.playerStatus,
    this.avatarURL,
    this.scores = 0,
    this.assists = 0,
    this.totalGames = 0,
    this.lifetimeInjuries = 0,
    DateTime? timestampJoined,
  }) : timestampJoined = timestampJoined ?? DateTime.now();

  factory Member.fromMap(Map<String, dynamic> map) {
    return Member(
      id: map['id'],
      name: map['name'],
      position: map['position'],
      contact: map['contact'],
      emergencyContact: map['emergencyContact'],
      emergencyContactRelation: map['emergencyContactRelation'],
      playerStatus: map['playerStatus'],
      avatarURL: map['avatarURL'] ?? '',
      scores: map['scores'] ?? 0,
      assists: map['assists'] ?? 0,
      totalGames: map['totalGames'] ?? 0,
      lifetimeInjuries: map['lifetimeInjuries'] ?? 0,
      timestampJoined: map['timestampJoined'] != null
          ? DateTime.parse(map['timestampJoined'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'position': position,
      'contact': contact,
      'timestampJoined': timestampJoined.toIso8601String(),
      'emergencyContact': emergencyContact,
      'emergencyContactRelation': emergencyContactRelation,
      'playerStatus': playerStatus,
      'avatarURL': avatarURL,
      'scores': scores,
      'assists': assists,
      'totalGames': totalGames,
      'lifetimeInjuries': lifetimeInjuries,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Member && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
