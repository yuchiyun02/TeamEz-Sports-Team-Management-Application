import 'package:flutter/material.dart';
import 'package:teamez/models/members_model.dart';

class MemberComparisonCard extends StatelessWidget {
  final Member memberA;
  final Member memberB;

  const MemberComparisonCard({
    super.key,
    required this.memberA,
    required this.memberB,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(8),
      child: Column(
        children: [
          const ListTile(
            title: Center(
              child: Text(
                "Member Comparison",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ),
          const Divider(),
          _buildComparisonRow("Scores", memberA.scores, memberB.scores),
          _buildComparisonRow("Assists", memberA.assists, memberB.assists),
          _buildComparisonRow("Games", memberA.totalGames, memberB.totalGames),
          _buildComparisonRow("Injuries", memberA.lifetimeInjuries, memberB.lifetimeInjuries),

          SizedBox(height:20)
        ],
      ),
    );
  }

  Widget _buildComparisonRow(String label, int statA, int statB) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(statA.toString(), textAlign: TextAlign.center)),
          Expanded(child: Text(label, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(statB.toString(), textAlign: TextAlign.center)),
        ],
      ),
    );
  }
}

class MemberComparisonSelector extends StatefulWidget {
  final List<Member> members;
  const MemberComparisonSelector({super.key, required this.members});

  @override
  State<MemberComparisonSelector> createState() => _MemberComparisonSelectorState();
}

class _MemberComparisonSelectorState extends State<MemberComparisonSelector> {
  Member? selectedA;
  Member? selectedB;

  @override
  void initState() {
    super.initState();
    if (widget.members.length >= 2) {
      selectedA = widget.members[0];
      selectedB = widget.members[1];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildDropdown(selectedA!.name, selectedA, (Member? val) {
          setState(() {
            selectedA = val;
          });
        }),
        _buildDropdown(selectedB!.name, selectedB, (Member? val) {
          setState(() {
            selectedB = val;
          });
        }),
        if (selectedA != null && selectedB != null)
          MemberComparisonCard(memberA: selectedA!, memberB: selectedB!),
      ],
    );
  }

  Widget _buildDropdown(String label, Member? selected, ValueChanged<Member?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: DropdownButtonFormField<Member>(
        decoration: InputDecoration(labelText: label),
        value: selected,
        items: widget.members
            .map((m) => DropdownMenuItem(
                  value: m,
                  child: Text(m.name),
                ))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
