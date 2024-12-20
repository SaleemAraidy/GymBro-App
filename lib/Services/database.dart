import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {

  final String uid;
  DatabaseService({required this.uid});
  //collection reference
  final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');

  //Method for updatinG a user's email and username when registering
  Future updateUserData({required String email,required String username}) async {
    return await usersCollection.doc(uid).set({
      'username': username,
      'email': email,
      'bio':'',
      'connects':[],
      'createdAt': FieldValue.serverTimestamp(),
      'imageurl':'',
    });

  }

  //Method that checks if a user with 'username' already exists
  Future<bool> checkIfUsernameExists(String username) async {
    final querySnapshot =
    await usersCollection.where('username', isEqualTo: username).get();
    return querySnapshot.docs.isNotEmpty;
  }

  Future<bool> changeUsername(String newUsername) async {
    await usersCollection.doc(uid).update({'username': newUsername});
    return true;
    // Username updated successfully
  }


}