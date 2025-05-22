import 'package:flutter/material.dart';
import 'package:teamez/constant/constants.dart';

class AppBarTitle extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const AppBarTitle({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      backgroundColor: CustomCol.bgGreen,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}