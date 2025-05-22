import 'package:flutter/material.dart';
import 'package:teamez/pages/intro/login.dart';
import 'package:teamez/pages/intro/signup.dart';
import 'package:teamez/widgets/intro/intro_scaffold.dart';
import 'package:teamez/widgets/intro/welcome_button.dart';
import 'package:teamez/constant/constants.dart';

class WelcomePage extends StatelessWidget{
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return IntroScaffold(
      child: Column(mainAxisAlignment: MainAxisAlignment.center,
        children: [
        Flexible(
          flex: 6,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/app_logo.png",
                height: 150,
                width: 300,
              ),
              Text("Welcome Back",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 45,
                fontWeight: FontWeight.bold,
                color: CustomCol.ashNavy,
              ),
              ),
          Text("We have missed you alot :)",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: CustomCol.ashNavy,
              ),
              ),
            ],
          ),
        ),
        Spacer(flex:1),
        Flexible(
          flex : 4,
          child: Align(
            alignment: Alignment.bottomRight,
            child: Row(children: [
              Expanded(child: WelcomeButton(buttonText: "Log in", 
                onTap: LoginPage(), 
                color: Colors.transparent,
                textColor: CustomCol.ashNavy,)),
              Expanded(child: WelcomeButton(buttonText: "Sign up", 
                onTap: SignupPage(), 
                color: CustomCol.armyGreen,
                textColor: CustomCol.silver,)),
            ],),
          ),
        ),
                
      ],)
    );
  }
}