import 'package:flutter/material.dart';
import 'package:fluttercare168/models/chatroom.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'order_message_detail.dart';
import 'package:fluttercare168/constant/server_api.dart';
import 'package:fluttercare168/notifier_model/user_model.dart';
import 'package:provider/provider.dart';
import 'dart:async';

//聊聊-訂單訊息列表
class OrderMessages extends StatefulWidget {
  const OrderMessages({Key? key}) : super(key: key);

  @override
  _OrderMessagesState createState() => _OrderMessagesState();
}

class _OrderMessagesState extends State<OrderMessages> {

  bool isLoading = true;
  List<Chatroom> chatroomList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getChatroomList();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: chatroomList.length,
        itemBuilder: (BuildContext context,int i){
          return Column(
            children: [
              GestureDetector(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
                    child: Row(
                      children: [
                        Expanded(
                          flex:1,
                          child: checkUserImage(chatroomList[i].otherSideImageUrl),
                        ),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(chatroomList[i].otherSideName!,style: const TextStyle(fontSize: 18,fontWeight: FontWeight.bold)),
                              Text(_filterMeesagePhone(chatroomList[i].lastMessage!))
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Column(
                            children: [
                              Text(chatroomList[i].updateAt!.substring(0,10),style: const TextStyle(fontSize: 14)),
                              (chatroomList[i].unreadNum != 0)?
                              Container(
                                decoration: const BoxDecoration(
                                    color: Colors.red, shape: BoxShape.circle),
                                margin: EdgeInsets.fromLTRB(0, 10, 10, 0),
                                padding: EdgeInsets.all(8),
                                child: Text(
                                  chatroomList[i].unreadNum.toString(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              )
                                  :
                              Container(
                                width: 30,
                                height: 30,
                                margin: EdgeInsets.fromLTRB(0, 10, 10,0),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  onTap: () async {
                    if(chatroomList[i].otherSideName!=null&&chatroomList[i].otherSideName!=""){
                      await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context)=> OrderMessageDetail(chatroomId: chatroomList[i].id!,)));
                      getChatroomList();
                    }
                  }
              ),
              const Divider(
                color: Color(0xffC0C0C0),
              ),
            ],
          );
        }
    );
  }

  String _filterMeesagePhone(String text){
    return text.replaceAll(RegExp('[0-9]{5,10}'), '[請勿輸入電話]');
  }

  checkUserImage(String? imgPath){
    if(imgPath == null || imgPath == ''){
      return Container(
        height: 60,
        width: 60,
        decoration: const BoxDecoration(shape: BoxShape.circle),
        child: const Icon(Icons.account_circle_rounded,size: 64,color: Colors.grey,),
      );
    } else {
      return Container(
        height: 60,
        width: 60,
        decoration: BoxDecoration(
          color: Colors.grey,
          shape: BoxShape.circle,
          image: DecorationImage(
              image: NetworkImage(ServerApi.IMG_PATH+imgPath),
              fit: BoxFit.cover
          ),
        ),
      );
    }
  }

  Future getChatroomList()async{
    var userModel = context.read<UserModel>();
    String path = ServerApi.PATH_CHATROOM;
    try {
      final response = await http.get(ServerApi.standard(path: path),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'Authorization': 'token ${userModel.token!}'},
      );
      if (response.statusCode == 200) {
        List<dynamic> parsedListJson = json.decode(utf8.decode(response.body.runes.toList()));
        List<Chatroom> data = List<Chatroom>.from(parsedListJson.map((i) => Chatroom.fromJson(i)));
        chatroomList = data;

        int num = 0;
        for(var chatRoom in chatroomList){
          num = num + chatRoom.unreadNum!;
        }
        var userModel = context.read<UserModel>();
        userModel.setUserUnReadNum(num);

        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print(e);
    }
  }
}
