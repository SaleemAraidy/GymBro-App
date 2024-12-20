import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../Widgets/post_card.dart';
import 'package:gymbro/Widgets/user_utility.dart';

class DetailedPostPage extends StatefulWidget {
  final String? postID;
  const DetailedPostPage({
    Key? key,
    required this.postID,
  }) : super(key: key);

  @override
  State<DetailedPostPage> createState() => _DetailedPostPageState();
}

class _DetailedPostPageState extends State<DetailedPostPage> {
  late Map<String, dynamic> post;

  @override
  void initState() {
    super.initState();
    post = {}; // Initialize the post map

    // Retrieve the post from Firestore
    FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postID)
        .get()
        .then((DocumentSnapshot doc) {
      setState(() {
        post = doc.data() as Map<String, dynamic>;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[600],
        appBar: AppBar(
          title:
          const Text(
            'GymBro',
            style: TextStyle(
              fontFamily: 'KaushanScript',
              color: Color(0xFF000000),
              fontSize: 35,
            ),
          ),
          automaticallyImplyLeading: false, // Hide the back button
          elevation: 0,
          centerTitle: false,
          backgroundColor: const Color(0xFFDEBB00),
        ),
        body: FutureBuilder<String?>(
          future: post['author'] != null && post['author'].isNotEmpty
              ? UserUtility.getUsername(post['author']!)
              : Future.value(null), // Return null or a default value if post['author'] is null or empty
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              final username = snapshot.data!;
              return PostCard(
                username: username,
                imageUrl: post['imageUrl'] != null && post['imageUrl'].isNotEmpty
                    ? post['imageUrl']
                    : 'https://pbs.twimg.com/media/EXRRemvU0AYWu2v.jpg',
                caption: post['caption'],
                postID: widget.postID ?? '',
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
