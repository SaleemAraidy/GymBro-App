import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../Widgets/post_card.dart';
import 'package:gymbro/Widgets/user_utility.dart';

class TimelinePage extends StatefulWidget {
  const TimelinePage({Key? key}) : super(key: key);

  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  late List<Map<String, dynamic>> posts;

  @override
  void initState() {
    super.initState();
    posts = []; // Initialize the posts list

    // Retrieve the posts from Firestore
    FirebaseFirestore.instance
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .get()
        .then((querySnapshot) {
      if (!mounted) return; // Check if the widget is still mounted

      for (var doc in querySnapshot.docs) {
        final postID = doc.id;
        Map<String, dynamic> postData = doc.data();
        postData['postID'] = postID;
        posts.add(postData);
      }

      setState(() {}); // Refresh the UI after fetching the posts
    }).catchError((error) {
      print("Error retrieving posts: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          final postID = post['postID'];
          return StreamBuilder<String?>(
            stream: UserUtility.getUsernameStream(post['author']),
            builder: (context, AsyncSnapshot<String?> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return const Text('Error retrieving postcard');
              }
              else {
                final username = snapshot.data ?? '';
                return PostCard(
                  username: username,
                  imageUrl: post['imageUrl'] != null &&
                      post['imageUrl'].isNotEmpty
                      ? post['imageUrl']
                      : 'https://pbs.twimg.com/media/EXRRemvU0AYWu2v.jpg',
                  caption: post['caption'],
                  postID: postID,
                );
              }
            },
          );
        });
  }
}

// // Replace this with actual data from the backend
// final List<Map<String, dynamic>> posts = [
//   {
//     'username': '__dangkhoi__',
//     'imageUrl': 'https://pbs.twimg.com/media/EkOAqpDXkAwicuw.jpg',
//     'caption': 'Beefy Quads!'
//   },
//   {
//     'username': '_khoidepzai',
//     'imageUrl': 'https://cdn05.zipify.com/3Vqefgmic8V-tzk2RcQSrkCtkfc=/fit-in/1080x0/418af4ba858a4e16b9b546686a91d429/greg-ogallagher-products-min.jpg',
//     'caption': 'A shoulder killer!!!'
//   },
// ];

// // Create a Firestore instance
// FirebaseFirestore db = FirebaseFirestore.instance;
//
// // Create a post document
// final post1 = <String, dynamic>{
//   "author" : "xDENgvcCEATclThEx6hq773gu3z1",
//   "imageUrl" : "",
//   "caption" : "Great chest day!",
//   "likes" : [],
//   "comments" : [],
//   "createdAt" : FieldValue.serverTimestamp(),
// };
//
// final post2 = <String, dynamic>{
//   "author" : "M1l9j3VCrhMtlBby5CYtd4YJwAR2",
//   "imageUrl" : "",
//   "caption" : "Beefy Quads!",
//   "likes" : [],
//   "comments" : [],
//   "createdAt" : FieldValue.serverTimestamp(),
// };
//
// // Add the post document to the "posts" collection
// // Add the 2 post documents with an automatically generated document ID
// DocumentReference post1Ref = db.collection('posts').doc();
// post1Ref.set(post1);
//
// DocumentReference post2Ref = db.collection('posts').doc();
// post2Ref.set(post2)