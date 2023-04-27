import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:fluttercare168/constant/color.dart';
import 'package:flutter/material.dart';
import 'package:fluttercare168/pages/member/register/register_by_social.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fluttercare168/widgets/custom_textfield.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:fluttercare168/models/user.dart';
import 'package:fluttercare168/notifier_model/user_model.dart';
import 'package:fluttercare168/constant/server_api.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_line_sdk/flutter_line_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';


class LoginRegister extends StatefulWidget {
  const LoginRegister({Key? key}) : super(key: key);

  @override
  _LoginRegisterState createState() => _LoginRegisterState();
}

class _LoginRegisterState extends State<LoginRegister> {

  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController pwdTextController = TextEditingController();

  @override
  void initState() {
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
        appBar: AppBar(
          title: const Text('登入'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 60),
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: Colors.grey,
                    image: DecorationImage(
                      image:AssetImage('images/care_logo.png'),
                    )
                ),
              ),
              CustomTextField(
                icon: Icons.phone_android_outlined,
                hintText: '電話號碼',
                controller: phoneNumberController,
                isNumberOnly: true,
              ),
              CustomTextField(
                icon: Icons.lock_outline,
                hintText: '密碼',
                controller: pwdTextController,
                isObscureText: true,
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 30,vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          primary: AppColor.purple
                        ),
                        child: const Text('登入'),
                        onPressed: (){
                            _phoneLogIn(context, phoneNumberController.text, pwdTextController.text);
                        },
                          ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      alignment: Alignment.centerRight,
                      child: const Text('忘記密碼', style: TextStyle(color: AppColor.darkGrey,decoration: TextDecoration.underline,),),
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, '/reset_password_phone');
                    },
                  ),
                  GestureDetector(
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(0,0,30,0),
                      alignment: Alignment.centerRight,
                      child: const Text('註冊', style: TextStyle(color: AppColor.darkGrey,decoration: TextDecoration.underline,),),
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, '/registerPhone');
                      // Navigator.pushNamed(context, '/registerPhone')
                      //     .then((value){
                      //   var userModel = context.read<UserModel>();
                      //   if(userModel.user != null){
                      //     Navigator.pop(context,"ok");
                      //   }
                      // });
                    },
                  ),
                ],
              ),
              const Divider(
                height: 30,
                color: Colors.black87,
                indent: 30,
                endIndent: 30,
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 30),
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: const Color(0xFF00B900),
                        elevation: 0
                    ),
                    onPressed: (){
                      // Navigator.pushNamed(context, '/registerLine');
                      print("line button pressed");
                      _lineSignIn(context);
                    },
                    child: Container(
                      height: 46,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(flex:1, child:Container(
                            margin: const EdgeInsets.only(left: 10),
                            alignment: Alignment.centerLeft,
                            width: 40,
                            child: const Icon(FontAwesomeIcons.line),
                          )),
                          Expanded(flex:3, child:Container(child: const Text('使用LINE繼續',textAlign: TextAlign.center,),)),
                          Expanded(flex:1, child:Container()),
                        ],
                      ),
                    )
                ),
              ),
              const SizedBox(height: 10),
              Consumer<UserModel>(builder: (context, userModel, child) =>
              (userModel.platformType=="android")?
              Container():
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 30),
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: const Color(0xFF000000),
                        elevation: 0
                    ),
                    onPressed: (){
                      print("apple button pressed");
                      _singInWithApple(context);
                    },
                    child: Container(
                      height: 46,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(flex:1, child:Container(
                            margin: const EdgeInsets.only(left: 10),
                            alignment: Alignment.centerLeft,
                            width: 40,
                            child: const Icon(FontAwesomeIcons.apple),
                          )),
                          Expanded(flex:3, child:Container(child: const Text('透過Apple繼續',textAlign: TextAlign.center,),)),
                          Expanded(flex:1, child:Container()),
                        ],
                      ),
                    )
                ),
              )
              ),
              const SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('登入即代表您同意',style: TextStyle(fontSize: 14),),
                  TextButton(
                    child:const Text('會員條款',style: TextStyle(fontSize: 14),),
                    onPressed: ()async{
                      Uri _url = Uri.parse('https://care168.com.tw/terms_of_service');
                      if (!await launchUrl(_url)) {
                        throw 'Could not launch $_url';
                      }
                    },
                  ),
                  const Text('與',style: TextStyle(fontSize: 14),),
                  TextButton(
                      child: const Text('隱私權政策',style: TextStyle(fontSize: 14),),
                      onPressed: ()async{
                        Uri _url = Uri.parse('https://care168.com.tw/privacy_policy');
                        if (!await launchUrl(_url)) {
                          throw 'Could not launch $_url';
                        }
                      },
                  ),
                ],
              ),
              const SizedBox(height: 300,)
            ],
          ),
        ));
  }

  Future<void> _phoneLogIn(BuildContext context, String phone, String password) async {
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
        print('server token $token');

        var userModel = context.read<UserModel>();
        userModel.token = token;
        User? user = await _getUserData(token);
        userModel.setUser(user!);

        Navigator.pop(context, 'ok');

      }else{
        print(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("電話號碼 或 密碼錯誤！"),
            )
        );
      }

    }catch(e){
      print(e);
    }
  }

  Future<void> _lineSignIn(BuildContext context) async {
    try {
      print("trying to line login");
      final result = await LineSDK.instance.login();

      String lineId = result.userProfile!.userId;
      String displayName = result.userProfile!.displayName;

      print("lineId $lineId");
      print(displayName);

      String? token = await _getUserTokenFromLine(lineId);
      print("userToken $token");

      if(token != null){
        var userModel = context.read<UserModel>();
        userModel.token = token;

        User? user = await _getUserData(token);
        userModel.setUser(user!);
        userModel.isLineLogin = true;

        Navigator.pop(context, 'ok');
      }else{

        await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RegisterBySocial(displayName: displayName, lineId: lineId, appleId: '', email: ''),
            )
        );

        var userModel = context.read<UserModel>();
        if(userModel.user != null){
          Navigator.pop(context, 'ok');
        }else{
          ScaffoldMessenger.of(context)..removeCurrentSnackBar()..showSnackBar(const SnackBar(content: Text('未成功建立使用者！')));
        }
      }
    } on PlatformException catch (e) {
      print(e.toString());
    }
  }

  Future<void> _singInWithApple(BuildContext context) async{
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.fullName,
        AppleIDAuthorizationScopes.email,
      ],
    );
    final String appleId = credential.userIdentifier!;

    String displayName = '';
    try{
      displayName = credential.givenName! + credential.familyName!;
    }catch(e){
      print(e);
    }

    String email = '';
    if(credential.email!=null){
      email = credential.email!;
    }

    print(appleId);
    print(displayName);
    print(email);

    String? token = await _getUserTokenFromApple(appleId);
    print("userToken $token");

    if(token != null){
      var userModel = context.read<UserModel>();
      userModel.token = token;

      User? user = await _getUserData(token);
      userModel.setUser(user!);

      Navigator.pop(context);
    }else{
      await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RegisterBySocial(displayName: displayName, lineId: "", appleId: appleId, email: email),
          )
      );

      var userModel = context.read<UserModel>();
      if(userModel.user != null){
        Navigator.pop(context, 'ok');
      }else{
        ScaffoldMessenger.of(context)..removeCurrentSnackBar()..showSnackBar(const SnackBar(content: Text('未成功建立使用者！')));
      }
    }
  }

  Future<String?> _getUserTokenFromLine(String lineId) async {
    String path = ServerApi.PATH_USER_TOKEN;
    try {
      Map queryParameters = {
        'phone': '00000',
        'password': '00000',
        'line_id': lineId,
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

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_token', token);

      _httpPostFCMDevice();

      return theUser;

    } catch (e) {
      print(e);

      // return null;
      // return User(phone: '0000000000', name: 'test test', isGottenLineId: false, token: '4b36f687579602c485093c868b6f2d8f24be74e2',isOwner: false);

    }
    return null;
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