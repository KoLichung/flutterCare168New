import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttercare168/models/body_condition.dart';
import 'package:fluttercare168/models/case.dart';
import 'package:fluttercare168/models/disease_condition.dart';
import 'package:fluttercare168/models/message.dart';
import 'package:fluttercare168/models/review.dart';
import 'package:fluttercare168/models/service.dart';
import 'package:fluttercare168/models/service_increase_money.dart';
import 'package:fluttercare168/pages/messages/message_bubble_widget.dart';
import 'package:fluttercare168/pages/messages/new_message_widget.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttercare168/constant/server_api.dart';
import 'package:fluttercare168/notifier_model/user_model.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import 'order_page.dart';

//聊聊-訂單訊息詳細
class OrderMessageDetail extends StatefulWidget {
  final int chatroomId;
  const OrderMessageDetail({Key? key, required this.chatroomId}) : super(key: key);

  @override
  _OrderMessageDetailState createState() => _OrderMessageDetailState();
}

class _OrderMessageDetailState extends State<OrderMessageDetail> {

  List<Message> chatroomMsgList = [];

  Timer? _timer;
  int timerPeriod = 3;

  bool isSendImage = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getChatroomMsgList();
    _timer = Timer.periodic(Duration(seconds: timerPeriod), (timer) {
      getChatroomMsgList();
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    if(_timer!=null){
      print('cancel timer');
      _timer!.cancel();
      _timer = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        title: const Text('聊聊'),
      ),
      body: Column(
        children: [
          Expanded(
            child: GroupedListView<Message, DateTime>(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                reverse: true,
                order: GroupedListOrder.DESC,
                useStickyGroupSeparators: false,
                floatingHeader: true,
                elements: chatroomMsgList,
                groupBy: (message){
                  DateTime time = DateTime.parse(message.createAt!);
                  return DateTime(time.year, time.month, time.day);
                },
                groupHeaderBuilder: (Message message) => SizedBox(
                  height: 40,
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(20)
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14,vertical: 8),
                      child: Text(
                        (message.createAt!.substring(0,10)).toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                itemBuilder: (context, Message message) {
                  // print(message.caseDetail);
                  // print(message.orderDetail);

                  if(message.caseDetail!=null){
                    return MessageBubble(message: message, onPressed: () async{
                      var userModel = context.read<UserModel>();
                      if(message.caseDetail!.servant == null || (userModel.user!.id == message.caseDetail!.user) || (userModel.user!.id == message.caseDetail!.servant!.id) ){
                        if(_timer!=null){
                          print('cancel timer');
                          _timer!.cancel();
                          _timer = null;
                        }
                        await Navigator.push(context,MaterialPageRoute(builder: (context)=> OrderPage(orderId: message.orderDetail!.id!)));
                        _timer = Timer.periodic(Duration(seconds: timerPeriod), (timer) {
                          print('start timer');
                          getChatroomMsgList();
                        });
                      }else{
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("訂單已被承接，無權觀看。")));
                      }
                    });
                  }else{
                    return MessageBubble(message: message, onPressed: (){},);
                  }
                }
            ),
          ),
          NewMessageWidget(
            chatroomId: widget.chatroomId,
            isSendImage: isSendImage,
            onSubmitted: (messageMap) {
              //可能要在這邊做個判斷回傳的內容是 text or image
              //若圖片是傳 image.path，則丟到 chatroomMsgList 要用 container 顯示

              // print(DateTime.now().add(const Duration(hours: -8)));
              DateTime fixTime = DateTime.now().add(const Duration(hours: -8));

              if(messageMap['isMsgImage']){
                final message = Message(
                  image: messageMap['text'],
                  createAt: fixTime.toString(),
                  messageIsMine: true,
                  isThisMessageOnlyCase: false,
                );
                setState(() => chatroomMsgList.add(message));
              }else{
                final message = Message(
                  content: messageMap['text'],
                  createAt: fixTime.toString(),
                  messageIsMine: true,
                  isThisMessageOnlyCase: false,
                );
                setState(() {
                  chatroomMsgList.add(message);
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Future getChatroomMsgList()async{
    var userModel = context.read<UserModel>();
    String path = ServerApi.PATH_MESSAGES;
    print(userModel.token);
    try {
      final response = await http.get(ServerApi.standard(
          path: path,
          queryParameters: {'chatroom' : widget.chatroomId.toString(),}
      ),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'Authorization': 'token ${userModel.token!}'},
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> map = json.decode(utf8.decode(response.body.runes.toList()));
        // print(map);
        // List<dynamic> parsedListJson = json.decode(utf8.decode(response.body.runes.toList()));
        // print(map['is_send_image']);
        isSendImage = map['is_send_image'];

        List<Message> data = List<Message>.from(map['messages'].map((i) => Message.fromJson(i)));
        chatroomMsgList = data;
        setState(() {});
      }
    } catch (e) {
      print(e);
    }
  }

}
