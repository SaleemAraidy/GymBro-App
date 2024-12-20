import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gymbro/Services/database.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:gymbro/Services/auth.dart';

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final AuthService _auth = AuthService();
  final DatabaseService _database =
  DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid);

  late Stream<QuerySnapshot> notificationsStream;

  @override
  void initState() {
    super.initState();
    notificationsStream = _database.usersCollection.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text(
          'Notifications',
          style: TextStyle(
            fontFamily: 'Kaushan Script',
            color: Colors.black,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: notificationsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final notifications = snapshot.data?.docs;
            return ListView.builder(
              itemCount: notifications!.length,
              itemBuilder: (context, index) {
                final notification = notifications?[index];
                final connects = (notification?.data() as Map<String, dynamic>)['connects'] as List<dynamic>;
                final username = (notification?.data() as Map<String, dynamic>)['username'] as String?;
                final imageUrl = (notification?.data() as Map<String, dynamic>)['imageurl'] as String?;

                if (connects.contains(_auth.currentUser!.uid)) {
                  return Column(
                    children: [
                      ListTile(
                        leading: ClipOval(
                          child: Container(
                            width: 40.0,
                            height: 40.0,
                            child: imageUrl != null
                                ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return CircularProgressIndicator();
                              },
                              errorBuilder: (context, error, stackTrace) => Icon(Icons.person),
                            )
                                : Icon(Icons.person),
                          ),
                        ),
                        title: Text(
                          '$username connected with you.',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      if (index != notifications.length - 1) Divider(color: Colors.grey, thickness: 1.0),
                    ],
                  );
                }

                return SizedBox();
              },
            );
          }
        },
      ),
    );
  }
}
