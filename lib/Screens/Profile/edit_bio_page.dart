import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gymbro/Screens/Profile/profile_page.dart';

void main() {
  runApp(EditBioPage());
}
class EditBioPage extends StatefulWidget{
  @override
  State<EditBioPage> createState() => _EditBioPageState();
}


class _EditBioPageState extends State<EditBioPage> {
  final TextEditingController bioController = TextEditingController();
  String username = "";
  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    final userID = user?.uid??'';
    final snapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(userID)
        .snapshots()
        .first;
    if (snapshot.exists) {
      setState(() {
        username = snapshot.data()!["username"] as String; // Assign the value to the username
      });
    }
  }
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[600],
      appBar: AppBar(
        backgroundColor: Colors.grey[600],
        title:Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              flex: 4,
              child: Text(
                username,
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: IconButton(
                  onPressed: (){
                  },
                  icon: Icon(
                    Icons.settings,
                    color: Colors.white,
                  )
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 300,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller:bioController,
                decoration: InputDecoration(
                  hintText: 'Enter Bio Change',
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Perform the desired action when the button is pressed
                final user = FirebaseAuth.instance.currentUser;
                final userID = user?.uid??'';
                FirebaseFirestore.instance.collection('users').doc(userID).update({'bio': bioController.text});
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.yellow,
              ),
              child: Text(
                'Confirm Change',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


