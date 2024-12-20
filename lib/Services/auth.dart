import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gymbro/Services/database.dart';

//enum Status { Authenticating, Authenticated, Unauthenticated }

class AuthService{

  final FirebaseAuth _auth = FirebaseAuth.instance;
  //User? _user;
  //Status? _status;

  //auth change user stream
  Stream<User?> get user{
    return _auth.authStateChanges();
  }

  User? get currentUser => _auth.currentUser;




  //Function that checks if a user with 'username' already exists
  Future<bool> checkIfUsernameExists(String username) async {
    final CollectionReference usersRef = FirebaseFirestore.instance.collection('users');
    final querySnapshot = await usersRef.where('username', isEqualTo: username).get();
    return querySnapshot.docs.isNotEmpty;
  }




  //sign in anon
  Future signinanon() async {
    try{
      UserCredential userCredential = await _auth.signInAnonymously();
      User? user = userCredential.user;
      return user;
    }catch(e){
      print(e.toString());
      return null;
    }
  }

  //Log in with email and password

  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // User account Sign in successful
      return userCredential.user;
    }
    catch (e) {
      print('Error signing in user: $e');
      if (e is FirebaseAuthException) {
        FirebaseAuthException authException = e;
        if (authException.code == 'wrong-password' || authException.code == 'user-not-found' || authException.code == 'invalid-email') {
          return 'Invalid credentials';
        } else {
          return 'An error occurred, couldn\'t log in';
        }
      } else {
        return 'An error occurred, couldn\'t log in';
      }
    }
  }


  //Register with email and password
  Future registerWithEmailAndPassword(String email, String password,String username) async {
    try {
      bool usernameExists = await checkIfUsernameExists(username);
      if (usernameExists) {
        // Username already exists
        return 'Username already in use';
      }

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print("Start creating an user document");
      User? user = userCredential.user;
      await DatabaseService(uid: user!.uid).updateUserData(email: email, username: username);
      print("Create an user document");

      // User account creation successful
      return userCredential.user;
    } catch (e) {
      // Error occurred during user account creation
      print('Error creating user: $e');
      if (e is FirebaseAuthException) {
        FirebaseAuthException authException = e;
        if (authException.code == 'email-already-in-use') {
          return 'Email already in use';
        } else {
          return 'An error occurred, couldn\'t sign up';
        }
      } else {
        return 'An error occurred, couldn\'t sign up';
      }
    }
  }


  //Reset password via link
  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
      // Password reset email sent successfully
    } catch (e) {
      // Error occurred while sending password reset email
      print('Error resetting password: $e');
      return false;
    }
  }




  //Sign out
  Future signOut() async {
    try{
      return await _auth.signOut();
    } catch(e){
      print("Error Signing out");
      print(e.toString());
      return null;
    }
  }

}