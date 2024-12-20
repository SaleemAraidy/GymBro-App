import 'package:flutter/material.dart';
import 'package:gymbro/Screens/authentication/authenticate_wrapper.dart';

class ResetPass extends StatefulWidget {
  //const ResetPass({Key? key}) : super(key: key);

  final String email;
  ResetPass({required this.email});


  @override
  State<ResetPass> createState() => _ResetPassState();
}

class _ResetPassState extends State<ResetPass> {

  final TextEditingController password = TextEditingController();
  final TextEditingController confirm_password = TextEditingController();



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

              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding :EdgeInsets.only(left: 0.0, top: 16.0),
                  child: ClipOval(
                    child: Material(
                      color: Colors.amber,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            Navigator.of(context).popUntil((route) => route.isFirst);
                          });
                        },
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),


              SizedBox(height: 70),
              Text(
                'Reset Password',
                style: TextStyle(
                    fontSize: 30,
                    color: Colors.white
                ),
              ),
              SizedBox(height: 30),
              TextFormField(
                controller: password,
                decoration: InputDecoration(
                  hintText: 'New Password',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                obscureText: true,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: confirm_password,
                decoration: InputDecoration(
                  hintText: 'Confirm Password',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                obscureText: true,
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
                    //should reset password if password and confirm_password match
                    if(password.text == confirm_password.text){
                      //handle reseting password
                    }

                  },
                  child: Text('Reset',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 25
                      )
                  ),
                ),
              ),

              SizedBox(height: 30,),

              GestureDetector(

                onTap: () {
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
