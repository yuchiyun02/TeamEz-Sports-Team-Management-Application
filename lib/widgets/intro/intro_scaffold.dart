import 'package:flutter/material.dart';
import 'package:teamez/constant/constants.dart';

class IntroScaffold extends StatelessWidget {
  const IntroScaffold({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: CustomCol.armyGreen),
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Image.asset("assets/login_bg.jpg",
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity),

          SafeArea(
            child: child!,
          ),
        ],
      ) 
    );
    
    
  }
}