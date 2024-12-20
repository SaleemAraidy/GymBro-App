import 'package:cloud_firestore/cloud_firestore.dart';

class PostUtility {
  static Future<String?> getPostIdFromImageUrl(String imageUrl) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .where('imageUrl', isEqualTo: imageUrl)
        .get();

    if (querySnapshot.size > 0) {
      final document = querySnapshot.docs.first;
      return document.id;
    }
    return null;
  }
}
