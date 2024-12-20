import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gymbro/Screens/Profile/NutritionTracking/nutrition_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gymbro/Screens/Profile/edit_bio_page.dart';
import 'package:gymbro/Screens/Profile/GoalsTracking/progress_container.dart';
import 'package:gymbro/Widgets/post_utility.dart';
import 'package:gymbro/Settings/settings.dart';


import '../Notifications/notifications_screen.dart';
import 'detailed_post_page.dart';

enum Tab {
  Posts,
  Goals,
}

void main() {
  runApp(ProfilePage());
}

class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Stream<DocumentSnapshot> _userDataStream = const Stream.empty();
  String username = ""; // Define the username as a class member
  List<String> posts = []; // List to store the post image URLs
  String profileUrl = "";
  Tab selectedTab = Tab.Posts; // Track the selected tab


  Future<void> _uploadImage() async {
    final user = FirebaseAuth.instance.currentUser;
    final userID = user?.uid ?? '';
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final storageRef =
      FirebaseStorage.instance.ref().child('images/${DateTime.now().millisecondsSinceEpoch}');
      final uploadTask = storageRef.putFile(file);
      final snapshot = await uploadTask.whenComplete(() => null);
      if (snapshot.state == TaskState.success) {
        final imageUrl = await snapshot.ref.getDownloadURL();
        setState(() {
          profileUrl = imageUrl.toString();
          FirebaseFirestore.instance.collection('users').doc(userID).update({'imageurl': profileUrl});
        });
        // TODO: Save the updated posts list to Firestore
      } else {
        // Handle the upload failure
        print('Image upload failed');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _getUserData();
  }


  Future<void> _getUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    final userID = user?.uid ?? '';
    final snapshot = await FirebaseFirestore.instance.collection("users").doc(userID).get();

    final querySnapshot = await FirebaseFirestore.instance.collection("posts").where("author", isEqualTo: userID).get();

    for (var docSnapshot in querySnapshot.docs) {
      final imageUrl = docSnapshot.data()["imageUrl"] as String?;
      if (imageUrl != null) {
        posts.add(imageUrl);
      }
    }

    if (snapshot.exists) {
      setState(() {
        _userDataStream = snapshot.reference.snapshots();
        username = snapshot.data()?["username"] as String? ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (selectedTab == Tab.Posts) {
      content = Expanded(
        child: GridView.builder(
          padding: const EdgeInsets.only(top: 16.0),
          itemCount: posts.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
          ),
          itemBuilder: (context, index) {
            final postImageUrl = posts[index]; // Access the imageUrl from the posts list
            return FutureBuilder<String?>(
              future: PostUtility.getPostIdFromImageUrl(postImageUrl),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  final postId = snapshot.data!; // Access the postId from snapshot.data
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailedPostPage(postID: postId),
                        ),
                      );
                    },
                    child: Image.network(
                      postImageUrl,
                      fit: BoxFit.cover,
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return const CircularProgressIndicator();
                }
              },
            );
          },
        ),
      );
    } else {
      content = Expanded(
        child: ProgressContainer(),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[600],
      appBar: AppBar(
        backgroundColor: const Color(0xFFDEBB00),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              flex: 4,
              child: Text(
                username,
                style: const TextStyle(
                  fontFamily: 'TrebuchetMS',
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        // automaticallyImplyLeading: false, // Hide the back button
        actions: [
          IconButton(
            icon:  const Icon(Icons.settings),
            onPressed: () {
              // Handle the button press
              // Navigate to the notifications page or perform any other action
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MySettings()),
              );
            },
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        color: Colors.grey[600],
        child: StreamBuilder<DocumentSnapshot>(
          stream: _userDataStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final data = snapshot.data!.data() as Map<String, dynamic>; // Explicitly cast data to Map<String, dynamic>
              String bio = data["bio"] as String;
              List<dynamic> connects = (data["connects"]) as List<dynamic>;
              String connections = "0";
              if (bio.isEmpty) {
                bio = "please edit your bio";
              }
              if (connects.isEmpty) {
                connections = "0";
              } else {
                connections = (connects.length).toString();
              }
              final String imageurl = data["imageurl"] as String;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        username,
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      GestureDetector(
                        onTap: _uploadImage,
                        child: CircleAvatar(
                          radius: 30.0,
                          backgroundImage: profileUrl == ""
                              ? NetworkImage(imageurl)
                              : NetworkImage(profileUrl),
                          child: IconButton(
                            onPressed: () {
                              _uploadImage();
                            },
                            icon: const Icon(Icons.add),
                          ),
                        ),
                      )
                    ],
                  ),
                  Text(
                    bio,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.normal,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        connections,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      const Text(
                        "Connections",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16.0, height: 10.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditBioPage(),
                            ),
                          ).then((value) {
                            if (value != null && value.isNotEmpty) {
                              setState(() {
                                bio = value;
                              });
                            }
                          });
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit Bio'),
                      ),
                      const SizedBox(width: 20.0),
                    ],
                  ),

                  const Divider(color: Colors.white),
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              selectedTab = Tab.Posts; // Update the selectedTab
                            });
                          },
                          style: ButtonStyle(
                            backgroundColor:
                            MaterialStateProperty.all<Color>(const Color(0xFFDEBB00)),
                          ),
                          icon: const Icon(Icons.image),
                          label: const Text('Posts'),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              selectedTab = Tab.Goals; // Update the selectedTab
                            });
                          },
                          style: ButtonStyle(
                            backgroundColor:
                            MaterialStateProperty.all<Color>(const Color(0xFFDEBB00)),
                          ),
                          icon: const Icon(Icons.fitness_center_outlined),
                          label: const Text('Goals'),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => NutritionPage()),
                              );
                            });
                          },
                          style: ButtonStyle(
                            backgroundColor:
                            MaterialStateProperty.all<Color>(const Color(0xFFDEBB00)),
                          ),
                          icon: const Icon(Icons.fastfood_sharp),
                          label: const Text('Nutrition'),
                        ),
                      ],
                    ),

                  ),
                  const Divider(color: Colors.white),
                  content, // Render the appropriate content based on the selectedTab
                ],
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}
