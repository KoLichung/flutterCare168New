import 'dart:convert';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:fluttercare168/constant/color.dart';
import 'package:flutter/material.dart';
import 'package:fluttercare168/widgets/custom_textfield.dart';
import 'package:http/http.dart' as http;
import 'package:fluttercare168/models/user.dart';
import 'package:fluttercare168/notifier_model/user_model.dart';
import 'package:fluttercare168/constant/server_api.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class RegisterByPhone extends StatefulWidget {
  String phone;

  RegisterByPhone({Key? key, required this.phone}) : super(key: key);

  @override
  _RegisterPhoneState createState() => _RegisterPhoneState();
}

class _RegisterPhoneState extends State<RegisterByPhone> {
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController pwdController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  bool isLoading = false;
  String _gender = 'M';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var userModel = context.read<UserModel>();
    if(userModel.deviceId==null){
      _getDeviceInfo();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(title: const Text('註冊'),),
        body: isLoading
            ? const Center(child: CircularProgressIndicator(),)
            : Column(
                children: [
                  const SizedBox(height: 50,),
                  Container(
                    margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: Row(
                      children: [
                        // const Text('性別'),
                        const SizedBox(width: 75,),
                        Radio<String>(
                          activeColor: Colors.black54,
                          value: 'M',
                          groupValue: _gender,
                          onChanged: (String? value) {
                            setState(() {
                              _gender = value!;
                            });
                          },
                        ),
                        const Text('男'),
                        Radio<String>(
                          activeColor: Colors.black54,
                          value: 'F',
                          groupValue: _gender,
                          onChanged: (String? value) {
                            setState(() {
                              _gender = value!;
                            });
                          },
                        ),
                        const Text('女')
                      ],
                    ),
                  ),
                  CustomTextField(
                    icon: Icons.person_outlined,
                    hintText: '姓名',
                    controller: nameController,
                    isNumberOnly: false,
                  ),
                  CustomTextField(
                    icon: Icons.phone_android_outlined,
                    hintText: '電話號碼',
                    controller: phoneNumberController,
                    isNumberOnly: true,
                    isEditable: false,
                    contentText: widget.phone,
                  ),
                  CustomTextField(
                    icon: Icons.email_outlined,
                    hintText: 'Email',
                    controller: emailController,
                    isNumberOnly: false,
                  ),
                  CustomTextField(
                    icon: Icons.lock_outline,
                    hintText: '密碼',
                    controller: pwdController,
                    isObscureText: true,
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 30,vertical: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                backgroundColor: AppColor.purple
                            ),
                            child: const Text('註冊'),
                            onPressed: (){
                              if(nameController.text == ''||phoneNumberController.text ==''||pwdController.text==''||emailController.text==''){
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("請輸入完整資料！"),));
                              } else{
                                User user = User(name: nameController.text, phone: phoneNumberController.text, email: emailController.text);
                                _postCreateUser(user, phoneNumberController.text,pwdController.text);
                                isLoading = true;
                                setState(() {});
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
    );
  }

  Future _postCreateUser(User user,String phone, String password) async {
    String path = ServerApi.PATH_CREATE_USER;
    try {
      Map queryParameters = {
        'name' : user.name,
        'phone': user.phone,
        'email': user.email,
        'gender': _gender,
        'password': password,
      };
      print(queryParameters);
      final response = await http.post(ServerApi.standard(path: path),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(queryParameters)
      );
      // print(response.body);

      if(response.statusCode == 201){
        var userModel = context.read<UserModel>();

        // Map<String, dynamic> map = json.decode(utf8.decode(response.body.runes.toList()));
        // User theUser = User.fromJson(map);
        // userModel.setUser(theUser);

        String? token = await _getUserToken(phone, password);
        userModel.token = token!;

        User? theUser = await _getUserData(token);
        userModel.setUser(theUser!);

        _httpPostFCMDevice();

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_token', token);

        Navigator.of(context).popUntil((route) => route.isFirst);

      }else{
        ScaffoldMessenger.of(context)..removeCurrentSnackBar()..showSnackBar(const SnackBar(content: Text('電話錯誤或此電話已經註冊！')));
      }


    } catch (e) {
      print(e);
      return "error";
    }
  }

  Future<String?> _getUserToken(String phone, String password) async {
    String path = ServerApi.PATH_USER_TOKEN;
    try {
      Map queryParameters = {
        'phone': phone,
        'password': password,
      };

      final response = await http.post(
          ServerApi.standard(path: path),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(queryParameters)
      );

      Map<String, dynamic> map = json.decode(utf8.decode(response.body.runes.toList()));
      if(map['token']!=null){
        String token = map['token'];
        return token;
      }else{
        print(response.body);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("無法取得Token！"),));
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<void> _httpPostFCMDevice() async {
    print("postFCMDevice");
    String path = ServerApi.PATH_REGISTER_DEVICE;
    var userModel = context.read<UserModel>();

    try {
      Map queryParameters = {
        'registration_id': userModel.fcmToken,
        'device_id': userModel.deviceId,
        'type': userModel.platformType,
      };

      print(userModel.fcmToken);
      print(userModel.deviceId);
      print(userModel.platformType);
      print(userModel.token);

      final response = await http.post(ServerApi.standard(path: path),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Token ${userModel.token!}',
        },
        body: jsonEncode(queryParameters),
      );

      print(response.body);

    }catch(e){
      print(e);
    }
  }

  Future _getDeviceInfo() async {
    var userModel = context.read<UserModel>();
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) { // import 'dart:io'
      var iosDeviceInfo = await deviceInfo.iosInfo;
      String deviceID = iosDeviceInfo.identifierForVendor!;
      print(deviceID);
      userModel.deviceId = deviceID;
      userModel.platformType = 'ios';
      setState(() {});
    } else {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      String deviceID =  androidDeviceInfo.androidId!;
      print(deviceID);
      userModel.deviceId = deviceID;
      userModel.platformType = 'android';
      setState(() {});
    }
  }

  Future<User?> _getUserData(String token) async {
    String path = ServerApi.PATH_USER_DATA;
    try {
      final response = await http.get(
        ServerApi.standard(path: path),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Token $token',
        },
      );

      print(response.body);

      Map<String, dynamic> map = json.decode(utf8.decode(response.body.runes.toList()));
      User theUser = User.fromJson(map);

      return theUser;

    } catch (e) {
      print(e);

      // return null;
      // return User(phone: '0000000000', name: 'test test', isGottenLineId: false, token: '4b36f687579602c485093c868b6f2d8f24be74e2',isOwner: false);

    }
    return null;
  }

  // Future _getVerifyCode(String phone) async {
  //   String path = Service.PATH_GET_SMS_VERIFY;
  //
  //   try {
  //
  //     final queryParameters = {
  //       'phone': phone,
  //     };
  //
  //     final response = await http.get(
  //       Service.standard(path: path, queryParameters: queryParameters),
  //       headers: <String, String>{
  //         'Content-Type': 'application/json; charset=UTF-8',
  //       },
  //     );
  //
  //     print(response.body);
  //
  //     Map<String, dynamic> map = json.decode(utf8.decode(response.body.runes.toList()));
  //     if(map['code'] != null){
  //       String code = map['code'].toString();
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(builder: (context) => RegisterPhoneVerificationCode(phone: phone,code: code) ),
  //       );
  //       // setState(() {});
  //     }else{
  //       ScaffoldMessenger.of(context)..removeCurrentSnackBar()..showSnackBar(const SnackBar(content: Text('電話錯誤或此電話已經註冊！')));
  //     }
  //
  //   } catch (e) {
  //     print(e);
  //     return "error";
  //   }
  // }


}