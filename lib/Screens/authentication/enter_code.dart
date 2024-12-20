import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:gymbro/Screens/authentication/reset_password.dart';

class EnterCode extends StatefulWidget {
  //const EnterCode({Key? key}) : super(key: key);
  final String email;
  final String confirmationCode;
  EnterCode({required this.email, required this.confirmationCode});

  @override
  State<EnterCode> createState() => _EnterCodeState();
}

class _EnterCode {
}

class _EnterCodeState extends State<EnterCode> {

  TextEditingController codeController = TextEditingController();

  //Send Confirmation Code Function
  Future<bool> sendEmail({
    required String email,
    required String code,
  }) async {
    final serviceId ='service_yv7yoc1';
    final templateId ='template_i1cm1xv';
    final userId ='P5avjZR0WGd8napVJ';


    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
    final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'service_id': serviceId,
          'template_id': templateId,
          'user_id': userId,
          'template_params':{
            'user_email': email,
            'user_message': code,
          }
        })
    );

    if (response.statusCode == 200) {
      // Operation succeeded
      print(code);
      print('Post request succeeded');
      print('Response body: ${response.body}');
      return true;
    } else {
      // Operation failed
      print('Post request failed with status: ${response.statusCode}');
      return false;
    }
  }





  //Function for code match validation
  bool verifyCode(BuildContext context) {
    // Retrieve the entered code
    String enteredCode = codeController.text;

    if (enteredCode == widget.confirmationCode) {
      // Navigate to ResetPass() page if the code matches
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ResetPass(email: widget.email)),
      );
      return true;
    } else {
      // Show a SnackBar for an incorrect code
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid confirmation code'),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
      return false;
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 70),
              Icon(Icons.lock,
                size: 80,
                color: Colors.white,),
              SizedBox(height: 30),
              Row(
                children: [

                  Text("Didn't recieve a code ?",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 17
                    ),
                  ),
                  SizedBox(width: 5,),
                  GestureDetector(

                    onTap: () {
                      // Handle the clickable text action here
                      print('Resending code');
                    },
                    child: Text(
                      ' resend code',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.white,
                        fontSize: 17,
                      ),
                    ),
                  ),




                ],
              ),
              SizedBox(height: 30),
              TextFormField(
                controller: codeController,
                decoration: InputDecoration(
                  hintText: 'Enter the code that was sent to your email',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                  hintStyle: TextStyle(fontSize: 12.0),
                  // Adjust the hintStyle fontSize to your preference
                ),
                onChanged: (val) {
                  setState(() {

                  });
                },
              ),
              SizedBox(height: 20),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.amber, // Set the button color to amber
                  ),
                  onPressed: () async {
                    verifyCode(context);
                  },
                  child: Text('Confirm Code',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18
                      )
                  ),
                ),
              ),
              SizedBox(height: 30),

              GestureDetector(

                onTap: () {
                  // Handle the clickable text action here
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  print('Back to sign in.');
                },
                child: Text(
                  'Back to sign in.',
                  style: TextStyle(
                    fontSize: 17,
                    decoration: TextDecoration.underline,
                    color: Colors.white,
                  ),
                ),
              )

            ],
          ),
        ),
      ),
    );
  }
}
