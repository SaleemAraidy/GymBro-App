import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymbro/Widgets/user_utility.dart';


class LikesScreen extends StatelessWidget {
  final String postID;

  const LikesScreen({
    required this.postID,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
            'Likes',
            style: TextStyle(
              fontFamily: 'KaushanScript',
              color: Color(0xFF000000),
              fontSize: 35,
              ),
            ),
        elevation: 0,
        centerTitle: false,
        backgroundColor: const Color(0xFFDEBB00),
      ),
      body: StreamBuilder<List<String>>(
        stream: UserUtility.fetchLikedUsers(postID),
        builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
          if (snapshot.hasData) {
            final likedUsers = snapshot.data;
            return ListView.builder(
              itemCount: likedUsers?.length,
              itemBuilder: (BuildContext context, int index) {
                final userID = likedUsers![index];
                // Display user information or customize as needed
                return ListTile(
                  leading: FutureBuilder<String?>(
                    future: UserUtility.getUserProfileImage(userID),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircleAvatar(
                          backgroundColor: Colors.grey,
                        );
                      } else if (snapshot.hasError) {
                        return const CircleAvatar(
                          backgroundColor: Colors.grey,
                          child: Icon(Icons.error),
                        );
                      } else {
                        final imageUrl = snapshot.data;
                        if (imageUrl != null && imageUrl.isNotEmpty) {
                          return CircleAvatar(
                            backgroundColor: Colors.grey,
                            backgroundImage: NetworkImage(imageUrl),
                          );
                        } else {
                          return const CircleAvatar(
                            backgroundColor: Colors.grey,
                            child: Icon(Icons.person),
                          );
                        }
                      }
                    },
                  ),

                  title: FutureBuilder<String?>(
                    future: UserUtility.getUsername(userID),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return const Text('Error retrieving username');
                      } else {
                        final username = snapshot.data ?? '';
                        return Text(
                          username,
                          style: const TextStyle(
                            fontFamily: 'TrebuchetMS',
                            fontWeight: FontWeight.bold,
                            fontSize: 14.0,
                            color: Colors.black,
                          ),
                        );
                      }
                    },
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}