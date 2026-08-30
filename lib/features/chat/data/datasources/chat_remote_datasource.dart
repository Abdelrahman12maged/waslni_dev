import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:car_app/features/chat/data/models/chat_message_model.dart';

abstract class ChatRemoteDataSource {
  Stream<List<ChatMessageModel>> getMessages({
    required String tripId,
    required String currentUserId,
  });

  Future<void> sendMessage({
    required String tripId,
    required String senderId,
    required String senderName,
    required String text,
    bool isDriver = false,
    String senderType = 'passenger',
  });

  Future<void> markMessagesAsRead({
    required String chatId,
    required String currentUserId,
  });

  Stream<int> getUnreadCount({
    required String chatId,
    required String currentUserId,
  });

  Future<void> deleteChat({required String chatId});
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final FirebaseFirestore _firestore;

  ChatRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<ChatMessageModel>> getMessages({
    required String tripId,
    required String currentUserId,
  }) {
    return _firestore
        .collection('chats')
        .doc(tripId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ChatMessageModel.fromFirestore(doc, currentUserId))
          .toList();
    });
  }

  @override
  Future<void> sendMessage({
    required String tripId,
    required String senderId,
    required String senderName,
    required String text,
    bool isDriver = false,
    String senderType = 'passenger',
  }) async {
    final docRef = _firestore
        .collection('chats')
        .doc(tripId)
        .collection('messages')
        .doc();

    final model = ChatMessageModel(
      id: docRef.id,
      tripId: tripId,
      senderId: senderId,
      senderName: senderName,
      text: text,
      timestamp: DateTime.now(),
      isDriver: isDriver,
      senderType: senderType,
      readBy: [senderId],
    );

    await docRef.set(model.toFirestore());

    // Also update conversation root document with last message details
    try {
      await _firestore.collection('chats').doc(tripId).set({
        'tripId': tripId,
        'last_message': text,
        'last_sender_id': senderId,
        'last_sender_name': senderName,
        'last_sender_is_driver': isDriver,
        'last_timestamp': FieldValue.serverTimestamp(),
        'updated_at': DateTime.now().millisecondsSinceEpoch,
        'unread_counts': {
          senderId: 0,
        },
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  @override
  Future<void> markMessagesAsRead({
    required String chatId,
    required String currentUserId,
  }) async {
    try {
      if (chatId.isEmpty || currentUserId.isEmpty) return;

      final unreadDocs = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('senderId', isNotEqualTo: currentUserId)
          .get();

      final batch = _firestore.batch();
      bool hasUpdates = false;

      for (final doc in unreadDocs.docs) {
        final data = doc.data();
        final readBy = (data['readBy'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [];
        if (!readBy.contains(currentUserId)) {
          batch.update(doc.reference, {
            'readBy': FieldValue.arrayUnion([currentUserId])
          });
          hasUpdates = true;
        }
      }

      if (hasUpdates) {
        await batch.commit();
      }

      await _firestore.collection('chats').doc(chatId).set({
        'unread_counts': {
          currentUserId: 0,
        }
      }, SetOptions(merge: true));
    } catch (e) {
      log('Error marking messages as read for $chatId: $e',
          name: 'ChatRemoteDataSource');
    }
  }

  @override
  Stream<int> getUnreadCount({
    required String chatId,
    required String currentUserId,
  }) {
    if (chatId.isEmpty || currentUserId.isEmpty) {
      return Stream.value(0);
    }
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .snapshots()
        .map((snapshot) {
      int count = 0;
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final senderId = data['senderId']?.toString() ?? '';
        if (senderId.isNotEmpty && senderId != currentUserId) {
          final readBy = (data['readBy'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [];
          if (!readBy.contains(currentUserId)) {
            count++;
          }
        }
      }
      return count;
    });
  }

  @override
  Future<void> deleteChat({required String chatId}) async {
    try {
      final messagesRef = _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages');
      final snapshots = await messagesRef.get();
      for (final doc in snapshots.docs) {
        await doc.reference.delete();
      }
      await _firestore.collection('chats').doc(chatId).delete();
      log('Chat deleted successfully for channel: $chatId',
          name: 'ChatRemoteDataSource');
    } catch (e) {
      log('Error deleting chat channel $chatId: $e',
          name: 'ChatRemoteDataSource');
    }
  }
}
