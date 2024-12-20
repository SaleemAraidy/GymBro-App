import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'comment_box.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymbro/Services/database.dart';
import 'package:gymbro/Widgets/user_utility.dart';


class CommentScreen extends StatelessWidget {
  final String postID;


  const CommentScreen({
    required this.postID,
  });


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
        const Text(
          'Comments',
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
      body: Column(
        children: [
          Expanded(
            child: CommentList(postID: postID),
          ),
          const Divider(),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: CommentBox(
                textEditingController: TextEditingController(),
                focusNode: FocusNode(),
                onSubmitted: (comment) {
                  // Implement the logic to submit the comment

                  saveComment(postID, comment!);

                  print('Submitted comment: $comment');
                },
              ),
          ),
        ]
      ),
    );
  }


  void saveComment(String postID, String commentContent) {
    FirebaseFirestore.instance
        .collection('posts')
        .doc(postID)
        .get()
        .then((postSnapshot) {
      if (postSnapshot.exists) {
        final user = FirebaseAuth.instance.currentUser;
        final userId = user?.uid ?? '';

        final comment = Comment(
          author: userId,
          content: commentContent,
          createdAt: Timestamp.now()
        );

        FirebaseFirestore.instance
            .collection('posts')
            .doc(postID)
            .collection('comments')
            .add({
          'author' : comment.author,
          'content': commentContent,
          'createdAt' : comment.createdAt,
        })
            .then((value) => print('Comment added successfully'))
            .catchError((error) => print('Failed to add comment: $error'));
      }
    });
  }
}


class CommentList extends StatelessWidget {
  final String postID;
  const CommentList({
    Key? key,
    required this.postID,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    // Replace this with your backend logic to fetch comments
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .doc(postID)
          .collection('comments')
          .orderBy('createdAt')
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          final comments = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Comment(
              author: data['author'] as String,
              content: data['content'] as String,
              createdAt: data['createdAt'] as Timestamp,
            );
          }).toList();

          return ListView.builder(
            itemCount: comments.length,
            itemBuilder: (context, index) {
              final comment = comments[index];
              return FutureBuilder<String?>(
                future: UserUtility.getUsername(comment.author),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    final userName = snapshot.data!;

                    return ListTile(
                      leading: FutureBuilder<String?>(
                        future: UserUtility.getUserProfileImage(comment.author),
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
                      title: Text(userName),
                      subtitle: Text(comment.content),
                    );
                  } else {
                    // Handle the case when the username is not available
                    return ListTile(
                      leading: const CircleAvatar(
                        radius: 16.0,
                        backgroundColor: Colors.grey,
                      ),
                      title: const Text('Unknown'),
                      subtitle: Text(comment.content),
                    );
                  }
                },
              );
            },
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}

class Comment {
  final String author;
  final String content;
  late final Timestamp createdAt;

  Comment({
    required this.author,
    required this.content,
    required this.createdAt
  });


}