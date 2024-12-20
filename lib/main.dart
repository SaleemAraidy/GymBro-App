import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gymbro/Screens/wrapper.dart';
import 'package:provider/provider.dart';



void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App());
}



class App extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
              body: Center(
                  child: Text(snapshot.error.toString(),
                      textDirection: TextDirection.ltr)));
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return const MyApp();
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // TRY THIS: Try running your application with "flutter run". You'll see
          // the application has a blue toolbar. Then, without quitting the app,
          // try changing the seedColor in the colorScheme below to Colors.green
          // and then invoke "hot reload" (save your changes or press the "hot
          // reload" button in a Flutter-supported IDE, or press "r" if you used
          // the command line to start the app).
          //
          // Notice that the counter didn't reset back to zero; the application
          // state is not lost during the reload. To reset the state, use hot
          // restart instead.
          //
          // This works for code too, not just values: Most code changes can be
          // tested with just a hot reload.
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home:  Wrapper()
    );
  }
}















// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'home_screen.dart';
// import 'state/app_state.dart';
// import 'Screens/authentication/sign_up.dart';
//
// // void main() async {
// //   WidgetsFlutterBinding.ensureInitialized();
// //   await Firebase.initializeApp();
// //   runApp(
// //     FutureBuilder(
// //       future: Firebase.initializeApp(),
// //       builder: (context, snapshot) {
// //         if (snapshot.connectionState == ConnectionState.done) {
// //           return const MyApp();
// //         }
// //         if (snapshot.hasError) {
// //           // Handle the error
// //         }
// //         // Show a loading spinner while waiting for Firebase initialization to complete
// //         return const CircularProgressIndicator();
// //       },
// //     ),
// //   );
// // }
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider<AuthProvider>(
//           create: (_) => AuthProvider(),
//         ),
//       ],
//       child: MaterialApp(
//         title: 'Flutter Demo',
//         theme: ThemeData(
//           appBarTheme: const AppBarTheme(
//             backgroundColor: Color(0xFF727372),
//             foregroundColor: Color(0xFF727372),
//           ),
//         ),
//         home: const GymBroLoginPage(),
//       ),
//     );
//   }
// }
//
// class GymBroLoginPage extends StatefulWidget {
//   const GymBroLoginPage({Key? key}) : super(key: key);
//
//   // This widget is the home page of your application. It is stateful, meaning
//   // that it has a State object (defined below) that contains fields that affect
//   // how it looks
//
//   // This class is the configuration for the state. It holds the values (in this
//   // case the title) provided by the parent (in this case the App widget) and
//   // used by the build method of the State. Fields in a Widget subclass are
//   // always marked "final".
//
//   @override
//   State<GymBroLoginPage> createState() => _GymBroLoginPageState();
//
// }
//
// class _GymBroLoginPageState extends State<GymBroLoginPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _isLoading = false;
//
//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: false, // Prevents resizing when the keyboard appears
//       body: GestureDetector(
//         onTap: () {
//           // Dismiss the keyboard when tapping outside the text fields
//           FocusScope.of(context).unfocus();
//         },
//         child: SingleChildScrollView(
//           child: Container(
//             padding: const EdgeInsets.all(20.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: <Widget>[
//                 const SizedBox(height: 80.0),
//                 const Text(
//                   'GymBro',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontFamily: 'KaushanScript',
//                     color: Color(0xFFDEBB00),
//                     fontSize: 80,
//                   ),
//                 ),
//                 const SizedBox(height: 20.0),
//                 Image.asset(
//                   'assets/images/gymbro_logo.png',
//                   height: 100.0,
//                 ),
//                 const SizedBox(height: 20.0),
//                 Form(
//                   key: _formKey,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.stretch,
//                     children: <Widget>[
//                       TextFormField(
//                         controller: _emailController,
//                         decoration: InputDecoration(
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(31.0),
//                           ),
//                           labelText: 'Email or username',
//                         ),
//                       ),
//                       const SizedBox(height: 20.0),
//                       TextFormField(
//                         controller: _passwordController,
//                         decoration: InputDecoration(
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(31.0),
//                           ),
//                           labelText: 'Password',
//                         ),
//                         obscureText: true,
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter your password';
//                           }
//                           return null;
//                         },
//                       ),
//                       const SizedBox(height: 20.0),
//                       ElevatedButton(
//                         style: ButtonStyle(
//                           shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//                             RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(31.0),
//                             ),
//                           ),
//                           backgroundColor:
//                           MaterialStateProperty.all<Color>(const Color(0xFFDEBB00)),
//                         ),
//                         onPressed: ()  async{
//
//                           if (_formKey.currentState!.validate()) {
//                             setState(() {
//                               _isLoading = true;
//                             });
//                             try {
//                               final authProvider =
//                               Provider.of<AuthProvider>(context, listen: false);
//                               final String email = _emailController.text.trim();
//                               final String password = _passwordController.text.trim();
//
//                               await authProvider.signIn(email, password);
//                               // await FirebaseAuth.instance
//                               //     .signInWithEmailAndPassword(
//                               //         email: email,
//                               //         password: password)
//                               //     .then((value) {
//                               //   Navigator.of(context).pushReplacement(
//                               //     MaterialPageRoute(builder: (_) => const HomeScreen()),
//                               //   );
//                               // });
//
//                               if (mounted) { // Add this check
//                                 Navigator.of(context).pushReplacement(
//                                   MaterialPageRoute(builder: (_) => const HomeScreen()),
//                                 );
//                               }
//
//                             } on FirebaseAuthException catch (e) {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 SnackBar(
//                                   key: const Key('login-error-snackbar'),
//                                   content: Text(
//                                     'There was an error logging into the app: ${e.message}',
//                                   ),
//                                 ),
//                               );
//                             } finally {
//                               if (mounted) { // Add this check
//                                 setState(() {
//                                   _isLoading = false;
//                                 });
//                               }
//                             }
//                           }
//                         },
//                         child: const Text(
//                           'Log In',
//                           style: TextStyle(
//                             fontFamily: 'KaushanScript',
//                             color: Color(0xFF000000),
//                             fontSize: 20,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 10.0),
//                       TextButton(
//                         child: const Text(
//                           'Forgot password?',
//                           style: TextStyle(
//                             fontFamily: 'TrebuchetMS',
//                           ),
//                         ),
//                         onPressed: () {
//                           // Add forgot password logic here
//                         },
//                       ),
//                       const SizedBox(height: 10.0),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: <Widget>[
//                           const Text(
//                             'Don\'t have an account?',
//                             style: TextStyle(
//                               fontFamily: 'TrebuchetMS',
//                               fontSize: 16.0,
//                             ),
//                           ),
//                           TextButton(
//                             child: const Text(
//                               'Sign Up',
//                               style: TextStyle(
//                                 fontFamily: 'TrebuchetMS',
//                                 fontSize: 16.0,
//                               ),
//                             ),
//                             onPressed: () {
//                               Navigator.of(context).pushReplacement(
//                                 MaterialPageRoute(builder: (_) => const SignUp()),
//                               );
//                               // if (_formKey.currentState!.validate()) {
//                               //   setState(() {
//                               //     _isLoading = true;
//                               //   });
//                               //   final String email = _emailController.text.trim();
//                               //   final String password = _passwordController.text.trim();
//                               //   try {
//                               //     final authProvider =
//                               //     Provider.of<AuthProvider>(context, listen: false);
//                               //     await authProvider.signUp(email, password);
//                               //     // await FirebaseAuth.instance
//                               //     //         .createUserWithEmailAndPassword(
//                               //     //             email: email, password: password)
//                               //     //         .then((value) {
//                               //     //           print("Create new user");
//                               //     // });
//                               //   } on FirebaseAuthException catch (e) {
//                               //     ScaffoldMessenger.of(context).showSnackBar(
//                               //       SnackBar(
//                               //         content: Text(
//                               //           'There was an error signing up into the app: ${e.message}',
//                               //         ),
//                               //       ),
//                               //     );
//                               //   } finally {
//                               //     setState(() {
//                               //       _isLoading = false;
//                               //     });
//                               //   }
//                               // }
//                             },
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
