import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttercare168/constant/color.dart';
import 'package:provider/provider.dart';

import '../../../constant/server_api.dart';
import 'package:http/http.dart' as http;

import '../../../notifier_model/user_model.dart';

class NotificationSetting extends StatefulWidget {
  const NotificationSetting({Key? key}) : super(key: key);

  @override
  _NotificationSettingState createState() => _NotificationSettingState();
}

class _NotificationSettingState extends State<NotificationSetting> {

  bool isChecked = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var userModel = context.read<UserModel>();
    _getUserNotify(userModel.token!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('通知設定'),
        actions: [
          TextButton(
            child: const Text('儲存',style: TextStyle(color: Colors.white),),
            onPressed: (){
              var userModel = context.read<UserModel>();
              _putUpdateUserNotify(userModel.token!, isChecked);
              Navigator.pop(context);
            },
          )],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('訊息通知', style: TextStyle(fontWeight: FontWeight.bold),),
                const SizedBox(height: 20,),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('推播通知我'),
                    Checkbox(
                      checkColor:Colors.white,
                      activeColor: AppColor.purple,
                      value: isChecked,
                      onChanged: (bool? value){
                        setState(() {
                          isChecked = value!;
                        });
                      },
                    ),
                  ],
                ),

              ],
            ),

          ],
        ),
      ),
    );
  }

  Future _getUserNotify(String token) async {
    String path = ServerApi.PATH_GET_UPDATE_USER_FCM_NOTIFY;
    try {
      final response = await http.get(
        ServerApi.standard(path: path),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Token $token',
        },
      );

      Map<String, dynamic> map = json.decode(utf8.decode(response.body.runes.toList()));
      if(map['is_fcm_notify'] == true ){
        isChecked = true;
        setState(() {});
      }else{
        isChecked = false;
        setState(() {});
      }

    } catch (e) {
      print(e);
    }
    return null;
  }

  Future _putUpdateUserNotify (String token, bool isChecked)async{
    String path = ServerApi.PATH_GET_UPDATE_USER_FCM_NOTIFY;
    try{
      final bodyParams ={
        'is_fcm_notify':isChecked.toString(),
      };

      final response = await http.put(ServerApi.standard(path:path),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'token $token'
        },
        body: jsonEncode(bodyParams),
      );
      // print(response.body);
      if(response.statusCode == 200){
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("成功更新通知設定！"),
            )
        );
      }

    } catch (e){
      print(e);
    }
  }

}
