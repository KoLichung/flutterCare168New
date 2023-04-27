import 'dart:convert';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:fluttercare168/constant/color.dart';
import 'package:flutter/material.dart';
import 'package:fluttercare168/widgets/custom_textfield.dart';
import 'package:fluttercare168/models/user.dart';
import 'package:fluttercare168/constant/server_api.dart';
import 'package:http/http.dart' as http;
import 'package:fluttercare168/models/user.dart';
import 'package:fluttercare168/notifier_model/user_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class RegisterBySocial extends StatefulWidget {
  final String displayName;
  final String lineId;
  final String appleId;
  final String email;

  const RegisterBySocial({Key? key, required this.displayName, required this.lineId, required this.appleId, required this.email}) : super(key: key);

  @override
  _RegisterSocialState createState() => _RegisterSocialState();
}

class _RegisterSocialState extends State<RegisterBySocial> {

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  bool isLoading = false;
  String _gender = 'M';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    nameController.text = widget.displayName;
    emailController.text = widget.email;
    var userModel = context.read<UserModel>();
    if(userModel.deviceId==null){
      _getDeviceInfo();
    }
  }

  @override
  Widget build(BuildContext context) {

    print(widget.lineId);
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('註冊'),
        ),
        body: Column(
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
              contentText: nameController.text,
            ),
            CustomTextField(
              icon: Icons.phone_android_outlined,
              hintText: '電話號碼',
              controller: phoneNumberController,
              isNumberOnly: true,
            ),
            CustomTextField(
              icon: Icons.email_outlined,
              hintText: 'Email',
              controller: emailController,
              isNumberOnly: false,
              contentText: emailController.text,
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
                          primary: AppColor.purple
                      ),
                      child: const Text('註冊'),
                      onPressed: () async {
                        if(nameController.text ==''||phoneNumberController.text==''||emailController.text==''){
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("請輸入完整資料！"),));
                        } else {
                          User user = User(name: nameController.text, phone: phoneNumberController.text, email: emailController.text);
                          if(widget.lineId!=""){
                            _postCreateUser(user, widget.lineId, '');
                          }else{
                            _postCreateUser(user, '', widget.appleId);
                          }
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

  Future _postCreateUser(User user, String lineId, String appleId) async {
    String path = ServerApi.PATH_CREATE_USER;

    try {
      Map queryParameters = {};

      if(lineId!=''){
        queryParameters = {
          'phone': user.phone,
          'name': user.name,
          'gender': _gender,
          'email': user.email,
          'password': '00000',
          'line_id': lineId,
        };
      }else{
        queryParameters = {
          'phone': user.phone,
          'name': user.name,
          'email': user.email,
          'password': '00000',
          'apple_id': appleId,
        };
      }

      final response = await http.post(ServerApi.standard(path: path),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(queryParameters)
      );

      print(response.body);
      print(response.statusCode);

      if(response.statusCode == 201){
        // Map<String, dynamic> map = json.decode(utf8.decode(response.body.runes.toList()));
        // User theUser = User.fromJson(map);

        var userModel = context.read<UserModel>();

        String? token;
        if(lineId!='') {
          token = await _getUserTokenFromLine(lineId);
          userModel.isLineLogin = true;
        }else{
          token = await _getUserTokenFromApple(appleId);
          userModel.isLineLogin = false;
        }

        userModel.token = token;
        User? user = await _getUserData(token!);
        userModel.setUser(user!);

        Navigator.pop(context);
      }else{
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("此電話號碼可能已註冊，更改電話試試！"),));
        isLoading = false;
        setState(() {});
      }

      // print(response.body);

    } catch (e) {
      print(e);
      return "error";
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

      _httpPostFCMDevice();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_token', token);

      return theUser;

    } catch (e) {
      print(e);

      // return null;
      // return User(phone: '0000000000', name: 'test test', isGottenLineId: false, token: '4b36f687579602c485093c868b6f2d8f24be74e2',isOwner: false);

    }
    return null;
  }

  Future<String?> _getUserTokenFromLine(String lineId) async {
    String path = ServerApi.PATH_USER_TOKEN;
    try {
      Map queryParameters = {
        'phone': '00000',
        'password': '00000',
        'line_id': lineId,
      };

      final response = await http.post(ServerApi.standard(path: path),
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
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<String?> _getUserTokenFromApple(String appleId) async {
    String path = ServerApi.PATH_USER_TOKEN;
    try {
      Map queryParameters = {
        'phone': '00000',
        'password': '00000',
        'apple_id': appleId,
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
}