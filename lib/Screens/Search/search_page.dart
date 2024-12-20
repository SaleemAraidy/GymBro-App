import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymbro/Screens/Profile/UserProfilePage.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Map<String, dynamic>> searchResults = [];

  void searchUsers(String query) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: query)
        .where('username', isLessThan: query + 'z')
        .get();

    setState(() {
      searchResults = snapshot.docs
          .map((doc) => {
        ...doc.data(),
        'userID': doc.id, // Include the user ID in the search results
      })
          .toList()
          .cast<Map<String, dynamic>>();
    });
  }

  void navigateToUserProfile(String userID) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfilePage(userID: userID),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Retrieve initial data on page load
    searchUsers('');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFDEBB00),
        title: Text(
            'Search',
            style: TextStyle(
              fontFamily: 'KaushanScript',
              color: Color(0xFF000000),
              fontSize: 35,
            ),
        ),
      ),
      body: Container(
        color: Colors.grey[600],
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            CupertinoSearchTextField(
              onChanged: (value) {
                searchUsers(value);
              },
              placeholder: 'Search...',
              style: TextStyle(
                color: Colors.black,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final user = searchResults[index];
                  final userID = user['userID']; // Use the user ID from the search results
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(user['imageurl']),
                      ),
                      title: Text(
                        user['username'],
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: ElevatedButton(
                        onPressed: () {
                          navigateToUserProfile(userID);
                        },
                        child: Text('View Profile'),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
