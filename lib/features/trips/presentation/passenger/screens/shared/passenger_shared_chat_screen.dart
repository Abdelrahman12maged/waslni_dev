import 'package:car_app/core/theme/app_colors.dart';

import 'package:car_app/core/widgets/components.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';

const Color _mainColor = AppColors.primary;

/// Passenger-side shared trip chat screen.
/// Displays chat messages grouped by date between passenger and driver.
class PassengerSharedChatScreenClean extends StatelessWidget {
  const PassengerSharedChatScreenClean({super.key});

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
        backgroundColor: _mainColor,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
        ),
        title: defaultText(
          text: 'Ahmad Ismail',
          textColor: Colors.white,
        ),
        actions: [
          PopupMenuButton(
            color: Colors.white,
            position: PopupMenuPosition.under,
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                child: defaultText(
                  text: 'Trip Cancellation',
                  textColor: _mainColor,
                ),
              ),
            ],
          ),
        ],
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
              child: GroupedListView<SharedChatMessage, DateTime>(
                padding: const EdgeInsets.all(8),
                reverse: true,
                order: GroupedListOrder.DESC,
                elements: sharedChatMessages,
                groupBy: (message) => DateTime(
                  message.date.year,
                  message.date.month,
                  message.date.day,
                ),
                groupHeaderBuilder: (SharedChatMessage message) => SizedBox(
                  height: 40.0,
                  child: Center(
                    child: defaultText(
                      text: DateFormat.yMMMMd().format(message.date),
                      textColor: Colors.grey.shade400,
                    ),
                  ),
                ),
                itemBuilder: (context, SharedChatMessage message) =>
                    message.isSentByMe
                        ? myMessageContainer(
                            context: context,
                            messageText: message.text,
                            messageDate: message.date,
                          )
                        : otherMessageContainer(
                            context: context,
                            messageText: message.text,
                            messageDate: message.date,
                          ),
              ),
            ),
            Container(
              height: 70.0,
              padding: const EdgeInsets.only(bottom: 10.0),
              child: chatTextFeildContainer(
                sendButtonOnpressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SharedChatMessage {
  final String text;
  final bool isSentByMe;
  final DateTime date;
  SharedChatMessage({required this.text, required this.isSentByMe, required this.date});
}

final List<SharedChatMessage> sharedChatMessages = [
  SharedChatMessage(text: 'Hello, I am on my way!', isSentByMe: false, date: DateTime.now().subtract(const Duration(minutes: 5))),
  SharedChatMessage(text: 'Great, waiting for you!', isSentByMe: true, date: DateTime.now()),
];
