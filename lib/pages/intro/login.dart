import 'package:flutter/material.dart';
import 'package:teamez/widgets/general/custom_textfield.dart';
import 'package:teamez/widgets/intro/intro_scaffold.dart';
import 'package:teamez/constant/constants.dart';
import 'package:teamez/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formLoginKey = GlobalKey<FormState>();
  bool rememberPassword = true;
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
                  key: _formLoginKey,
                  child: Column(
                    children: [
                      Text("Welcome Back",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: CustomCol.darkGrey
                        ),
                      ),
                
                      SizedBox(height:30),
                
                      //Email Input
                      CustomTextField(
                        controller: _emailController, 
                        label: "Email", 
                        hintText: "Please enter email",
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter email";
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                
                              Text("Remember me",
                                style: TextStyle(color: CustomCol.black))
                          ]),
                
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, "/forgetpasspage");
                            },
                            child: Text("Forget Password?",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: CustomCol.darkGrey
                              )),
                          )
                      ],),
                
                      SizedBox(height: 20),
                
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if(_formLoginKey.currentState!.validate()) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Logging in...")
                                ),
                              );
                            
                            //Log in user
                            await authService.login(
                                context: context,
                                email: _emailController.text,
                                password: _passwordController.text,
                                rememberMe: rememberPassword
                              );
                            }
                          }, 
                          child: Text("Log In", 
                            style: TextStyle(color: CustomCol.darkGrey),))
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
                          child: Text("Log in with",
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
                        Text("Don't have an account? ",
                          style: TextStyle(color: CustomCol.darkGrey)),
                        
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, "/signuppage");
                          },
                          child: Text("Sign up",
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