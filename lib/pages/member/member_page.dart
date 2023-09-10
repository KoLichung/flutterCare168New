import 'dart:convert';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttercare168/constant/color.dart';
import 'package:fluttercare168/pages/member/apply_servant/applying_page.dart';
import 'package:fluttercare168/pages/member/register/login_register.dart';
import 'package:fluttercare168/pages/member/my_service/my_service_setting.dart';
import 'package:fluttercare168/pages/member/setting/notification_setting.dart';
import 'package:fluttercare168/pages/member/my_service/share_my_service.dart';
import 'package:fluttercare168/widgets/custom_elevated_button.dart';
import 'package:fluttercare168/widgets/custom_member_page_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fluttercare168/pages/messages/messages.dart';
import 'package:fluttercare168/pages/member/setting/profile.dart';
import 'package:fluttercare168/pages/member/order_management/my_bookings_page.dart';
import 'package:fluttercare168/pages/member/order_management/reviews_page.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:fluttercare168/notifier_model/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constant/server_api.dart';
import '../../models/carer.dart';
import '../../models/user.dart';
import 'package:http/http.dart' as http;

import '../../notifier_model/service_model.dart';
import '../search_carer/search_carer_detail.dart';
import 'apply_servant/applying_documents_one.dart';
import 'dart:io';

//會員中心
class MemberPage extends StatefulWidget {
  const MemberPage({Key? key}) : super(key: key);

  @override
  _MemberPageState createState() => _MemberPageState();
}

class _MemberPageState extends State<MemberPage> {

  @override
  void initState() {
    super.initState();
    _getUserTokenAndRefreshUser();

    _getDeviceInfo();
    _initPackageInfo();
    _getLatestAppVersion();
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
    } else {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      String deviceID =  androidDeviceInfo.androidId!;
      print(deviceID);
      userModel.deviceId = deviceID;
      userModel.platformType = 'android';
    }
  }

  Future<void> _initPackageInfo() async {
    var userModel = context.read<UserModel>();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    // userModel.setCurrentAppVersion(packageInfo.version);
    userModel.currentAppVersionCode = int.parse(packageInfo.buildNumber);
    // print(userModel.currentAppVersion);
    print(userModel.currentAppVersionCode);
  }

  _getUserTokenAndRefreshUser() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('user_token');
    print(token);
    var userModel = context.read<UserModel>();
    if(token!=null && userModel.user==null){
      _getUserData(token);
    }
  }

  _deleteUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_token');
  }

  _deleteIsShowTeachingDialog() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isNotShowTeachingDialog');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('會員中心'),
          actions: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16,16,8,0),
                  child: IconButton(
                    icon: const FaIcon(FontAwesomeIcons.comments),
                    onPressed: (){
                      var userModel = context.read<UserModel>();
                      if(userModel.isLogin()){
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Messages(),
                            ));
                      } else {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginRegister(),
                            ));
                      }
                    },),
                ),
                Consumer<UserModel>(builder: (context, userModel, child){
                    if(userModel.user!=null && userModel.user!.totalUnReadNum!=null && userModel.user!.totalUnReadNum != 0){
                      return Container(
                        decoration: const BoxDecoration(
                            color: Colors.red, shape: BoxShape.circle),
                        margin: const EdgeInsets.fromLTRB(0, 10, 10, 0),
                        padding: const EdgeInsets.all(5),
                        child: Text(userModel.user!.totalUnReadNum.toString(),style: const TextStyle(color: Colors.white)),
                      );
                    }else{
                      return Container();
                    }
                }),
              ],
            ),
          ]),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer<UserModel>(builder: (context, userModel, child) => (userModel.isLogin())
                ? (userModel.user!.isServantPassed!= null && userModel.user!.isServantPassed! == true)
                    ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: ()async{
                                    Uri url = Uri.parse(ServerApi.getCarerUrl(userModel.user!.id!).toString());
                                    if (!await launchUrl(url)) {
                                    throw 'Could not launch $url';
                                    }
                                  },
                                  child: checkUserImage(userModel.user?.image),),

                                const Text('哈囉! '),
                                Text('${userModel.user?.name}', style: const TextStyle(fontSize: 16),),
                                const Text(' (服務者)',style: TextStyle(fontSize: 12),),
                              ],),),
                      const Divider(
                            // color: Colors.green,
                            color: Color(0xffCCCCCC),
                            thickness: 6,
                          ),
                      const Padding(
                            padding: EdgeInsets.fromLTRB(22,10,20,0),
                            child: Text('我的服務',style: TextStyle(color: AppColor.deepPurple),),
                          ), //我的服務
                      CustomMemberPageButton(
                              title: '我的服務設定',
                              onPressed: () async {
                                await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder:(context) => const MyServiceSetting()
                                    ));
                                var serviceModel = context.read<ServiceModel>();
                                serviceModel.clearServiceData();
                              }),
                      const Divider(
                        indent: 20,
                        height: 1,
                        thickness: 1,
                        color: Color(0xffCCCCCC),
                      ),
                      CustomMemberPageButton(
                              title: '收款方式',
                              onPressed: (){
                                Navigator.pushNamed(context, '/bankAccount');
                              }),
                      const Divider(
                        indent: 20,
                        height: 1,
                        thickness: 1,
                        color: Color(0xffCCCCCC),
                      ),
                      CustomMemberPageButton(
                              title: '我接的案',
                              onPressed: (){
                                Navigator.pushNamed(context, '/myCases');
                              }),
                      const Divider(
                        indent: 20,
                        height: 1,
                        thickness: 1,
                        color: Color(0xffCCCCCC),
                      ),
                      CustomMemberPageButton(
                          title: '推廣我的照顧服務',
                          onPressed: (){
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ShareMyService(),
                                ));
                          }),
                      const Divider(
                            // color: Colors.green,
                            color: Color(0xffCCCCCC),
                            thickness: 6,
                          ),
                      const Padding(
                            padding: EdgeInsets.fromLTRB(22,10,20,0),
                            child: Text('個人設定',style: TextStyle(color: AppColor.deepPurple),),
                          ), //個人設定
                      CustomMemberPageButton(
                              title: '基本資料',
                              onPressed: (){
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const Profile(),
                                    ));
                              }),
                      const Divider(
                        indent: 20,
                        height: 1,
                        thickness: 1,
                        color: Color(0xffCCCCCC),
                      ),
                      // CustomMemberPageButton(
                      //     title: '我的文件',
                      //     onPressed: (){
                      //       Navigator.push(
                      //           context,
                      //           MaterialPageRoute(
                      //             builder: (context) => const MyDocuments(),
                      //           ));
                      //     }),
                      const Divider(
                        indent: 20,
                        height: 1,
                        thickness: 1,
                        color: Color(0xffCCCCCC),
                      ),
                      CustomMemberPageButton(
                          title: '通知設定',
                          onPressed: (){
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const NotificationSetting(),
                                ));
                          }),
                      const Divider(
                            // color: Colors.green,
                            color: Color(0xffCCCCCC),
                            thickness: 6,
                          ),
                      const Padding(
                            padding: EdgeInsets.fromLTRB(22,10,20,0),
                            child: Text('訂單管理',style: TextStyle(color: AppColor.deepPurple),),
                          ), //訂單管理
                      CustomMemberPageButton(
                              title: '我發的需求案件',
                              onPressed: (){
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const MyBookingsPage(),
                                    ));

                              }),
                      const Divider(
                        indent: 20,
                        height: 1,
                        thickness: 1,
                        color: Color(0xffCCCCCC),
                      ),
                      CustomMemberPageButton(
                          title: '評價',
                          onPressed: (){
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ReviewsPage(),
                                ));
                          }),
                    ],
                )
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 0,horizontal: 0),
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              checkUserImage(userModel.user?.image),
                              const Text('哈囉! '),
                              Text('${userModel.user?.name}', style: const TextStyle(fontSize: 16),),
                            ],),),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomElevatedButton(
                                text: '申請成為服務者',
                                color: AppColor.purple,
                                onPressed: (){
                                  if(userModel.user!.isApplyServant!){
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const ApplyingPage(),
                                        ));
                                  }else {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const ApplyDocumentsOne(),
                                        ));
                                  }
                                })
                          ],
                        ),
                        SizedBox(height: 15,),
                        const Divider(
                          // color: Colors.green,
                          color: Color(0xffCCCCCC),
                          thickness: 6,
                        ),
                        const Padding(
                          padding: EdgeInsets.fromLTRB(22,10,20,0),
                          child: Text('個人設定',style: TextStyle(color: AppColor.deepPurple),),
                        ), //個人設定
                        CustomMemberPageButton(
                            title: '基本資料',
                            onPressed: (){
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Profile(),
                                  ));
                            }),
                        const Divider(
                          indent: 20,
                          height: 1,
                          thickness: 1,
                          color: Color(0xffCCCCCC),
                        ),
                        // CustomMemberPageButton(
                        //     title: '我的文件',
                        //     onPressed: (){
                        //       Navigator.push(
                        //           context,
                        //           MaterialPageRoute(
                        //             builder: (context) => const MyDocuments(),
                        //           ));
                        //     }),
                        // const Divider(
                        //   indent: 20,
                        //   height: 1,
                        //   thickness: 1,
                        //   color: Color(0xffCCCCCC),
                        // ),
                        Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            child: ListTile(
                              title: const Text('通知設定', style: TextStyle(fontSize: 16),),
                              trailing: SizedBox(
                                width: 30,
                                child: IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const NotificationSetting(),
                                        ));
                                  },
                                  icon: const Icon(Icons.arrow_forward_ios),
                                ),
                              ),
                            )),
                        const Divider(
                          // color: Colors.green,
                          color: Color(0xffCCCCCC),
                          thickness: 6,
                        ),
                        const Padding(
                          padding: EdgeInsets.fromLTRB(22,10,20,0),
                          child: Text('訂單管理',style: TextStyle(color: AppColor.deepPurple),),
                        ), //訂單管理
                        CustomMemberPageButton(
                            title: '我發的需求案件',
                            onPressed: (){
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const MyBookingsPage(),
                                  ));
                            }),
                        const Divider(
                          indent: 20,
                          height: 1,
                          thickness: 1,
                          color: Color(0xffCCCCCC),
                        ),
                        CustomMemberPageButton(
                            title: '評價',
                            onPressed: (){
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ReviewsPage(),
                                  ));
                            }),
                      ],
                    )
                : Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('狀態：未登入', style: TextStyle(fontSize: 20),),
                          ElevatedButton(
                              onPressed: ()  {
                                Navigator.pushNamed(context, '/loginRegister');
                              },
                              child: const Text('登入', style: TextStyle(fontSize: 16)),
                              style: ElevatedButton.styleFrom(backgroundColor: AppColor.deepPurple, elevation: 0)
                          ),
                        ],
                      ),
                    ),
            ),
            const Divider(
              color: Color(0xffCCCCCC),
              thickness: 6,
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(22,10,20,0),
              child: Text('關於 Care168',style: TextStyle(color: AppColor.deepPurple),),
            ), //關於168
            CustomMemberPageButton(
                title: '關於我們',
                onPressed: ()async{
                  Uri url = Uri.parse(ServerApi.ABOUT_URL);
                  if (!await launchUrl(url)) {
                  throw 'Could not launch $url';
                  }
                }),
            const Divider(
              indent: 20,
              height: 1,
              thickness: 1,
              color: Color(0xffCCCCCC),
            ),
            CustomMemberPageButton(
                title: '會員條款',
                onPressed: ()async{
                  Uri url = Uri.parse(ServerApi.TERMS_SERVICE_URL);
                  if (!await launchUrl(url)) {
                  throw 'Could not launch $url';
                  }
                }),
            const Divider(
              indent: 20,
              height: 1,
              thickness: 1,
              color: Color(0xffCCCCCC),
            ),
            CustomMemberPageButton(
                title: '隱私權政策',
                onPressed: ()async{
                  Uri url = Uri.parse(ServerApi.PRIVACY_POLICY_URL);
                  if (!await launchUrl(url)) {
                  throw 'Could not launch $url';
                  }
                }),
            const Divider(
              indent: 20,
              height: 1,
              thickness: 1,
              color: Color(0xffCCCCCC),
            ),
            CustomMemberPageButton(
                title: '線上LINE客服',
                onPressed: ()async{
                  Uri url = Uri.parse('https://page.line.me/876gfkog');
                  var userModel = context.read<UserModel>();
                  if (userModel.platformType != null && userModel.platformType == 'ios' ){
                    if (!await launchUrl(url)) {
                      throw 'Could not launch $url';
                    }
                  }else{
                    if (!await launchUrl(url,mode: LaunchMode.externalApplication)) {
                      throw 'Could not launch $url';
                    }
                  }
                }),
            const Divider(
              indent: 20,
              height: 1,
              thickness: 1,
              color: Color(0xffCCCCCC),
            ),
            const SizedBox(height: 10,),
            Consumer<UserModel>(builder: (context, userModel, child) => (userModel.isLogin())
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: const Color(0xffCCCCCC)
                              ),
                              child: const Text('登出'),
                              onPressed: (){
                                var userModel = context.read<UserModel>();
                                userModel.removeUser(context);
                                _deleteUserToken();
                                _deleteIsShowTeachingDialog();
                                userModel.isNotShowTeachingDialogAgain = false;
                              },),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox()
            ),
            Consumer<UserModel>(builder: (context, userModel, child) => (userModel.isLogin())
                ? Container(
                    margin: const EdgeInsets.fromLTRB(0, 20, 0, 40),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: Colors.red
                            ),
                            child: const Text('刪除用戶'),
                            onPressed: () async {
                              final confirmBack = await _showDeleteDialog(context);
                              if(confirmBack){
                                print('here');
                                var userModel = context.read<UserModel>();
                                _deleteUserData(userModel.token!, userModel.user!.id!);
                              }
                            },),
                        ),
                      ],
                    ),
                  )
                : const SizedBox()
            ),
        ],),
      ),
    );
  }

  checkUserImage(String? imgPath) {
    if (imgPath == null || imgPath == '') {
      return Container(
        margin: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        height: 70,
        width: 70,
        decoration: const BoxDecoration(shape: BoxShape.circle),
        child: const Icon(Icons.account_circle_rounded, size: 64, color: Colors.grey,),
      );
    } else {
      return Container(
        margin: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        height: 70,
        width: 70,
        decoration: BoxDecoration(
          color: Colors.grey,
          shape: BoxShape.circle,
          image: DecorationImage(
              image: NetworkImage(imgPath),
              fit: BoxFit.cover
          ),
        ),
      );
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

      if(response.statusCode ==200){
        Map<String, dynamic> map = json.decode(utf8.decode(response.body.runes.toList()));
        User theUser = User.fromJson(map);

        var userModel = context.read<UserModel>();
        userModel.setUser(theUser);
        userModel.token = token;

        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("歡迎回來！${userModel.user!.name}"),));
        return theUser;
      }else{
        //token過期, 需重新登入
        _deleteUserToken();
      }

    } catch (e) {
      print(e);

      // return null;
      // return User(phone: '0000000000', name: 'test test', isGottenLineId: false, token: '4b36f687579602c485093c868b6f2d8f24be74e2',isOwner: false);

    }
    return null;
  }

  Future _showDeleteDialog(BuildContext context) {
    // Init
    AlertDialog dialog = AlertDialog(
      title: Text("Care168提醒您～！"),
      content: Text('用戶刪除後，無法取回用戶資料！'),
      actions: [
        ElevatedButton(
            child: Text("取消"),
            style: ElevatedButton.styleFrom(
              // primary: AppColor.purple,
                primary: AppColor.purple,
                elevation: 0
            ),
            onPressed: () {
              Navigator.pop(context, false);
            }
        ),
        ElevatedButton(
            child: Text("確認刪除"),
            style: ElevatedButton.styleFrom(
              // primary: AppColor.purple,
                primary: AppColor.purple,
                elevation: 0
            ),
            onPressed: () {
              Navigator.pop(context, true);
            }
        ),
      ],
    );

    // Show the dialog
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return dialog;
        }
    );
  }

  Future<User?> _deleteUserData(String token,int userId) async {
    String path = ServerApi.PATH_DELETE_USER+userId.toString()+'/';
    try {
      final response = await http.delete(
        ServerApi.standard(path: path),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Token $token',
        },
      );

      print(response.body);

      if(response.body.contains('continuous order exists')){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("有訂單尚未完成！無法刪除！"),));
      }
      if(response.body.contains('delete user')){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("成功刪除使用者!"),));
        var userModel = context.read<UserModel>();
        userModel.removeUser(context);
      }

    } catch (e) {
      print(e);
    }
    return null;
  }

  Future _getLatestAppVersion () async {
    String path = ServerApi.PATH_GET_CURRENT_VERSION;
    try {
      final response = await http.get(ServerApi.standard(path: path));
      if (response.statusCode == 200){
        Map<String, dynamic> map = json.decode(utf8.decode(response.body.runes.toList()));
        print(map);

        var userModel = context.read<UserModel>();
        print('userModel.platformType ${userModel.platformType}');
        print('userModel.currentAppVersionCode ${userModel.currentAppVersionCode}');

        if(userModel.platformType!=null && userModel.currentAppVersionCode != null){
          if(userModel.platformType=='ios' && userModel.currentAppVersionCode! < int.parse(map['ios'])){
            return showDialog(
              barrierDismissible: false,
              context: context,
              builder: (BuildContext context) => AlertDialog(
                contentPadding: const EdgeInsets.all(20),
                content: const Text('有新的 App 版本，請立即更新'),
                actionsAlignment: MainAxisAlignment.center,
                actions: [
                  TextButton(
                    child: const Text('前往更新'),
                    onPressed: ()async{
                      String app= 'https://apps.apple.com/tw/app/care168/id1644036067';
                      Uri url = Uri.parse(app);
                      if (!await launchUrl(url)) {
                        throw 'Could not launch $url';
                      }
                    },
                  ),
                ],
              ),
            );
          }else if (userModel.platformType=='android' && userModel.currentAppVersionCode! < int.parse(map['android'])){
            return showDialog(
              barrierDismissible: false,
              context: context,
              builder: (BuildContext context) => AlertDialog(
                contentPadding: const EdgeInsets.all(20),
                content: const Text('有新的 App 版本，請立即更新'),
                actionsAlignment: MainAxisAlignment.center,
                actions: [
                  TextButton(
                    child: const Text('前往更新'),
                    onPressed: ()async{
                      String app= 'market://details?id=com.chijia.fluttercare168';
                      Uri url = Uri.parse(app);
                      if (!await launchUrl(url)) {
                        throw 'Could not launch $url';
                      }
                    },
                  ),
                ],
              ),
            );
          }
        }
        // iOSLatestVersion = map['ios'];
        // androidLatestVersion = map['android'];
      }
    } catch (e) {
      print(e);
    }
  }

}



