import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  final String userID;

  ChatPage({required this.userID});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Chats',
            style: TextStyle(
              fontFamily: 'KaushanScript',
              color: Color(0xFF000000),
              fontSize: 35,
            ),
        ),
        backgroundColor: const Color(0xFFDEBB00), // Set the AppBar background color to yellow
      ),
      backgroundColor: Colors.grey[600], // Set the background color of the Scaffold to grey[600]
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userID)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          final user = snapshot.data?.data() as Map<String, dynamic>;
          final connects = user['connects'] as List<dynamic>;

          if (connects.isEmpty) {
            return Text('No chats found.');
          }

          return ListView.builder(
            itemCount: connects.length,
            itemBuilder: (context, index) {
              final connectedUserId = connects[index] as String;

              return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(connectedUserId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Icon(Icons.person); // Show a default icon if there's an error
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }

                  final connectedUser = snapshot.data?.data() as Map<String, dynamic>;
                  final profileImageUrl = connectedUser['imageurl'];
                  final username = connectedUser['username'];

                  return ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            currentUserId: userID,
                            selectedUserId: connectedUserId,
                            selectedUserName: username,
                          ),
                        ),
                      );
                    },
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(profileImageUrl ?? ''),
                    ),
                    title: Text(username ?? 'Unknown User'),
                    trailing: Icon(Icons.arrow_forward_ios),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String currentUserId;
  final String selectedUserId;
  final String selectedUserName;

  ChatScreen({
    required this.currentUserId,
    required this.selectedUserId,
    required this.selectedUserName,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF000000),
        title: Text(
          widget.selectedUserName,
          style: const TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: Container(
        color: Colors.grey[600],
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('messages')
                    .where('conversationId', isEqualTo: _generateConversationId())
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text('No messages yet.'),
                    );
                  }

                  final messages = snapshot.data!.docs;
                  return ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final content = message['content'];
                      final senderId = message['senderId'];

                      final isCurrentUser = senderId == widget.currentUserId;
                      final backgroundColor = isCurrentUser ? const Color(0xFF000000) : Colors.grey[300];
                      final textColor = Colors.black;

                      String senderName = '';
                      if (!isCurrentUser) {
                        senderName = widget.selectedUserName;
                      }

                      return Align(
                        alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 4),
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.7,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isCurrentUser ? 'You' : senderName,
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                content,
                                style: TextStyle(
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    color: Colors.blue,
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _generateConversationId() {
    final participants = [widget.currentUserId, widget.selectedUserId];
    participants.sort();
    return participants.join('_');
  }

  void _sendMessage() async {
    final conversationId = _generateConversationId();
    final messageContent = _messageController.text.trim();
    if (messageContent.isNotEmpty) {
      await FirebaseFirestore.instance.collection('messages').add({
        'content': messageContent,
        'senderId': widget.currentUserId,
        'conversationId': conversationId,
        'timestamp': DateTime.now(),
      });
      _messageController.clear();
    }
  }
}

