import 'package:flutter/material.dart';
import 'package:teamez/widgets/intro/intro_scaffold.dart';
import 'package:teamez/constant/constants.dart';
import 'package:teamez/services/auth_service.dart';

class ForgetPassPage extends StatefulWidget {
  const ForgetPassPage({super.key});

  @override
  State<ForgetPassPage> createState() => _ForgetPassPageState();
}

class _ForgetPassPageState extends State<ForgetPassPage> {
  final _formForgotPassKey = GlobalKey<FormState>();
  final TextEditingController _emailResetController = TextEditingController();
  final authService = AuthService();

  @override
  void dispose() {
    _emailResetController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return IntroScaffold(
      child: Column(
        children: [
          Expanded(
            flex: 1,
            child: SizedBox(height:10)),
          Expanded(
            flex: 7,
            child: Container(
              padding: EdgeInsets.fromLTRB(25, 50, 25, 20),
              decoration: BoxDecoration(
                color: CustomCol.silver,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40)
                ),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formForgotPassKey,
                  child: Column(
                    children: [
                      Text("Reset Password",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: CustomCol.darkGrey
                        ),
                      ),
                
                      SizedBox(height:30),

                      Text("Enter your email and we wil send you a password reset link.",
                        textAlign: TextAlign.center,),

                      SizedBox(height:20),
                      //Email Input
                      TextFormField(
                        controller: _emailResetController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter email";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: Text("Email"),
                          hintText: "Enter Email",
                          hintStyle: TextStyle(color: CustomCol.black),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: CustomCol.black),
                            borderRadius: BorderRadius.circular(10)
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: CustomCol.black),
                            borderRadius: BorderRadius.circular(10)
                          ),
                        ),
                      ),
                
                      SizedBox(height:20),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            await authService.passwordReset(context: context, email: _emailResetController.text.trim());
                          },
                          child: Text("Reset Password",
                          style: TextStyle(color:CustomCol.darkGrey)))
                      ),
                      ],)
                  )
                ),
              ))]));
  }
}