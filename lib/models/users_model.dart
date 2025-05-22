class UserModel {
  final String uid;
  final String? email;
  final String? teamName;
  final String? sport;
  final String? bio;
  final List<String>? events;
  final List<String>? friends;
  final List<String>? members;

  UserModel({
    required this.uid,
    this.email,
    this.teamName,
    this.sport,
    this.bio,
    this.events,
    this.friends,
    this.members,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'teamName': teamName,
      'sport' : sport,
      'bio': bio,
      'events': events,
      'friends': friends,
      'members' : members,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      teamName: map['teamName'] ?? '',
      sport: map['sport'] ?? '',
      bio: map['bio'],
      events: List<String>.from(map['events'] ?? []),
      friends: List<String>.from(map['friends'] ?? []),
      members: List<String>.from(map['members'] ?? []),
    );
  }
}
