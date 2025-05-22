import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:teamez/constant/constants.dart';
import 'package:teamez/models/events_model.dart';
import 'package:teamez/models/members_model.dart';
import 'package:teamez/widgets/tracker/leaderboards_widget.dart';
import 'package:teamez/widgets/tracker/graphs_widget.dart';
import 'package:teamez/widgets/tracker/member_comparison.dart';

class CombinedLogEntry {
  final String scorer;
  final String assister;
  final DateTime timestamp;

  CombinedLogEntry({
    required this.scorer,
    required this.assister,
    required this.timestamp,
  });
}

class AggregatedMetrics {
  final List<CombinedLogEntry> allLogs;

  AggregatedMetrics({required this.allLogs});

  List<FlSpot> generateScoresGraphData() {
    List<FlSpot> scoresData = [];
    int score = 0;

    if (allLogs.isEmpty) return scoresData;

    final start = DateTime(
      allLogs.first.timestamp.year,
      allLogs.first.timestamp.month,
      allLogs.first.timestamp.day,
    );

    for (var entry in allLogs) {
      score += entry.scorer.isNotEmpty ? 1 : 0;
      final entryDate = DateTime(
        entry.timestamp.year,
        entry.timestamp.month,
        entry.timestamp.day,
      );
      final timeDiff = entryDate.difference(start).inDays.toDouble(); // or .inDays
      scoresData.add(FlSpot(timeDiff, score.toDouble()));
    }

    return scoresData;
  }

  List<FlSpot> generateAssistsGraphData() {
    List<FlSpot> assistsData = [];
    int assists = 0;

    if (allLogs.isEmpty) return assistsData;

    final start = DateTime(
      allLogs.first.timestamp.year,
      allLogs.first.timestamp.month,
      allLogs.first.timestamp.day,
    );

    for (var entry in allLogs) {
      assists += entry.assister.isNotEmpty ? 1 : 0;
      final entryDate = DateTime(
        entry.timestamp.year,
        entry.timestamp.month,
        entry.timestamp.day,
      );
      final timeDiff = entryDate.difference(start).inDays.toDouble();
      print("timeDiff :${timeDiff}");
      assistsData.add(FlSpot(timeDiff, assists.toDouble()));
    }

    return assistsData;
  }
}


class TrackerPage extends StatefulWidget {
  const TrackerPage({super.key});

  @override
  State<TrackerPage> createState() => _TrackerPageState();
}

class _TrackerPageState extends State<TrackerPage> {
  List<Member> members = [];
  bool isLoading = true;

  List<FlSpot> scoresGraphData = [];
  List<FlSpot> assistsGraphData = [];
  DateTime startTime = DateTime(DateTime.now().year, 1, 1);

  @override
  void initState() {
    super.initState();
    fetchMembers();
    loadData();
  }

  Future<void> fetchMembers() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('members')
        .get();

    final List<Member> loadedMembers = snapshot.docs.map((doc) {
      return Member.fromMap(doc.data());
    }).toList();

    setState(() {
      members = loadedMembers;
      isLoading = false;
    });
  }

  Future<void> loadData() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    final memberSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('members')
        .get();

    final List<Member> loadedMembers = memberSnapshot.docs
        .map((doc) => Member.fromMap(doc.data()))
        .toList();

    final allLogs = await fetchAllLogs(userId);
    final metrics = AggregatedMetrics(allLogs: allLogs);

    setState(() {
      members = loadedMembers;
      scoresGraphData = metrics.generateScoresGraphData();
      assistsGraphData = metrics.generateAssistsGraphData();
      isLoading = false;
    });
  }

  Future<List<CombinedLogEntry>> fetchAllLogs(String userId) async {
    final eventsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('events')
        .get();

    List<CombinedLogEntry> logs = [];

    for (var doc in eventsSnapshot.docs) {
      final data = doc.data();

      if (data.containsKey('metrics') && data['metrics']?['eventLog'] != null) {
        final eventDate = (data['dateFrom'] as Timestamp).toDate();

        final logEntries = List<Map<String, dynamic>>.from(data['metrics']['eventLog']);

        for (int i = 0; i < logEntries.length; i++) {
          final log = logEntries[i];
          logs.add(CombinedLogEntry(
            scorer: log['scorer'] ?? '',
            assister: log['assister'] ?? '',
            timestamp: eventDate,
          ));
        }
      }
    }

    return logs;
  }

  Future<List<EventMetrics>> fetchEventMetrics(String memberId) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    final eventsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('events')
        .get();

    List<EventMetrics> metricsList = [];

    for (var eventDoc in eventsSnapshot.docs) {
      final eventMetricsSnapshot = await eventDoc.reference.collection('metrics').get();
      for (var metricsDoc in eventMetricsSnapshot.docs) {
        final metricsData = metricsDoc.data();

        if (metricsData['scorer'] == memberId || metricsData['assister'] == memberId) {
          metricsList.add(EventMetrics.fromMap(metricsData));
        }
      }
    }

    return metricsList;
  }

  @override
  Widget build(BuildContext context) {
    
    if (isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

    if (members.isEmpty) {
      return const Center(child: Text("No statistics found."));
    }

    Member topScorer = members.reduce((a, b) => a.scores >= b.scores ? a : b);

    return Scaffold(
      backgroundColor: CustomCol.bgGreen,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: Text("Tracker", style:TextStyle(fontWeight: FontWeight.bold, fontSize: 30))),
            SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "👑 ${topScorer.name} : Current Top Scorer",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Card(
                elevation: 4.0,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Scores: ${topScorer.scores}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text("Assists: ${topScorer.assists}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text("Games Played: ${topScorer.totalGames}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text("Status: ${topScorer.playerStatus}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      CircleAvatar(
                        backgroundImage: NetworkImage(topScorer.avatarURL.toString()),
                        radius: 40,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 8),

            Center(child:Text("Scores Over Time", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20))),

            Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                height: 220,
                child: ScoreOverTimeChart(scoresData: scoresGraphData, startTime: startTime),
              ),
            ),

            SizedBox(height: 8),

            Center(child:Text("Assists Over Time", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20))),

            Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                height: 220,
                child: AssistsOverTimeChart(assistsData: assistsGraphData, startTime: startTime),
              ),
            ),

            SizedBox(height: 24),

            TopScorersLeaderboard(members: members),
            TopAssistsLeaderboard(members: members),
            TopGamesPlayedLeaderboard(members: members),

            SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: MemberComparisonSelector(members: members, ),
            ),
            
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
