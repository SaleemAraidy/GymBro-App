import 'package:flutter/material.dart';
import 'package:gymbro/Screens/authentication/enter_code.dart';
import 'package:gymbro/Screens/authentication/send_confirmation_code.dart';
import 'sign_in.dart';
import 'sign_up.dart';
import 'reset_password.dart';

class Authenticate extends StatefulWidget {
  const Authenticate({Key? key}) : super(key: key);

  @override
  State<Authenticate> createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {

  @override
  Widget build(BuildContext context) {
    return SignUp();
  }
}
