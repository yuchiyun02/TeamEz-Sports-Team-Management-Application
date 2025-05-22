import 'package:flutter/material.dart';
import 'package:teamez/widgets/intro/intro_scaffold.dart';
import 'package:teamez/constant/constants.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:teamez/policies/privacy_policy.dart';
import 'package:teamez/services/auth_service.dart';
import 'package:teamez/widgets/general/custom_textfield.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formSignupKey = GlobalKey<FormState>();
  bool rememberPassword = true;
  final TextEditingController _teamNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final authService = AuthService();

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
                  key: _formSignupKey,
                  child: Column(
                    children: [
                      Text("Get Started",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: CustomCol.darkGrey
                        ),
                      ),
                
                      SizedBox(height:30),

                       // Team Name Input
                      CustomTextField(
                        controller: _teamNameController, 
                        label: "Team Name", 
                        hintText: "Enter Team Name",
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter team name";
                          }
                          return null;
                      }),

                      SizedBox(height:20),

                      //Email Input
                      CustomTextField(
                        controller: _emailController, 
                        label: "Email", 
                        hintText: "Please enter email",
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter team name";
                          } else if (!value.contains("@")) {
                          return "Please enter a valid email";
                          }
                          return null;
                      }),
                      
                      SizedBox(height:20),
                
                      //Password Input
                      CustomTextField(
                        controller: _passwordController, 
                        label: "Password", 
                        hintText: "Please enter password",
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter password";
                          } else if (value.length <= 6) {
                            return "Password must be longer than 6 characters";
                          }
                          return null;
                        }),
                      
                      SizedBox(height:5),
                
                      Row(
                        children: [
                          Row(
                            children: [
                              Checkbox(value: rememberPassword, 
                              onChanged: (bool? value) {
                                setState(() {
                                  rememberPassword = value!;
                                });
                              },
                              activeColor: CustomCol.darkGrey,
                              ),
                
                              Text("I agree to the processing of ",
                                style: TextStyle(color: CustomCol.black))
                          ]),
                
                          GestureDetector(
                            onTap: () {
                              // Show Privacy Policy
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text("Privacy Policy"),
                                    content: SingleChildScrollView(
                                        child: MarkdownBody(data: privacyPolicyText), // Uses Markdown for better formatting
                                      ),

                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text("Close"),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Text("Personal Data",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: CustomCol.armyGreen
                              )),
                          )
                      ],),
                
                      SizedBox(height: 20),
                
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if(_formSignupKey.currentState!.validate() && rememberPassword) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Processing data...")
                                ),
                              );
                              
                              //Register User
                              await AuthService().signup(
                                context: context,
                                teamName: _teamNameController.text,
                                email: _emailController.text,
                                password: _passwordController.text
                              );

                            } else if (!rememberPassword) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Please agree to the processing of personal data"),)
                              );
                            }
                          }, 
                          child: Text("Sign up",
                            style: TextStyle(color: CustomCol.darkGrey)))
                      ),

                    SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Divider(
                            thickness: 0.7,
                            color: CustomCol.darkGrey
                          )),

                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 0,
                            horizontal: 10
                          ),
                          child: Text("Sign up with",
                            style: TextStyle(color:Colors.black45))
                          ),

                        Expanded(
                          child: Divider(
                            thickness: 0.7,
                            color: CustomCol.darkGrey
                          ),)    
                    ]),

                    SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            await AuthService().signInFacebook(context: context);
                          },
                          child: Image.asset("assets/facebook.png",
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover),
                        ),

                        GestureDetector(
                          onTap: () async {
                            await authService.signinGoogle(context:context);
                          },
                          child: Image.asset("assets/google.png",
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover),
                        ),
                        
                        GestureDetector(
                          onTap: () async {
                            await authService.signinTwitter(context:context);
                          },
                          child: Image.asset("assets/x.png",
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover),
                        ),
                      ],
                    ),

                    SizedBox(height: 15),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Already have an account? ",
                          style: TextStyle(color: CustomCol.darkGrey)),
                        
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, "/loginpage");
                          },
                          child: Text("Log In",
                            style: TextStyle(
                              color: CustomCol.armyGreen,
                              fontWeight: FontWeight.bold
                            ))

                        )

                    ],)
                  ],)
                ),
              )
            ),)
        ],)
    );
  }
}