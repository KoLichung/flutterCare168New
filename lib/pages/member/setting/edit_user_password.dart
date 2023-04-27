import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttercare168/constant/color.dart';
import 'package:fluttercare168/constant/server_api.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../../../notifier_model/user_model.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/custom_textfield.dart';


class EditUserPassword extends StatefulWidget {
  const EditUserPassword({Key? key}) : super(key: key);

  @override
  _EditUserPasswordState createState() => _EditUserPasswordState();
}

class _EditUserPasswordState extends State<EditUserPassword> {

  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController newPasswordAgainController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('會員資料'),),
      body: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.fromLTRB(30, 30, 30, 10),
            child: Consumer<UserModel>(builder: (context, userModel, child) =>
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextField(
                        icon: Icons.lock_outline,
                        hintText: '舊密碼',
                        controller: oldPasswordController,
                        isObscureText: true,
                      ),
                      CustomTextField(
                        icon: Icons.lock_reset,
                        hintText: '新密碼',
                        controller: newPasswordController,
                        isObscureText: true,
                      ),
                      CustomTextField(
                        icon: Icons.lock_reset,
                        hintText: '再次輸入新密碼',
                        controller: newPasswordAgainController,
                        isObscureText: true,
                      ),
                      Text("(密碼須為英文字母或數字)"),
                    ]
                ),
            ),
          ),
          Consumer<UserModel>(builder: (context, userModel, child) =>
          (!userModel.isLineLogin)?
          CustomElevatedButton(
            text: '確認修改密碼',
            color: AppColor.purple,
            onPressed: (){
              if(oldPasswordController.text =='' ){
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("請輸入舊密碼！"),));
              }else if(newPasswordController.text == ''){
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("請輸入新密碼！"),));
              }else if(newPasswordController.text != newPasswordAgainController.text){
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("再次輸入密碼不相同！"),));
              }else{
                // var userModel = context.read<UserModel>();
                _putUpdateUserPassword(userModel.token!, oldPasswordController.text, newPasswordController.text);
              }
            },
          ):
          Container(),
          )
        ],
      ),

    );
  }

  Future _putUpdateUserPassword(String token, String oldPassword, String newPassword) async {
    String path = ServerApi.PATH_USER_UPDATE_PASSWORD;

    try {
      Map queryParameters = {
        'new_password': newPassword,
        'old_password': oldPassword,
      };

      final response = await http.put(
          ServerApi.standard(path: path),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Token $token',
          },
          body: jsonEncode(queryParameters)
      );

      print(response.body);

      Map<String, dynamic> map = json.decode(utf8.decode(response.body.runes.toList()));
      if(map['message']!=null){
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("成功更新密碼！"),));
        Navigator.pop(context);
      }else{
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("無法更新資料 密碼有誤！"),));
      }

    } catch (e) {
      print(e);
      return "error";
    }
  }


}