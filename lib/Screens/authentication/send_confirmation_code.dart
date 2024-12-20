import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gymbro/Screens/authentication/enter_code.dart';
import 'package:gymbro/Screens/authentication/sign_in.dart';
import 'dart:math';
import 'package:http/http.dart' as http;

import '../../Services/auth.dart';

class SendConfCode extends StatefulWidget {
  const SendConfCode({Key? key}) : super(key: key);

  @override
  State<SendConfCode> createState() => _SendConfCodeState();
}

class _SendConfCodeState extends State<SendConfCode> {

  final AuthService _auth = AuthService();
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 70),
              Icon(Icons.lock,
                size: 80,
                color: Colors.white,),
              SizedBox(height: 30),
              Center(
                child: Text("Trouble signing in ?\n "
                    "Enter your email and we will send you"
                    " a password reset link.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 17
                  ),),
              ),
              SizedBox(height: 30),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: 'Enter you email',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.amber, // Set the button color to amber
                  ),
                  onPressed: () async {
                    //dynamic result = await sendEmail(email : emailController.text, code: conf_code);
                    dynamic result = await _auth.resetPassword(emailController.text);
                    print(result);
                    if(result == true) {

                      //Shows an alert that password reset link was sent to email
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Link Sent!'),
                          content: Text('A password reset link was sent to your email'),
                          actions: [
                            TextButton(
                              onPressed: () =>  Navigator.of(context).push(
                                MaterialPageRoute<void>(builder: (context) {
                                  return SignIn();
                                }),
                              ),
                              child: Text('OK'),
                            ),
                          ],
                        ),
                      );

                    }
                    else {
                      // Show an error message for incorrect code
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Error'),
                          content: Text('Could not send password reset link.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('OK'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  child: Text('Send link',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18
                      )
                  ),
                ),
              ),
              SizedBox(height: 30),

              GestureDetector(

                onTap: () {
                  // Handle the clickable text action here
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  print('Back to Login.');
                },
                child: Text(
                  'Back to Log in.',
                  style: TextStyle(
                    fontSize: 17,
                    decoration: TextDecoration.underline,
                    color: Colors.white,
                  ),
                ),
              )

            ],
          ),
        ),
      ),
    );
  }
}
