import 'dart:developer';
import 'package:car_app/generated/l10n.dart';
import 'package:car_app/core/widgets/components.dart';
import 'package:car_app/core/theme/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DriverSharedChatTripsScreenClean extends StatefulWidget {
  const DriverSharedChatTripsScreenClean({
    super.key,
    this.m_id,
    this.chat_id,
    this.r_name,
  });
  final dynamic m_id;
  final dynamic chat_id;
  final dynamic r_name;

  @override
  State<DriverSharedChatTripsScreenClean> createState() =>
      _DriverSharedChatTripsScreenCleanState();
}

class _DriverSharedChatTripsScreenCleanState
    extends State<DriverSharedChatTripsScreenClean> {
  final TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 120,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20.0),
          ),
        ),
        backgroundColor: AppColors.primary,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
        ),
        title: defaultText(
          text: widget.r_name.toString(),
          textColor: Colors.white,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          left: 10.0,
          right: 10.0,
          bottom: 10.0,
        ),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('messages')
                    .where(Filter.or(
                      Filter.and(Filter("r_id", isEqualTo: widget.m_id),
                          Filter("s_id", isEqualTo: widget.chat_id)),
                      Filter.and(Filter("s_id", isEqualTo: widget.m_id),
                          Filter("r_id", isEqualTo: widget.chat_id)),
                    ))
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final messages = snapshot.data!.docs.toList()
                    ..sort((a, b) {
                      final aTime = (a.data() as Map<String, dynamic>?)?['timestamp'];
                      final bTime = (b.data() as Map<String, dynamic>?)?['timestamp'];
                      if (aTime == null || bTime == null) return 0;
                      if (aTime is Timestamp && bTime is Timestamp) return bTime.compareTo(aTime);
                      return bTime.toString().compareTo(aTime.toString());
                    });
                  return ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final tsValue = message['timestamp'];
                      final DateTime date = tsValue is Timestamp 
                          ? tsValue.toDate() 
                          : tsValue is String 
                              ? DateTime.tryParse(tsValue) ?? DateTime.now() 
                              : DateTime.now();

                      return widget.m_id == message['s_id']
                          ? myMessageContainer(
                              context: context,
                              messageText: message['text'],
                              messageDate: date,
                            )
                          : otherMessageContainer(
                              context: context,
                              messageText: message['text'],
                              messageDate: date,
                            );
                    },
                  );
                },
              ),
            ),
            Container(
              height: 70.0,
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textEditingController,
                        decoration: InputDecoration(
                          hintText: S.of(context).typeMessage,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () => _sendMessage(),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _sendMessage() async {
    final text = _textEditingController.text.trim();
    if (text.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.collection('messages').add({
          'text': text,
          's_id': widget.m_id,
          'r_id': widget.chat_id,
          'timestamp': DateTime.now().toLocal(),
        });
        _textEditingController.clear();
      } catch (e) {
        log('Error sending message: $e', name: 'DriverSharedChat');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(S.of(context).error),
              content: Text(S.of(context).failedToSendMessage),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(S.of(context).ok),
                ),
              ],
            );
          },
        );
      }
    }
  }
}
