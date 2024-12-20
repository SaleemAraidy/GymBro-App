import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


// AuthProvider class encapsulates the logic for signing up, signing in, and
// handling authentication state changes.
// It keeps track of the current authentication status (_status) and
// the current user (_user).
// It also provides methods like signUp and signIn for performing the
// corresponding authentication operations using the
// Firebase authentication API.

// An enumeration that defines the different possible states of authentication
// that the app can have.
enum Status { Uninitialized, Authenticated, Unauthenticated, Authenticating }

class AuthProvider extends ChangeNotifier {
  late FirebaseAuth _auth;
  late User _user;
  Status _status = Status.Uninitialized;

  AuthProvider() {
    _auth = FirebaseAuth.instance;
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Status get status => _status;
  User get user => _user;


  Future<UserCredential?> signUp(String email, String password) async {
    try {
      _status = Status.Authenticating;
      notifyListeners();

      final result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      _user = result.user!;
      await saveUser(email, _user.uid);
      _status = Status.Authenticated;
      notifyListeners();

      return result;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }

      _status = Status.Unauthenticated;
      notifyListeners();
    } catch (e) {
      _status = Status.Unauthenticated;
      notifyListeners();
    }

    return null;
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _status = Status.Authenticating;
      notifyListeners();

      await _auth.signInWithEmailAndPassword(email: email, password: password);

      _status = Status.Authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _status = Status.Unauthenticated;
      notifyListeners();
      return false;
    }
  }



  void _onAuthStateChanged(User? user) {
    if (user == null) {
      _status = Status.Unauthenticated;
    } else {
      _user = user;
      _status = Status.Authenticated;
    }
    notifyListeners();
  }

  Future<void> saveUser(String email, String uid) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'bio': '',
      'connections': [],
      'createdAt': FieldValue.serverTimestamp(),
      'email': email,
      'posts': [],
      'username': '',
    });
  }
}
