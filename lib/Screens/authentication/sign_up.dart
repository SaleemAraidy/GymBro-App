import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gymbro/Screens/Home/home_screen.dart';
import 'package:gymbro/Screens/authentication/send_confirmation_code.dart';
import 'package:gymbro/Screens/authentication/sign_in.dart';
import 'package:gymbro/loading.dart';
import '../../Services/auth.dart';
import '../../Services/database.dart';
import '../Home/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {

  final AuthService _auth = AuthService();
  final _formkey = GlobalKey<FormState>();
  bool loading = false;

  //text field state
  String email = '';
  String username = '';
  String password = '';
  String password_confirm = '';
  bool passwordConfirmError = false;
  String errorMessage ='';

  //Function for validating email format
  bool isEmailValid(String email) {
    // Regular expression pattern for email validation
    RegExp emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
    return emailRegex.hasMatch(email);
  }


  //Function that checks if a user with 'username' already exists
  Future<bool> checkIfUsernameExists(String username) async {
    final usersRef = FirebaseFirestore.instance.collection('users');
    final querySnapshot = await usersRef.where('username', isEqualTo: username).get();
    return querySnapshot.docs.isNotEmpty;
  }



  //Function for validating username
  dynamic validateUsername(String? val) {
    if (val == null || val.isEmpty) {
      return 'Enter a username';
    }

    if (!RegExp(r'^[a-zA-Z0-9_.]+$').hasMatch(val)) {
      return 'Username contains forbidden characters!';
    }

    return null;
  }



  @override
  Widget build(BuildContext context) {
    return loading ? Loading() : Scaffold(
      backgroundColor: Colors.grey[800],
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 50),
        child: SingleChildScrollView(
          child: Form(
            key: _formkey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'GymBro',
                  style: TextStyle(
                      fontSize: 60,
                      color: Color(0xFFDEBB00),
                      fontFamily: 'KaushanScript'
                  ),
                ),
                const SizedBox(height: 80),
                TextFormField(
                  // validator: (val) => val!.isEmpty ? 'Enter Email or Username' : null,
                  validator: (val) => !isEmailValid(val!) ? 'Enter valid email' : null,
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
                      errorMessage ='';
                    });
                  },
                ),
                SizedBox(height: 20,),
                TextFormField(
                  //validator: (val) => val!.isEmpty ? 'Enter valid username' : null,
                  validator: (val) => validateUsername(val) ,
                  decoration: InputDecoration(
                    hintText: 'Choose Username',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onChanged: (val) {
                    setState(() {
                      username = val;
                      errorMessage ='';
                    });
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  validator: (val) => val!.length < 8 ? 'Passwords must be 8 chars long' : null  ,
                  decoration: InputDecoration(
                    hintText: 'Choose Password',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  obscureText: true,
                  onChanged: (val) {
                    setState(() {
                      password = val;
                    });
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  validator: (val) => val != password ? 'Passwords don\'t match' : null ,
                  decoration: InputDecoration(
                    hintText: 'Confirm Your Password',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  obscureText: true,
                  onChanged: (val) {
                    setState(() {
                      password_confirm = val;
                      passwordConfirmError = (password_confirm != password);
                    });
                  },
                ),
                const SizedBox(height: 10),

                Text(errorMessage,
                  style: const TextStyle(
                    color: Colors.red,
                  ),
                ),

                const SizedBox(height: 10,),

                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: const Color(0xFFDEBB00), // Set the button color to amber
                    ),
                    onPressed: () async {
                      if(_formkey.currentState!.validate()){

                        setState(() => loading = true );

                        dynamic result = await _auth.registerWithEmailAndPassword(email, password,username);
                        if(result is String){
                          //Could not create user
                          setState(() {
                            loading = false;
                            errorMessage = result;
                          });
                        }
                        else {
                          //Created user successfully
                          setState(() {
                            loading = false;
                            errorMessage = '';
                          });
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute<void>(builder: (context) {
                              return const HomeScreen();
                            }),
                          );
                        }
                      }

                    },
                    child: const Text('Sign Up',
                        style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'KaushanScript',
                            fontSize: 25
                        )
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Forgot your login details ?',
                      style: TextStyle(color: Colors.white),
                    ),
                    const SizedBox(width: 5),

                    GestureDetector(

                      onTap: () {
                        // Handle the clickable text action here
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(builder: (context) {
                            return SendConfCode();
                          }),
                        );
                        print('Forgot Password');
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account ?",
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(width: 5),

                    GestureDetector(

                      onTap: () {
                        // Handle the clickable text action here
                        // Navigator.of(context).pop();
                        // Handle the clickable text action here
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(builder: (context) {
                            return const SignIn();
                          }),
                        );
                        print('Bck to Log in page');
                      },
                      child: const Text(
                        'Log In.',
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

