import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Screens/Comments/comment_screen.dart';
import 'package:gymbro/Screens/Likes/likes_screen.dart';
import 'package:gymbro/Widgets/user_utility.dart';
import 'package:gymbro/Screens/Profile/UserProfilePage.dart';


class PostCard extends StatefulWidget {
  final String username;
  final String imageUrl;
  final String caption;
  final int likesCount;
  final int commentsCount;
  final String postID;

  PostCard({
    required this.username,
    required this.imageUrl,
    required this.caption,
    this.likesCount = 0,
    this.commentsCount = 0,
    required this.postID,
  });

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isLiked = false;
  late String _likedStateKey;
  bool isDisposed = false;

  @override
  void initState() {
    super.initState();
    isLiked = false;
    _likedStateKey = getLikedStateKey(widget.postID);
    initLikedState();
  }

  void initLikedState() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final postSnapshot = await FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.postID)
            .get();
        final likes = List<String>.from(postSnapshot.data()?['likes'] ?? []);
        if (!isDisposed) {
          setState(() {
            isLiked = likes.contains(user.uid);
          });
        }
      }
    } catch (error) {
      print('Failed to retrieve liked state: $error');
    }
  }

  void updateLikedState(bool liked) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // User is not logged in, handle accordingly
        return;
      }

      final postRef = FirebaseFirestore.instance.collection('posts').doc(widget.postID);
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final postSnapshot = await transaction.get(postRef);
        final likes = List<String>.from(postSnapshot.data()?['likes'] ?? []);

        if (liked) {
          // User is liking the post
          likes.add(user.uid);
        } else {
          // User is unliking the post
          likes.remove(user.uid);
        }

        transaction.update(postRef, {'likes': likes});
      });

      setState(() {
        isLiked = liked;
      });
    } catch (error) {
      // Handle error
      print("Failed to update like status: $error");
    }
  }

  String getLikedStateKey(String postID) {
    final user = FirebaseAuth.instance.currentUser;
    final userID = user != null ? user.uid : 'guest';
    return 'liked_state_$userID$postID';
  }

  void handleLikeButtonPress(String postID, bool isLiked) async {
    print('handleLikeButtonPress called with postID: $postID, isLiked: $isLiked');

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // User is not logged in, handle accordingly
        return;
      }

      final postRef = FirebaseFirestore.instance.collection('posts').doc(postID);
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final postSnapshot = await transaction.get(postRef);
        final likes = List<String>.from(postSnapshot.data()!['likes'] ?? []);

        if (isLiked) {
          // User is unliking the post
          likes.remove(user.uid);
        } else {
          // User is liking the post
          likes.add(user.uid);
        }

        transaction.update(postRef, {'likes': likes});
      });

      // Update the liked state in SharedPreferences
      if (mounted) {
        setState(() {
          updateLikedState(!isLiked);
        });
      }

    } catch (error) {
      // Handle error
      print("Failed to update like status: $error");
    }
  }

  Stream<int> getLikesCountStream(String postID) {
    return FirebaseFirestore.instance
        .collection('posts')
        .doc(postID)
        .snapshots()
        .map((snapshot) {
      final data = snapshot.data();
      final likes = List<String>.from(data!['likes'] ?? []);
      return likes.length;
    });
  }

  @override
  void dispose() {
    isDisposed = true;
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.0,
      color: Colors.grey[800],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                FutureBuilder<String?>(
                  future: UserUtility.getUserProfileImageFromPostID(widget.postID),
                  builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
                    if (snapshot.hasData) {
                      final profileImageUrl = snapshot.data!;
                      return CircleAvatar(
                        radius: 16.0,
                        backgroundColor: Colors.grey,
                        backgroundImage: NetworkImage(profileImageUrl),
                      );
                    } else if (snapshot.hasError) {
                      return const CircleAvatar(
                        radius: 16.0,
                        backgroundColor: Colors.grey,
                      );
                    } else {
                      return const CircleAvatar(
                        radius: 16.0,
                        backgroundColor: Colors.grey,
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
                const SizedBox(width: 8.0),
                FutureBuilder<String?>(
                  future: UserUtility.getUserIDFromName(widget.username),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {  // Check if data has been successfully retrieved
                      String? userID = snapshot.data ?? '';
                      return TextButton(
                        onPressed: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => UserProfilePage(userID: userID)),
                          );
                        },
                        child: Text(
                          widget.username,
                          style: const TextStyle(
                            fontFamily: 'TrebuchetMS',
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return const Text('Error retrieving username');
                    } else {
                      return const CircularProgressIndicator();
                    }
                  },
                )
              ],
            ),
          ),
          AspectRatio(
            aspectRatio: 1.0,
            child: Image.network(
              widget.imageUrl,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 0.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        // handleLikeButtonPress(widget.postID, isLiked);
                        setState(() {
                          if (isLiked) {
                            updateLikedState(false);
                          } else {
                            updateLikedState(true);
                          }
                        });

                      },
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) {
                              return CommentScreen(postID: widget.postID);
                            },
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.mode_comment_outlined,
                        size: 24.0,
                        color: Colors.white,
                      ),
                    ),
                    // IconButton(
                    //   onPressed: () {
                    //     // Handle share button press
                    //   },
                    //   icon: const Icon(
                    //     Icons.share,
                    //     size: 24.0,
                    //     color: Colors.white,
                    //   ),
                    // ),
                  ],
                ),
                StreamBuilder<int>(
                  stream: getLikesCountStream(widget.postID),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasData && snapshot.data != 0) {
                      final likesCount = snapshot.data;
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LikesScreen(postID: widget.postID),
                            ),
                          );
                        },
                        child: Text(
                          '$likesCount likes',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      );
                    } else {
                      return Container(); // Return an empty container when there are no likes
                    }
                  },
                ),
                const SizedBox(height: 4.0),
                Row(
                  children: [
                    Text(
                      widget.username,
                      style: const TextStyle(
                        fontFamily: 'TrebuchetMS',
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      ': ${widget.caption}',
                      style: const TextStyle(
                        fontFamily: 'TrebuchetMS',
                        fontSize: 14.0,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4.0),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) {
                          return CommentScreen(postID: widget.postID);
                        },
                      ),
                    );
                  },
                  child: const Text(
                    'View all comments',
                    style: TextStyle(
                      color: Colors.grey,
                      fontFamily: 'TrebuchetMS',
                      fontSize: 12.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}