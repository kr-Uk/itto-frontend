import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/chat_models.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Stream<List<ChatRoom>> getChatRoomsStream(
    int userId,
    Map<String, String> chatRoomIdToName,
  ) {
    return _firestore
        .collection('chatRooms')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final chatRooms = <ChatRoom>[];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final participants = (data['participants'] as List<dynamic>?)
                ?.map((e) => e as int)
                .toList() ??
            [];

        final names = <int, String>{};
        for (final participantId in participants) {
          if (chatRoomIdToName.containsKey(doc.id)) {
            names[participantId] = chatRoomIdToName[doc.id]!;
          } else {
            names[participantId] = '알 수 없음';
          }
        }

        final unreadCount = await _getUnreadCount(doc.id, userId);

        final chatRoom = ChatRoom(
          id: doc.id,
          participantIds: participants,
          participantNames: names,
          lastMessage: data['lastMessage'] as String?,
          lastMessageAt: (data['lastMessageAt'] as Timestamp?)?.toDate(),
          unreadCount: unreadCount,
        );

        chatRooms.add(chatRoom);
      }

      return chatRooms;
    });
  }

  Future<int> _getUnreadCount(String chatRoomId, int userId) async {
    final snapshot = await _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .where('senderId', isNotEqualTo: userId)
        .get();

    int count = 0;
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final readBy =
          (data['readBy'] as List<dynamic>?)?.map((e) => e as int).toList() ??
              [];
      if (!readBy.contains(userId)) {
        count++;
      }
    }
    return count;
  }

  Stream<List<ChatMessage>> getMessagesStream(String chatRoomId) {
    return _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ChatMessage.fromFirestore(doc)).toList();
    });
  }

  Future<void> sendMessage({
    required String chatRoomId,
    required int senderId,
    required String text,
    String type = 'text',
  }) async {
    final now = DateTime.now();
    final messageRef = _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .doc();

    final message = ChatMessage(
      id: messageRef.id,
      senderId: senderId,
      text: text,
      type: type,
      createdAt: now,
      readBy: [senderId],
    );

    final batch = _firestore.batch();

    batch.set(messageRef, message.toFirestore());

    batch.set(
      _firestore.collection('chatRooms').doc(chatRoomId),
      {
        'lastMessage': text,
        'lastMessageAt': Timestamp.fromDate(now),
      },
      SetOptions(merge: true),
    );

    await batch.commit();
  }

  Future<void> markAsRead(String chatRoomId, int userId) async {
    final snapshot = await _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .where('senderId', isNotEqualTo: userId)
        .get();

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final readBy =
          (data['readBy'] as List<dynamic>?)?.map((e) => e as int).toList() ??
              [];
      if (!readBy.contains(userId)) {
        batch.update(doc.reference, {
          'readBy': FieldValue.arrayUnion([userId]),
        });
      }
    }

    await batch.commit();
  }

  Future<String> uploadImage({
    required String chatRoomId,
    required String filePath,
  }) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${filePath.split('/').last}';
    final ref = _storage.ref().child('chat_images/$chatRoomId/$fileName');
    await ref.putFile(File(filePath));
    return await ref.getDownloadURL();
  }

  Future<void> ensureChatRoomExists({
    required String chatRoomId,
    required List<int> participantIds,
  }) async {
    final chatRoomRef = _firestore.collection('chatRooms').doc(chatRoomId);
    final doc = await chatRoomRef.get();

    if (!doc.exists) {
      await chatRoomRef.set({
        'participants': participantIds,
        'lastMessage': null,
        'lastMessageAt': null,
        'createdAt': Timestamp.fromDate(DateTime.now()),
      });
    }
  }
}
