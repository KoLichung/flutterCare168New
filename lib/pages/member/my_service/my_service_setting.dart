import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttercare168/notifier_model/user_model.dart';
import 'package:fluttercare168/pages/member/my_service/my_service_setting_basic.dart';
import 'package:fluttercare168/pages/member/my_service/my_service_setting_items.dart';
import 'package:fluttercare168/pages/member/my_service/my_service_setting_about.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../constant/server_api.dart';
import '../../../models/user.dart';
import '../../../notifier_model/service_model.dart';

class MyServiceSetting extends StatefulWidget {
  const MyServiceSetting({Key? key}) : super(key: key);

  @override
  _MyServiceSettingState createState() => _MyServiceSettingState();
}

class _MyServiceSettingState extends State<MyServiceSetting> with SingleTickerProviderStateMixin{
  late TabController _tabController;


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    var userModel = context.read<UserModel>();
    var serviceModel = context.read<ServiceModel>();

    print(userModel.user!.gender);
    serviceModel.gender = (userModel.user!.gender!=null&&userModel.user!.gender=='男')?Gender.male:Gender.female;

    serviceModel.isHomeChecked = userModel.user!.isHome;
    serviceModel.homeHourly = userModel.user!.homeHourWage.toString();
    serviceModel.homeHalfDay = userModel.user!.homeHalfDayWage.toString();
    serviceModel.homeFullDay = userModel.user!.homeOneDayWage.toString();

    serviceModel.isHospitalChecked = userModel.user!.isHospital;
    serviceModel.hospitalHourly = userModel.user!.hospitalHourWage.toString();
    serviceModel.hospitalHalfDay = userModel.user!.hospitalHalfDayWage.toString();
    serviceModel.hospitalFullDay = userModel.user!.hospitalOneDayWage.toString();

    serviceModel.aboutMe = userModel.user!.aboutMe;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return
      WillPopScope(
          onWillPop: () async {
            print("back pressed");
            var serviceModel = context.read<ServiceModel>();
            serviceModel.clearServiceData();
            return true;
          },
          child: DefaultTabController(
            length: 3,
            child: Scaffold(
              appBar: AppBar(
                elevation: 2,
                shadowColor: Colors.black26,
                title: const Text('我的服務設定'),
                actions: [
                  TextButton(
                    child: const Text('儲存',style: TextStyle(color: Colors.white),),
                    onPressed: (){
                      //update me and update userModel when data back
                      _putUpdateProfile();

                      //update user weekdays
                      _putUpdateWeekDayTimes();

                      //update user languages
                      _putUpdateLanguages();

                      //update user locations
                      _putUdateUserLocations();

                      //update user services
                      _putUpdateUserServices();
                    },
                  )],
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(50.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 1),
                    child: TabBar(
                      controller: _tabController,
                      indicatorPadding: const EdgeInsets.symmetric(vertical: 8),
                      labelColor: Colors.white,
                      indicatorColor: Colors.white,
                      indicatorSize: TabBarIndicatorSize.label,
                      tabs: const [
                        Tab(text: '時段語言',),
                        Tab(text: '服務項目',),
                        Tab(text: '關於我',),
                      ],
                    ),
                  ),
                ),),
              body: TabBarView(
                controller: _tabController,
                children: const [
                  MyServiceSettingBasic(), //時段語言
                  MyServiceSettingItems(), //服務項目
                  MyServiceSettingAbout(), //關於我
                ],
              ),
            ),
          ) // Your Scaffold goes here.
      );
  }

  Future _putUpdateProfile()async{
    var userModel = context.read<UserModel>();
    var serviceModel = context.read<ServiceModel>();

    String path = ServerApi.PATH_USER_DATA;
    try{
      final bodyParams ={
        'name':userModel.user!.name,
        'phone': userModel.user!.phone,
        'gender':(serviceModel.gender==Gender.male)?'M':'F',
        'is_home':serviceModel.isHomeChecked,
        'home_hour_wage':serviceModel.homeHourly,
        'home_half_day_wage':serviceModel.homeHalfDay,
        'home_one_day_wage':serviceModel.homeFullDay,
        'is_hospital':serviceModel.isHospitalChecked,
        'hospital_hour_wage':serviceModel.hospitalHourly,
        'hospital_half_day_wage':serviceModel.hospitalHalfDay,
        'hospital_one_day_wage':serviceModel.hospitalFullDay,
        'about_me':serviceModel.aboutMe,
        'is_continuous_time':serviceModel.isContinuousTime,
      };

      final response = await http.put(ServerApi.standard(path:path),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'token ${userModel.token}'
        },
        body: jsonEncode(bodyParams),
      );
      print(response.body);
      if(response.statusCode == 200){
        Map<String, dynamic> map = json.decode(utf8.decode(response.body.runes.toList()));
        User theUser = User.fromJson(map);
        var userModel = context.read<UserModel>();
        userModel.setUser(theUser);

        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("成功更新！"),
            )
        );
        Navigator.pop(context);
      }
    } catch (e){
      print(e);
    }

  }

  Future _putUpdateWeekDayTimes()async{
    var userModel = context.read<UserModel>();
    String path = ServerApi.PATH_USER_WEEK_DAY_TIMES;

    var serviceModel = context.read<ServiceModel>();
    String weekdayString = '';
    String weektimeString = '';

    serviceModel.checkUserWeekDayTimes.removeWhere((element) => element.isChecked==false);
    weekdayString = serviceModel.checkUserWeekDayTimes.map((item) => item.userWeekDayTime!.weekday! ).toList().toString().replaceAll('[', '').replaceAll(']', '').replaceAll(' ', '');

    print('weekdayString $weekdayString');

    weektimeString = serviceModel.checkUserWeekDayTimes.map((item) => '${item.userWeekDayTime!.startTime!}:${item.userWeekDayTime!.endTime!}' ).toList().toString().replaceAll('[', '').replaceAll(']', '').replaceAll(' ', '');
    // print(weektimeString);

    try {
      // final bodyParams = {
      //   'weekday': '1,3,5',
      //   'weektime': '6.5:17.0,8.0:17.0,8.0:17.0'
      // };

      final bodyParams = {
        'weekday': weekdayString,
        'weektime': weektimeString,
      };

      final response = await http.put(ServerApi.standard(path: path),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'token ${userModel.token!}'
        },
        body: jsonEncode(bodyParams),
      );

      _printLongString(response.body);

      if (response.statusCode == 200) {
        // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("成功更新！") ));
      }
    } catch (e) {
      print(e);
    }
  }

  Future _putUpdateLanguages()async{
    var userModel = context.read<UserModel>();
    String path = ServerApi.PATH_USER_LANGUAGES;

    var serviceModel = context.read<ServiceModel>();
    String language = serviceModel.checkedUserLanguages.map((item) => item.language ).toList().toString().replaceAll('[', '').replaceAll(']', '').replaceAll(' ', '');

    print(language);

    try {

      Map<String,String> bodyParams = {
        'language': language,
      };

      if(serviceModel.checkedUserLanguages.where((element) => element.language==5).isNotEmpty){
        if(serviceModel.checkedUserLanguages.where((element) => element.language==5).first.remark!=null){
          bodyParams['remark_original'] = serviceModel.checkedUserLanguages.where((element) => element.language==5).first.remark!;
        }else{
          bodyParams['remark_original'] = '';
        }
      }

      if(serviceModel.checkedUserLanguages.where((element) => element.language==8).isNotEmpty){
        if(serviceModel.checkedUserLanguages.where((element) => element.language==8).first.remark!=null){
          bodyParams['remark_others'] = serviceModel.checkedUserLanguages.where((element) => element.language==8).first.remark!;
        }else{
          bodyParams['remark_others'] = '';
        }
      }

      print(bodyParams);

      final response = await http.put(ServerApi.standard(path: path),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'token ${userModel.token!}'
        },
        body: jsonEncode(bodyParams),
      );
      _printLongString(response.body);

      if (response.statusCode == 200) {
        // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("成功更新！") ));
      }
    } catch (e) {
      print(e);
    }
  }

  Future _putUdateUserLocations()async{
    var userModel = context.read<UserModel>();
    String path = ServerApi.PATH_USER_SERVICE_LOCATIONS;

    var serviceModel = context.read<ServiceModel>();
    String locations = serviceModel.servantLocations.map((item) => item.location!.city ).toList().toString().replaceAll('[', '').replaceAll(']', '').replaceAll(' ', '');

    String transferFees = serviceModel.servantLocations.map((item) => item.location!.transferFee ).toList().toString().replaceAll('[', '').replaceAll(']', '').replaceAll(' ', '');

    print(locations);
    print(transferFees);

    try {
      Map<String,String> bodyParams = {
        'locations': locations,
        'transfer_fee':transferFees,
      };

      final response = await http.put(ServerApi.standard(path: path),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'token ${userModel.token!}'
        },
        body: jsonEncode(bodyParams),
      );
      _printLongString(response.body);

      if (response.statusCode == 200) {
        // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("成功更新！") ));
      }
    } catch (e) {
      print(e);
    }
  }

  Future _putUpdateUserServices()async{
    var userModel = context.read<UserModel>();
    String path = ServerApi.PATH_USER_SERVICES;

    var serviceModel = context.read<ServiceModel>();
    String services = serviceModel.checkedUserServices.map((item) => (item.increasePercent!=null&&item.increasePercent!=0)?"${item.service!}:${item.increasePercent!.toInt()}":item.service).toList().toString().replaceAll('[', '').replaceAll(']', '').replaceAll(' ', '');

    print('services $services');

    try {
      Map<String,String> bodyParams = {
        'services': services,
      };

      final response = await http.put(ServerApi.standard(path: path),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'token ${userModel.token!}'
        },
        body: jsonEncode(bodyParams),
      );

      // _printLongString(response.body);

      if (response.statusCode == 200) {
        // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("成功更新！") ));
      }
    } catch (e) {
      print(e);
    }
  }

  void _printLongString(String text) {
    final RegExp pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern.allMatches(text).forEach((RegExpMatch match) =>   print(match.group(0)));
  }
}
