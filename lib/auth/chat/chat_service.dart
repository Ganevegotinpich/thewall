import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String get currentUserId => _firebaseAuth.currentUser!.uid;

  Future<void> sendMessage(String receiverId, String message) async {
    final currentUserEmail = _firebaseAuth.currentUser!.email!;
    final timestamp = Timestamp.now();

    final newMessage = {
      'senderId': currentUserId,
      'senderEmail': currentUserEmail,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp,
    };

    final chatRoomId = _generateChatRoomId(currentUserId, receiverId);

    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage);
  }

  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    final chatRoomId = _generateChatRoomId(userId, otherUserId);

    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  String _generateChatRoomId(String userId, String otherUserId) {
    final ids = [userId, otherUserId]..sort();
    return ids.join('_');
  }
}
