import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttercare168/pages/member/resetPassword/reset_password_finish.dart';
import 'package:http/http.dart' as http;

import '../../../constant/color.dart';
import '../../../constant/server_api.dart';
import '../../../widgets/custom_elevated_button.dart';

class ResetPasswordPhoneVerificationCode extends StatefulWidget {

  final String phone;
  final String code;

  const ResetPasswordPhoneVerificationCode({Key? key, required this.phone, required this.code}) : super(key: key);

  @override
  _ResetPasswordPhoneVerificationCodeState createState() => _ResetPasswordPhoneVerificationCodeState();
}

class _ResetPasswordPhoneVerificationCodeState extends State<ResetPasswordPhoneVerificationCode> {

  TextEditingController pwdTextControllerOne = TextEditingController();
  TextEditingController pwdTextControllerTwo = TextEditingController();
  TextEditingController pwdTextControllerThree = TextEditingController();
  TextEditingController pwdTextControllerFour = TextEditingController();

  FocusNode textFocusNodeOne = FocusNode();
  FocusNode textFocusNodeTwo = FocusNode();
  FocusNode textFocusNodeThree = FocusNode();
  FocusNode textFocusNodeFour = FocusNode();

  int runDownSecond = 60;
  Timer? _timer;

  String theCode = '';

  @override
  void initState() {
    super.initState();
    theCode = widget.code;
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('重設密碼'),
        ),
        body: Column(
          children: [
            const SizedBox(height: 60,),
            const Text('請輸入您的手機驗證碼'),
            RichText(
              text: TextSpan(
                text: runDownSecond.toString(),
                style: const TextStyle(fontSize: 24,color: Colors.black, height: 2),
                children: const <TextSpan>[
                  TextSpan(text: ' 秒',style: TextStyle(fontSize: 18)),
                ],
              ),
            ),
            const SizedBox(height: 30,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                verificationCodeTextField(pwdTextControllerOne, 1, textFocusNodeOne),
                verificationCodeTextField(pwdTextControllerTwo, 2, textFocusNodeTwo),
                verificationCodeTextField(pwdTextControllerThree, 3, textFocusNodeThree),
                verificationCodeTextField(pwdTextControllerFour, 4, textFocusNodeFour),
              ],),
            const SizedBox(height: 30,),
            CustomElevatedButton(
              text: '驗證',
              color: AppColor.purple,
              onPressed: (){
                String verifyCode = pwdTextControllerOne.text + pwdTextControllerTwo.text + pwdTextControllerThree.text + pwdTextControllerFour.text;
                if(verifyCode == theCode){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ResetPasswordFinish(phone: widget.phone)),
                  );
                }else{
                  ScaffoldMessenger.of(context)..removeCurrentSnackBar()..showSnackBar(const SnackBar(content: Text('驗證碼錯誤！')));
                }

              },
            ),
            GestureDetector(
              onTap: () {
                if(runDownSecond!=0){
                  ScaffoldMessenger.of(context)..removeCurrentSnackBar()..showSnackBar(const SnackBar(content: Text('請等待時間結束再重新發送！')));
                }else{
                  _getVerifyCode(widget.phone);
                }
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 30),
                alignment: Alignment.center,
                child: Text(
                  '未取得驗證碼，請再次發送',
                  style: TextStyle(color: Colors.yellow.shade700,decoration: TextDecoration.underline,),
                ),
              ),
            ),
          ],
        ));
  }

  verificationCodeTextField(TextEditingController controller, int index, FocusNode focusNode){
    return Container(
      margin: const  EdgeInsets.symmetric(horizontal: 10),
      width: 50,
      height: 60,
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColor.darkGrey,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(4),),
      child:  TextField(
        style: const TextStyle(fontSize: 30),
        controller: controller,
        keyboardType: TextInputType.number,
        focusNode: focusNode,
        onChanged: (text){
          if(text!=''){
            if(index == 1){
              FocusScope.of(context).requestFocus(textFocusNodeTwo);
            }else if(index == 2){
              FocusScope.of(context).requestFocus(textFocusNodeThree);
            }else if(index == 3){
              FocusScope.of(context).requestFocus(textFocusNodeFour);
            }
          }else{
            if(index == 2){
              FocusScope.of(context).requestFocus(textFocusNodeOne);
            }else if(index == 3){
              FocusScope.of(context).requestFocus(textFocusNodeTwo);
            }else if(index == 4){
              FocusScope.of(context).requestFocus(textFocusNodeThree);
            }
          }
        },
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 13,vertical: 10),
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
        ),

      ),
    );
  }

  void _startTimer(){
    runDownSecond = 60;
    _timer = Timer.periodic(const Duration(seconds:1), (timer){
      if(runDownSecond!=0) {
        runDownSecond --;
        setState(() {});
      }else{
        _timer!.cancel();
        _timer = null;
      }
    });
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

      Map<String, dynamic> map = json.decode(utf8.decode(response.body.runes.toList()));
      if(map['code'] != null){
        theCode = map['code'].toString();
        _startTimer();
      }else{
        ScaffoldMessenger.of(context)..removeCurrentSnackBar()..showSnackBar(const SnackBar(content: Text('可能網路不佳，請再試一次！')));
      }

    } catch (e) {
      print(e);
      return "error";
    }
  }

  @override
  void dispose() {
    super.dispose();
    if(_timer!=null){
      _timer!.cancel();
      _timer = null;
    }
  }

}
