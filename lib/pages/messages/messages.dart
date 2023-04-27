import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttercare168/pages/messages/order_message_detail.dart';
import 'package:fluttercare168/pages/messages/order_messages.dart';
import 'package:fluttercare168/pages/messages/system_messages.dart';

class Messages extends StatefulWidget {
  const Messages({Key? key}) : super(key: key);

  @override
  _MessagesState createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          elevation: 2,
          shadowColor: Colors.black26,
          title: const Text('聊聊'),
          // elevation: 1.5,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50.0),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 1),
              child: const TabBar(
                // indicatorWeight: 4,
                indicatorPadding: EdgeInsets.symmetric(vertical: 8),
                labelColor: Colors.white,
                indicatorColor: Colors.white,
                indicatorSize: TabBarIndicatorSize.label,
                tabs: [
                  Tab(text: '訂單訊息', ),
                  Tab(text: '系統訊息',),
                ],
              ),
            ),
          ),),
        body: TabBarView(
          children: [
            OrderMessages(), //訂單訊息
            SystemMessages(), //系統訊息
          ],
        ),
      ),
    );
  }

}
