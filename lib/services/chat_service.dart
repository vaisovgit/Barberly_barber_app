import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/chat_message.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Stream<List<ChatRoom>> getChatRoomsStream(String? barberPhone) {
    return _firestore
        .collection('chatrooms')
        .where('barber_phone', isEqualTo: barberPhone)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ChatRoom.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Stream<List<ChatMessage>> getMessagesStream(String chatRoomId) {
    return _firestore
        .collection('chatrooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ChatMessage.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> sendMessage(
    String chatRoomId,
    String senderId,
    String receiverId,
    String message,
  ) async {
    final chatMessage = ChatMessage(
      id: '',
      senderId: senderId,
      receiverId: receiverId,
      message: message,
      timestamp: DateTime.now(),
      isRead: false,
    );

    await _firestore
        .collection('chatrooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(chatMessage.toMap());

    await _firestore.collection('chatrooms').doc(chatRoomId).update({
      'lastMessage': message,
      'lastMessageTime': DateTime.now().toIso8601String(),
    });
  }

  Future<void> sendImageMessage(
    String chatRoomId,
    String senderId,
    String receiverId,
    File imageFile,
  ) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage.ref().child('chat_images/$chatRoomId/$fileName');
    await ref.putFile(imageFile);
    final imageUrl = await ref.getDownloadURL();

    final chatMessage = ChatMessage(
      id: '',
      senderId: senderId,
      receiverId: receiverId,
      message: '',
      imageUrl: imageUrl,
      timestamp: DateTime.now(),
      isRead: false,
    );

    await _firestore
        .collection('chatrooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(chatMessage.toMap());

    await _firestore.collection('chatrooms').doc(chatRoomId).update({
      'lastMessage': '📷 Image',
      'lastMessageTime': DateTime.now().toIso8601String(),
    });
  }

  Future<void> markAsRead(String chatRoomId, String barberId) async {
    final messages = await _firestore
        .collection('chatrooms')
        .doc(chatRoomId)
        .collection('messages')
        .where('receiverId', isEqualTo: barberId)
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in messages.docs) {
      await doc.reference.update({'isRead': true});
    }

    await _firestore.collection('chatrooms').doc(chatRoomId).update({
      'unreadCount': 0,
    });
  }
}
