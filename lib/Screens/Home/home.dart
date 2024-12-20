import 'package:flutter/material.dart';
// import 'package:gymbro/Services/auth.dart';

class Home extends StatelessWidget {
   Home({Key? key}) : super(key: key);

  // final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Dummy Home Page",
          style: TextStyle(
            fontSize: 20,
            fontFamily: 'KaushanScript',
          ),
        ),
        actions: <Widget>[
          TextButton.icon(
              onPressed: () async {
                // await _auth.signOut();
              },
              icon: Icon(Icons.person ,color: Colors.black,),
              label: Text("Log out" , style: TextStyle(color: Colors.black),))

        ],
        backgroundColor: Colors.amber,
      ),
      backgroundColor: Colors.grey,
    body: Container(
      child: Text("Home Page"),
    )
    );
  }
}
