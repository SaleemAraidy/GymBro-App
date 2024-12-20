import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

class UserUtility {
  static Future<String?> getUserIDFromName(String username) async {
    // Query the users collection for the user with the specified username
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Get the first document from the query results
      DocumentSnapshot userSnapshot = querySnapshot.docs[0];

      // Access the 'userID' field value from the document
      String userID = userSnapshot.id;
      return userID;
    }
    return null;
  }


  static Future<String?> getUsername(String userID) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userID)
          .get();

      if (userDoc.exists) {
        final username = userDoc.data()?['username'] as String?;
        return username;
      } else {
        return null; // User document does not exist
      }
    } catch (error) {
      print('Failed to retrieve username: $error');
      return null;
    }
  }

  static Stream<String?> getUsernameStream(String userID) {
    final controller = StreamController<String?>();

    FirebaseFirestore.instance
        .collection('users')
        .doc(userID)
        .snapshots()
        .listen((doc) {
      if (doc.exists) {
        final username = doc.data()?['username'] as String?;
        controller.add(username);
      } else {
        controller.add(null); // User document does not exist
      }
    }, onError: (error) {
      print('Failed to retrieve username: $error');
      controller.addError(error);
    });

    return controller.stream;
  }

  static Future<String?> getUserProfileImage(String userID) async{
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userID)
          .get();

      if (userDoc.exists) {
        final profileImageUrl = userDoc.data()?['imageurl'] as String?;
        return profileImageUrl;
      } else {
        return null; // User document does not exist
      }
    } catch (error) {
      print('Failed to retrieve username: $error');
      return null;
    }
  }

  static Stream<List<String>> fetchLikedUsers(String postID) {
    return FirebaseFirestore.instance
        .collection('posts')
        .doc(postID)
        .snapshots()
        .map((DocumentSnapshot snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        if (data != null && data.containsKey('likes')) {
          final likes = data['likes'];
          if (likes is List) {
            return likes.cast<String>().toList();
          }
        }
      }
      return []; // Return an empty list if likes data is not found or in the wrong format
    });
  }

  static Future<String?> getUserProfileImageFromPostID(String postID) async{
    try {
      final postDoc = await FirebaseFirestore.instance
          .collection('posts')
          .doc(postID)
          .get();

      if (postDoc.exists) {
        final userID = postDoc.data()?['author'] as String?;

        if (userID != null) {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(userID)
              .get();
          if (userDoc.exists) {
            final profileImageUrl = userDoc.data()?['imageurl'] as String?;
            return profileImageUrl;
          }
        }

      } else {
        return null; // User or post document does not exist
      }
    } catch (error) {
      print('Failed to retrieve username: $error');
      return null;
    }
    return null;
  }
}

