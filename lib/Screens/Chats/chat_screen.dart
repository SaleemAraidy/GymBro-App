import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
        backgroundColor: Color(0xFFDEBB00),
        title: Text(
          widget.selectedUserName,
          style: TextStyle(
            fontFamily: 'KaushanScript',
            fontSize: 24,
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
                      final backgroundColor = isCurrentUser ? Color(0xFFDEBB00) : Colors.grey[800];
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
