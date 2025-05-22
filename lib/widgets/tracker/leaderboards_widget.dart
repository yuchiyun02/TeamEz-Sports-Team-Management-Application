import 'package:flutter/material.dart';
import 'package:teamez/models/members_model.dart';

/// Top Scorers Leaderboard
class TopScorersLeaderboard extends StatelessWidget {
  final List<Member> members;

  const TopScorersLeaderboard({super.key, required this.members});

  @override
  Widget build(BuildContext context) {
    List<Member> sorted = List.from(members)
      ..sort((a, b) => b.scores.compareTo(a.scores));

    return _buildLeaderboard("Top Scorers", sorted, (m) => m.scores);
  }
}

/// Top Assists Leaderboard
class TopAssistsLeaderboard extends StatelessWidget {
  final List<Member> members;

  const TopAssistsLeaderboard({super.key, required this.members});

  @override
  Widget build(BuildContext context) {
    List<Member> sorted = List.from(members)
      ..sort((a, b) => b.assists.compareTo(a.assists));

    return _buildLeaderboard("Top Assists", sorted, (m) => m.assists);
  }
}

/// Top Games Played Leaderboard
class TopGamesPlayedLeaderboard extends StatelessWidget {
  final List<Member> members;

  const TopGamesPlayedLeaderboard({super.key, required this.members});

  @override
  Widget build(BuildContext context) {
    List<Member> sorted = List.from(members)
      ..sort((a, b) => b.totalGames.compareTo(a.totalGames));

    return _buildLeaderboard("Most Games Played", sorted, (m) => m.totalGames);
  }
}

/// Reusable leaderboard builder
Widget _buildLeaderboard(String title, List<Member> sortedMembers, int Function(Member) statGetter) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Card(
      elevation: 3,
      child: Column(
        children: [
          ListTile(
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ),
          Divider(),
          ...sortedMembers.take(5).map((member) => ListTile(
                leading: CircleAvatar(
                  backgroundImage: member.avatarURL != null && member.avatarURL!.isNotEmpty
                      ? NetworkImage(member.avatarURL!)
                      : null,
                  child: member.avatarURL == null || member.avatarURL!.isEmpty
                      ? Text(member.name[0])
                      : null,
                ),
                title: Text(member.name),
                trailing: Text(statGetter(member).toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              )),
        ],
      ),
    ),
  );
}
