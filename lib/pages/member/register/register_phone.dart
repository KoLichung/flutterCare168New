import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import '../../../constant/color.dart';
import '../../../constant/server_api.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/custom_textfield.dart';
import 'register_phone_verification_code.dart';

import 'package:http/http.dart' as http;

class RegisterPhone extends StatefulWidget {
  const RegisterPhone({Key? key}) : super(key: key);

  @override
  _RegisterPhoneState createState() => _RegisterPhoneState();
}

class _RegisterPhoneState extends State<RegisterPhone> {

  TextEditingController phoneNumberController = TextEditingController();
  // TextEditingController pwdTextController = TextEditingController();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('註冊'),
        ),
        body:  isLoading ?
          const Center(child: CircularProgressIndicator(),)
            :
          Column(
            children: [
              SizedBox(height: 60,),
              CustomTextField(
                icon: Icons.phone_android_outlined,
                hintText: '電話號碼',
                controller: phoneNumberController,
                isNumberOnly: true,
              ),

              CustomElevatedButton(
                text: '取得驗證碼',
                color: AppColor.purple,
                onPressed: (){
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => RegisterPhoneVerificationCode(phone: 'phone',code: 'code') ),
                  // );
                  isLoading = true;
                  setState(() {});
                  _getVerifyCode(phoneNumberController.text);
                },
              ),
            ],
          ));
  }


  Future _getVerifyCode(String phone) async {
    String path = ServerApi.PATH_GET_SMS_VERIFY;

    try {

      final queryParameters = {
        'phone': phone,
      };

      final response = await http.get(
        ServerApi.standard(path: path, queryParameters: queryParameters),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      print(response.body);
      // log(response.body);
      setState(() {
        isLoading = false;
      });

      Map<String, dynamic> map = json.decode(utf8.decode(response.body.runes.toList()));
      if(map['code'] != null){
        String code = map['code'].toString();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RegisterPhoneVerificationCode(phone: phone,code: code) ),
        );
        // setState(() {});
      }else{
        ScaffoldMessenger.of(context)..removeCurrentSnackBar()..showSnackBar(const SnackBar(content: Text('電話錯誤或此電話已經註冊！')));
      }

    } catch (e) {
      print(e);
      return "error";
    }
  }


}
