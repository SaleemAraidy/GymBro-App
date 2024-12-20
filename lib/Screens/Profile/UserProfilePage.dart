import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../../Widgets/post_utility.dart';
import '../Chats/chat_screen.dart';
import 'detailed_post_page.dart';

void main() {
  runApp(UserProfilePage(userID: ""));
}

class UserProfilePage extends StatefulWidget {
  final String userID; // Add a parameter to receive the selected userID

  UserProfilePage({required this.userID});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  late Stream<DocumentSnapshot> _userDataStream;
  String username = ""; // Define the username as a class member
  List<String> posts = []; // List to store the post image URLs
  bool isRequested = false; // Track if friend request is already sent

  @override
  void initState() {
    super.initState();
    _userDataStream = FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userID) // Use the selected user ID from the widget
        .snapshots();
  }

  void sendFriendRequest() async {
    final currentUserID = FirebaseAuth.instance.currentUser!.uid;
    final friendUserID = widget.userID;

    final currentUserRef = FirebaseFirestore.instance
        .collection("users")
        .doc(currentUserID);
    final friendUserRef =
    FirebaseFirestore.instance.collection("users").doc(friendUserID);

    final currentUserDoc = await currentUserRef.get();
    final friendUserDoc = await friendUserRef.get();

    if (currentUserDoc.exists && friendUserDoc.exists) {
      final currentUserData = currentUserDoc.data();
      final friendUserData = friendUserDoc.data();

      final List<dynamic>? currentUserConnects =
      currentUserData?['connects'] as List<dynamic>?;
      final List<dynamic>? friendUserConnects =
      friendUserData?['connects'] as List<dynamic>?;

      final bool currentUserConnected =
          currentUserConnects?.contains(friendUserID) ?? false;
      final bool friendUserConnected =
          friendUserConnects?.contains(currentUserID) ?? false;

      if (currentUserConnected && friendUserConnected) {
        // Remove the user IDs from the connects attribute of both users
        await currentUserRef.update({
          "connects": FieldValue.arrayRemove([friendUserID]),
        });

        await friendUserRef.update({
          "connects": FieldValue.arrayRemove([currentUserID]),
        });

        setState(() {
          isRequested = false;
        });
      } else {
        if (!currentUserConnected) {
          // Add the friend user ID to the connects attribute of the current user
          await currentUserRef.update({
            "connects": FieldValue.arrayUnion([friendUserID]),
          });
        }

        if (!friendUserConnected) {
          // Add the current user ID to the connects attribute of the friend user
          await friendUserRef.update({
            "connects": FieldValue.arrayUnion([currentUserID]),
          });
        }

        setState(() {
          isRequested = true;
        });

        // Send notification to the user
        final firebaseMessaging = FirebaseMessaging.instance;
        final token = await firebaseMessaging.getToken();
        final topic = "user_$friendUserID";
        final notification = {
          "notification": {
            "title": "Friend Request",
            "body": "You have received a friend request",
          },
          "data": {
            "click_action": "FLUTTER_NOTIFICATION_CLICK",
            "status": "done"
          },
          "to": "/topics/$topic",
          "priority": "high",
        };

        //await firebaseMessaging.send(notification);
      }
    } else {
      print("User not found");
    }
  }

  void navigateToChatScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          currentUserId: FirebaseAuth.instance.currentUser!.uid,
          selectedUserId: widget.userID,
          selectedUserName: username,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[600],
      appBar: AppBar(
        backgroundColor: const Color(0xFFDEBB00),
        title: StreamBuilder<DocumentSnapshot>(
          stream: _userDataStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            if (snapshot.hasData) {
              final data = snapshot.data!.data() as Map<String, dynamic>; // Explicitly cast data to Map<String, dynamic>
              username = data['username'] as String;
              return Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Center(
                      child: Text(
                        username,
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Text('User not found');
          },
        ),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        color: Colors.grey[600],
        child: StreamBuilder<DocumentSnapshot>(
          stream: _userDataStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}");
            }

            if (snapshot.hasData) {
              final data = snapshot.data!.data() as Map<String, dynamic>; // Explicitly cast data to Map<String, dynamic>
              String bio = data["bio"] as String;
              List<dynamic> connects = (data["connects"]) as List<dynamic>;
              String connections = "0";
              if (bio.isEmpty) {
                bio = "Bio : ";
              }
              if (connects.isEmpty) {
                connections = "0";
              } else {
                connections = (connects.length).toString();
              }
              final String imageurl = data["imageurl"] as String;
              username = data["username"] as String; // Assign the value to the username

              final bool isCurrentUserConnected =
              connects.contains(FirebaseAuth.instance.currentUser!.uid);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        username, // Use the selected username from the retrieved data
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      CircleAvatar(
                        radius: 30.0,
                        backgroundImage: NetworkImage(
                          imageurl,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    bio,
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.normal,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        connections,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                        ),
                      ),
                      SizedBox(width: 16.0),
                      Text(
                        "Connections",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 16.0, height: 10.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ElevatedButton.icon(
                        onPressed: sendFriendRequest,
                        icon: Icon(
                          isCurrentUserConnected ? Icons.check : Icons.add,
                          color: Colors.black,
                        ),
                        label: Text(
                          isCurrentUserConnected ? "Connected" : "Connect",
                          style: TextStyle(color: Colors.black),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isCurrentUserConnected ? Colors.grey : const Color(0xFFDEBB00),
                        ),
                      ),
                      SizedBox(width: 16.0),
                      ElevatedButton.icon(
                        onPressed: navigateToChatScreen,
                        icon: Icon(Icons.message),
                        label: Text('Message'),
                        style: ElevatedButton.styleFrom(
                          primary: Color(0xFFDEBB00),
                          onPrimary: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  Divider(color: Colors.white),
                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'POSTS',
                      style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Divider(color: Colors.white),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('posts')
                          .where('author', isEqualTo: widget.userID)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          return Text("Error: ${snapshot.error}");
                        }

                        if (snapshot.hasData) {
                          final postsData = snapshot.data!.docs;
                          posts = postsData.map((doc) => doc['imageUrl'] as String).toList();

                          return GridView.builder(
                            padding: const EdgeInsets.only(top: 16.0),
                            itemCount: posts.length,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 8.0,
                              mainAxisSpacing: 8.0,
                            ),
                            itemBuilder: (context, index) {
                              final postImageUrl = posts[index]; // Access the imageUrl from the posts list
                              return FutureBuilder<String?>(
                                future: PostUtility.getPostIdFromImageUrl(postImageUrl),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData && snapshot.data != null) {
                                    final postId = snapshot.data!; // Access the postId from snapshot.data
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => DetailedPostPage(postID: postId),
                                          ),
                                        );
                                      },
                                      child: Image.network(
                                        postImageUrl,
                                        fit: BoxFit.cover,
                                      ),
                                    );
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else {
                                    return const CircularProgressIndicator();
                                  }
                                },
                              );
                            },
                          );
                        }

                        return Text('No posts found');
                      },
                    ),
                  ),
                ],
              );
            }

            return Center(
              child: Text('Error retrieving user data'),
            );
          },
        ),
      ),
    );
  }
}
