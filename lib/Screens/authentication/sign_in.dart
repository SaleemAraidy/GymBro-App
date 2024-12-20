import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gymbro/Screens/authentication/send_confirmation_code.dart';
import 'package:gymbro/Screens/authentication/sign_up.dart';
import 'package:gymbro/Services/auth.dart';
import 'package:gymbro/loading.dart';

import '../Home/home_screen.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  final AuthService _auth = AuthService();
  final _formkey = GlobalKey<FormState>();
  bool loading = false;

  //text field state
  String email = '';
  String password = '';
  String errorMessage ='';

  @override
  Widget build(BuildContext context) {
    return loading ? Loading() : Scaffold(
      backgroundColor: Colors.grey[800],
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
        child: SingleChildScrollView(
          child: Form(
            key: _formkey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height:50),
                Text(
                  'GymBro',
                  style: TextStyle(
                      fontSize: 60,

                      color: Color(0xFFDEBB00),
                      fontFamily: 'KaushanScript'


                  ),
                ),
                SizedBox(height: 50),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Email',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onChanged: (val) {
                    setState(() {
                      email = val;
                      errorMessage = '';
                    });
                  },
                ),
                SizedBox(height: 20),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Password',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onChanged: (val){
                    setState(() {
                      password = val;
                      errorMessage = '';
                    });
                  },
                  obscureText: true,
                ),

                SizedBox(height: 10),

                Text(errorMessage,
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),

                SizedBox(height: 10),

                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: const Color(0xFFDEBB00), // Set the button color to amber
                    ),
                    onPressed: () async {
                      setState(() {
                        loading = true;
                      });
                      dynamic result = await _auth.signInWithEmailAndPassword(email, password);
                      if(result is String){
                        // print("did not log in");

                        setState(() {
                          loading = false;
                          errorMessage = result;// Update loading state here
                        });

                      }

                      else {
                        // print("logged in");
                        setState(() {
                          loading = false;
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute<void>(builder: (context) {
                              return const HomeScreen();
                            }),
                          );
                        });
                      }


                    },
                    child: const Text('Log In',
                        style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'KaushanScript',
                            fontSize: 25
                        )
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Forgot your login details ?',
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(width: 5),

                    GestureDetector(

                      onTap: () {
                        // Handle the clickable text action here
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(builder: (context) {
                            return SendConfCode();
                          }),
                        );
                        // print('Forgot Password');
                      },
                      child: Text(
                        'click here.',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.white,
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox( height: 60),
                Divider(
                  height: 60,
                  color: Colors.white,
                ),
                SizedBox( height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account ?",
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(width: 5),

                    GestureDetector(

                      onTap: () {
                        // Handle the clickable text action here
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(builder: (context) {
                            return SignUp();
                          }),
                        );
                        // print('Want to Sign up');
                      },
                      child: Text(
                        'Sign Up.',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.white,
                        ),
                      ),
                    )
                  ],
                )

              ],
            ),
          ),
        ),
      ),
    );
  }
}

