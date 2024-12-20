import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gymbro/Screens/Profile/profile_page.dart';
import 'package:gymbro/Screens/authentication/send_confirmation_code.dart';
import 'package:gymbro/Screens/authentication/sign_up.dart';
import 'package:gymbro/Services/auth.dart';
import 'package:gymbro/Services/database.dart';
import 'package:gymbro/loading.dart';

import 'package:gymbro/Screens/Home/home_screen.dart';

class ChangeUsername extends StatefulWidget {
  const ChangeUsername({Key? key}) : super(key: key);

  @override
  _ChangeUsernameState createState() => _ChangeUsernameState();
}

class _ChangeUsernameState extends State<ChangeUsername> {
  final AuthService _auth = AuthService();
  late Stream<User?> _userStream;
  final DatabaseService _databaseService =
  DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid);
  String username = '';

  @override
  void initState() {
    super.initState();
    _userStream = FirebaseAuth.instance.authStateChanges();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _userStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          if (user != null) {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.amber,
                title: Text(
                  "Change Username",
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'KaushanScript',
                    fontSize: 37,
                  ),
                ),
              ),
              body: Container(
                color: Colors.grey[800],
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextFormField(
                      onChanged: (val) {
                        setState(() {
                          username = val;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'New Username',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: TextButton(
                          onPressed: () async {
                            dynamic result = await _databaseService.changeUsername(username);
                            if (result) {
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(builder: (context) {
                                  return ProfilePage();
                                }),
                              );
                            } else {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Error'),
                                  content: Text('Could not update username.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                          child: Text(
                            "Set New Username",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          } else {
            // User is not authenticated, show loading or redirect to login
            return Loading(); // Replace Loading with your desired widget
          }
        } else {
          // Connection is not active, show loading or handle accordingly
          return Loading(); // Replace Loading with your desired widget
        }
      },
    );
  }
}
