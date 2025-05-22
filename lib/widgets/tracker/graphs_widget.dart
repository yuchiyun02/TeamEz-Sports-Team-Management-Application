import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';


class ScoreOverTimeChart extends StatelessWidget {
  final List<FlSpot> scoresData;
  final DateTime startTime;

  const ScoreOverTimeChart({super.key, required this.scoresData, required this.startTime});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        barGroups: scoresData.map((e) {
          return BarChartGroupData(
            x: e.x.toInt(),
            barRods: [
              BarChartRodData(toY: e.y, color: Colors.blue),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final date = startTime.add(Duration(days: value.toInt()));
                final label = DateFormat('MM/dd').format(date);
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(label, style: TextStyle(fontSize: 10)),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true),
          ),
        ),
        borderData: FlBorderData(show: true),
        gridData: FlGridData(show: true),
      ),
    );
  }
}

class AssistsOverTimeChart extends StatelessWidget {
  final List<FlSpot> assistsData;
  final DateTime startTime;

  const AssistsOverTimeChart({super.key, required this.assistsData, required this.startTime});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        barGroups: assistsData.map((e) {
          return BarChartGroupData(
            x: e.x.toInt(),
            barRods: [
              BarChartRodData(toY: e.y, color: Colors.green),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final date = startTime.add(Duration(days: value.toInt()));
                final label = DateFormat('MM/dd').format(date);
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(label, style: TextStyle(fontSize: 10)),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true),
          ),
        ),
        borderData: FlBorderData(show: true),
        gridData: FlGridData(show: true),
      ),
    );
  }
}


