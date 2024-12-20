import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gymbro/Screens/authentication/send_confirmation_code.dart';
import 'package:gymbro/Screens/authentication/sign_up.dart';
import 'package:gymbro/Settings/change_username.dart';
import 'package:gymbro/Services/auth.dart';
import 'package:gymbro/loading.dart';

import 'package:gymbro/Screens/Home/home_screen.dart';


class MySettings extends StatefulWidget {
  const MySettings({Key? key}) : super(key: key);

  @override
  _MySettingsState createState() => _MySettingsState();
}

class _MySettingsState extends State<MySettings> {

  final AuthService _auth = AuthService();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text(
          "Settings",
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(
                  Icons.person,
                  color: Colors.amber,
                  size: 70,
                ),
                SizedBox(width: 25),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(builder: (context) {
                            return ChangeUsername();
                          }),
                        );

                      },
                      child: Text(
                        "Change Username",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                )
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(
                  Icons.lock,
                  color: Colors.amber,
                  size: 70,
                ),
                SizedBox(width: 25),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: TextButton(
                      onPressed: () async {
                        User? user = _auth.currentUser;
                        String? email = user?.email;
                        dynamic result = await _auth.resetPassword(email!);
                        if(result == true){
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Password reset link was sent to your email'),
                              duration: Duration(seconds: 3), // Optional: Adjust the duration as needed
                            ),
                          );
                        }
                        else{
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Error'),
                              content: Text('Could not send password reset link.'),
                              actions: [
                                TextButton(
                                  onPressed: () {},
                                  child: Text('OK'),
                                ),
                              ],
                            ),
                          );
                        }

                      },
                      child: Text(
                        "Change Password",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                )
              ],
            ),
            SizedBox(height: 20),
            /*Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(
                  Icons.people_alt_rounded,
                  color: Colors.amber,
                  size: 70,
                ),
                SizedBox(width: 25),
                Switch(
                  value: isSwitched,
                  onChanged: (value) {
                    setState(() {
                      isSwitched = value;
                    });
                  },
                ),
              ],
            )*/
          ],
        ),
      ),
    );
  }
}