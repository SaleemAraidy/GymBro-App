import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';


// Screen to choose photos and add a new feed post
class NewPostScreen extends StatefulWidget {
  // Create a NewPostScreen
  const NewPostScreen({Key? key}) : super(key: key);

  // // Material route to this screen
  // static Route get route =>
  //     MaterialPageRoute(builder: (_) => const NewPostScreen());

  @override
  _NewPostScreenState createState() => _NewPostScreenState();
}


class _NewPostScreenState extends State<NewPostScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  late File _pickedImage;
  bool _isImageSelected = false;
  String _caption = '';
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final pickedImage = await _imagePicker.pickImage(source: ImageSource.gallery);
    print(pickedImage);
    if (pickedImage != null) {
      setState(() {
        _pickedImage = File(pickedImage.path);
        _isImageSelected = true;
      });
    }
  }

  // Method for uploading a selected image to Firebase Storage and retrieving
  // its download URL
  Future<void> _uploadPost() async {
    if (_isImageSelected || _caption.isNotEmpty) {
      try {
        // Show a circular progress indicator while uploading
        setState(() {
          _isUploading = true;
          const CircularProgressIndicator();
        });

        // Delay the execution for 2 seconds
        await Future.delayed(Duration(seconds: 2));

        // Retrieve the current userID
        final user = FirebaseAuth.instance.currentUser;
        // Use an empty string as a default value if user is null
        final userID = user?.uid ?? '';

        // Create a post document
        final post = <String, dynamic>{
          "author": userID,
          "caption": _caption,
          "likes": [],
          "comments": [],
          "createdAt": FieldValue.serverTimestamp(),
        };

        if (_isImageSelected) {
          // If an image is selected, create a Firebase Storage reference
          // with a unique path based on the current timestamp
          final firebaseStorageRef = FirebaseStorage.instance
              .ref()
              .child('posts')
              .child(DateTime.now().toString());

          // Upload the selected image to Firebase Storage
          final uploadTask = firebaseStorageRef.putFile(_pickedImage);
          print(uploadTask);

          // Wait for the upload task to complete
          final snapshot = await uploadTask.whenComplete(() {});
          print(snapshot);

          // Retrieve the download URL of the uploaded image
          // This URL represents the location of the uploaded image in Firebase Storage
          final downloadUrl = await snapshot.ref.getDownloadURL();
          print(downloadUrl);

          post["imageUrl"] = downloadUrl;
        }

        // Add the post document with an automatically generated document ID
        FirebaseFirestore db = FirebaseFirestore.instance;
        DocumentReference postRef = db.collection('posts').doc();
        await postRef.set(post);

        // Show a scaffold message to indicate successful upload
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post uploaded successfully!'),
          ),
        );

        // Close the current screen and return to the previous screen
        Navigator.pop(context);
      } catch (error) {
        // Show a scaffold message to indicate error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error uploading the post.'),
          ),
        );
      } finally {
        // Hide the circular progress indicator
        setState(() {
          _isUploading = false;
        });
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Post'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_isImageSelected)
              Expanded(
                child: Image.file(
                  _pickedImage,
                  fit: BoxFit.cover,
                ),
              )
            else
              const Expanded(
                child: Center(
                  child: Text(
                    'No image selected',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'TrebuchetMS',
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor:
                MaterialStateProperty.all<Color>(const Color(0xFFDEBB00)),
              ),
              onPressed: _pickImage,
              child: const Text(
                  'Select Image',
                  style: TextStyle(fontFamily: 'TrebuchetMS'),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Caption',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _caption = value;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor:
                MaterialStateProperty.all<Color>(const Color(0xFFDEBB00)),
              ),
              onPressed: () async {
                await _uploadPost();
              },
              child: const Text(
                  'Upload Post',
                  style: TextStyle(fontFamily: 'TrebuchetMS'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}