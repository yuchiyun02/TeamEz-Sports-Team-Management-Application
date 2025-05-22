import 'package:flutter/material.dart';
import 'package:teamez/constant/constants.dart';

class CustomFAB extends StatelessWidget {
  final Widget destination;

  const CustomFAB({super.key, required this.destination});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: CustomCol.brightGreen,
      foregroundColor: CustomCol.silver,
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
      },
      child: Icon(Icons.add),
    );
  }
}