import 'package:flutter/material.dart';
import 'package:fluttercare168/constant/server_api.dart';
import 'package:fluttercare168/notifier_model/user_model.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttercare168/models/message.dart';
import 'package:intl/intl.dart';

class SystemMessages extends StatefulWidget {
  const SystemMessages({Key? key}) : super(key: key);

  @override
  _SystemMessagesState createState() => _SystemMessagesState();
}

class _SystemMessagesState extends State<SystemMessages> {
  bool isLoading = true;
  List<Message> systemMsgList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSystemMsgList();
  }
  @override
  Widget build(BuildContext context) {
    if(isLoading){
      return  const Center(child: CircularProgressIndicator());
    } else {
      return ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: systemMsgList.length,
          itemBuilder: (BuildContext context,int i){
            DateTime time = DateTime.parse(systemMsgList[i].createAt!);
            time = time.add(Duration(hours: 8));
            String formattedDate = DateFormat('yyyy-MM-dd kk:mm').format(time);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(40,20,40,10),
                  child: Text(formattedDate),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(40,0,40,10),
                  child: Text(systemMsgList[i].content!, style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
                ),
                const Divider(
                  color: Color(0xffC0C0C0),
                ),
              ],
            );
          }
      );
    }
  }

  Future getSystemMsgList()async{
    var userModel = context.read<UserModel>();
    String path = ServerApi.PATH_SYSTEM_MESSAGES;
    // try {
      final response = await http.get(ServerApi.standard(path: path),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'Authorization': 'token ${userModel.token!}'},
      );
      if (response.statusCode == 200) {
        List<dynamic> parsedListJson = json.decode(utf8.decode(response.body.runes.toList()));
        List<Message> data = List<Message>.from(parsedListJson.map((i) => Message.fromJson(i)));
        systemMsgList = data;
        setState(() {
          isLoading = false;
        });
      }
    // } catch (e) {
    //   print(e);
    // }
  }
}
