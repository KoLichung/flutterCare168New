import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttercare168/pages/member/resetPassword/reset_password_phone_verification_code.dart';

import 'package:http/http.dart' as http;

import '../../../constant/color.dart';
import '../../../constant/server_api.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/custom_textfield.dart';

class ResetPasswordPhone extends StatefulWidget {
  const ResetPasswordPhone({Key? key}) : super(key: key);

  @override
  _ResetPasswordPhoneState createState() => _ResetPasswordPhoneState();
}

class _ResetPasswordPhoneState extends State<ResetPasswordPhone> {

  TextEditingController phoneNumberController = TextEditingController();
  // TextEditingController pwdTextController = TextEditingController();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('重設密碼'),
        ),
        body:
        isLoading ?
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
                setState(() {
                  isLoading = true;
                });
                _getVerifyCode(phoneNumberController.text);
              },
            ),
          ],
        ));
  }


  Future _getVerifyCode(String phone) async {
    String path = ServerApi.PATH_RESET_PASSWORD_SMS_VERIFY;

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
      setState(() {
        isLoading = false;
      });

      Map<String, dynamic> map = json.decode(utf8.decode(response.body.runes.toList()));
      if(map['code'] != null){
        String code = map['code'].toString();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ResetPasswordPhoneVerificationCode(phone: phone,code: code) ),
        );
        // setState(() {});
      }else{
        ScaffoldMessenger.of(context)..removeCurrentSnackBar()..showSnackBar(const SnackBar(content: Text('找不到此電話的使用者！')));
      }

    } catch (e) {
      print(e);
      return "error";
    }
  }


}
