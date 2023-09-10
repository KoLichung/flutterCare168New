import 'dart:convert';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttercare168/pages/search_carer/page_weekday_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constant/color.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:intl/intl.dart';
import '../../constant/server_api.dart';
import '../../models/user.dart';
import '../member/register/login_register.dart';
import 'package:provider/provider.dart';
import 'package:fluttercare168/notifier_model/user_model.dart';
import '../messages/messages.dart';
import 'package:fluttercare168/models/city.dart';
import 'package:fluttercare168/models/county.dart';
import 'package:fluttercare168/constant/format_converter.dart';
import 'package:fluttercare168/constant/enum.dart';
import 'search_list.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:flutter/src/material/date.dart';

//搜索服務者
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<String> cityList = City.getCityNames();
  List<String> districtList = [];

  final DateRangePickerController _startDateController = DateRangePickerController();
  final DateRangePickerController _endDateController = DateRangePickerController();
  final DateRangePickerController _dateRangePickerController = DateRangePickerController();

  @override
  initState(){
    super.initState();
    var userModel = context.read<UserModel>();
    districtList = County.getCountyNames(userModel.city.id!);
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

  @override
  Widget build(BuildContext context) {
    var userModel = context.read<UserModel>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Care168'),
        actions: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16,16,8,0),
                child: IconButton(
                  icon: const FaIcon(FontAwesomeIcons.comments),
                  onPressed: (){
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
                if(userModel.user!=null && userModel.user!.totalUnReadNum != 0){
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
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 15,),
              careTypeOptions(),
              const SizedBox(height: 15,),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColor.purple,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(4),),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: IntrinsicHeight(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Text('縣市：'),
                            const SizedBox(width: 10,),
                            _getCity(),
                            // const VerticalDivider(
                            //   thickness: 2,
                            //   indent: 12,
                            //   endIndent: 12,
                            //   color: AppColor.purple,
                            // ),
                            // const Text('區域：'),
                            // getDistrict(),
                          ],
                        ),
                      ),
                    ), //縣市區域
                    const Divider(
                      color: AppColor.purple,
                      thickness: 2,
                      height: 0,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Row(
                        children: [
                          // const Text('時間類型：'),
                          Radio<TimeType>(
                            value: TimeType.continuous,
                            groupValue: userModel.timeType,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            onChanged: (TimeType? value) {
                              setState(() {
                                userModel.timeType = value!;
                              });
                            },
                          ),
                          const Text('連續時間'),
                          Radio<TimeType>(
                            value: TimeType.weekly,
                            groupValue: userModel.timeType,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            onChanged: (TimeType? value) {
                              setState(() {
                                userModel.timeType = value!;
                              });
                            },
                          ),
                          const Text('指定時段'),
                          TextButton(
                            child: const Text('(說明)',style: TextStyle(decoration: TextDecoration.underline, color: AppColor.purple, fontSize: 16),),
                            onPressed: () async {
                              Uri url = Uri.parse('https://care168.com.tw//news_detail?blogpost=7');
                              if (!await launchUrl(url)) {
                              throw 'Could not launch $url';
                              }
                            }),
                        ],
                      ),
                    ), //時間類型
                    const Divider(
                      color: AppColor.purple,
                      thickness: 2,
                      height: 0,
                    ),
                    userModel.timeType == TimeType.continuous? continuousTime() : weeklyTime()
                  ],
                ),
              ), //表格內容
              const SizedBox(height: 20,),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: AppColor.purple,
                      elevation: 0),
                  onPressed: (){
                   //把 time 轉成 double 後再比較時間先後
                    DateTime _theStartDate = DateUtils.dateOnly(userModel.startDate);
                    DateTime _theEndDate = DateUtils.dateOnly(userModel.endDate);

                    if(userModel.startDate.isAfter(userModel.endDate)){
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("開始日期要早於結束日期！")));

                    } else if(_theStartDate.isAtSameMomentAs(_theEndDate) && timeToDouble(userModel.startTime) >= timeToDouble(userModel.endTime)) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("開始時間要小於結束時間！")));

                    } else {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SearchList(),
                          ));
                    }

                  },
                  child: const Text('開始搜索')),
              TextButton(
                child: const Text('我有需求，填寫需求單',style: TextStyle(decoration: TextDecoration.underline, color: AppColor.purple, fontSize: 16),),
                onPressed: (){
                  if(userModel.isLogin()){
                    Navigator.pushNamed(context, '/requirementStep1Basic');
                  } else {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginRegister(),
                        ));
                  }
                },
              ),
              const SizedBox(height: 100,),
            ],
          ),
        ),
      ),
    );
  }
  double timeToDouble(TimeOfDay myTime) => myTime.hour + myTime.minute/60.0;

  careTypeOptions(){
    var userModel = context.read<UserModel>();
    return CupertinoSegmentedControl<CareType>(
      unselectedColor:  CupertinoColors.white,
      selectedColor: AppColor.purple,
      borderColor: AppColor.purple,
      pressedColor: const Color(0xffEDDAFF),
      padding: const EdgeInsets.all(2),
      groupValue: userModel.careType,
      children: {
        CareType.homeCare:
        userModel.careType == CareType.homeCare
            ? Container(
                padding:const EdgeInsets.all(8),
                child: const Text('居家照顧',style: TextStyle(fontSize: 22, color: Colors.white),),
            )
            :Container(
                padding:const EdgeInsets.all(8),
                child: const Text('居家照顧',style: TextStyle(fontSize: 22, color: AppColor.purple),),
             ),

        CareType.hospitalCare: userModel.careType == CareType.hospitalCare
            ? Container(
                padding:const EdgeInsets.all(8),
                child: const Text('醫院看護',style: TextStyle(fontSize: 22, color: Colors.white),),
            )
            :Container(
                padding:const EdgeInsets.all(8),
                child: const Text('醫院看護',style: TextStyle(fontSize: 22, color: AppColor.purple),),
            ),
      },
      onValueChanged: (CareType value){
        setState(() {
          userModel.careType = value;
        });
      },
    );
  }

  DropdownButtonHideUnderline _getCity(){
    var userModel = context.read<UserModel>();
    return DropdownButtonHideUnderline(
        child: DropdownButton<String>(
            itemHeight: 50,
            value: userModel.city.name,
            onChanged:(String? newValue){
              setState(() {
                userModel.city = City.getCityFromName(newValue!);
                // districtList = County.getCountyNames(userModel.city.id!);
                // userModel.district= County.getCountyFromName(userModel.city.id!, districtList.first);
              });
            },
            items: cityList.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList())
    );
  }

  // DropdownButtonHideUnderline getDistrict(){
  //   var userModel = context.read<UserModel>();
  //   return DropdownButtonHideUnderline(
  //       child: DropdownButton<String>(
  //           itemHeight: 50,
  //           value: userModel.district.name,
  //           onChanged:(String? newValue){
  //             setState(() {
  //               userModel.district = County.getCountyFromName(userModel.city.id!, newValue!);
  //             });
  //           },
  //           items: districtList.map<DropdownMenuItem<String>>((String value) {
  //             return DropdownMenuItem<String>(
  //               value: value,
  //               child: Text(value),
  //             );
  //           }).toList())
  //   );
  // }

  //連續時間
  continuousTime(){
    var userModel = context.read<UserModel>();
    return Column(
      children: [
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              const Text('開始日期：'),
              GestureDetector(
                  onTap: (){
                    showDialog<Widget>(
                        context: context,
                        builder: (BuildContext context) {
                          return startDatePicker();
                        });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Text(DateFormat('MM/dd').format(userModel.startDate)),
                  )
              ),
              const SizedBox(width: 10,),
              const Text('時間：'),
              GestureDetector(
                child: Text(userModel.startTime.to24hours()),
                onTap: (){
                  _pickStartTime(context);
                },
              ),
            ],),
        ), //開始日期
        const Divider(
          color: AppColor.purple,
          thickness: 2,
          height: 0,
        ),
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              const Text('結束日期：'),
              GestureDetector(
                  onTap: (){
                    showDialog<Widget>(
                        context: context,
                        builder: (BuildContext context) {
                          return endDatePicker();
                        });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Text(DateFormat('MM/dd').format(userModel.endDate)),
                  )
              ),
              const SizedBox(width: 10,),
              const Text('時間：'),
              GestureDetector(
                child: Text(userModel.endTime.to24hours()),
                onTap: (){
                  _pickEndTime(context);
                },
              ),
            ],),
        ), //結束日期
      ],
    );
  }

  startDatePicker(){
    var userModel = context.read<UserModel>();
    return Center(
      child: SizedBox(
        height: 460,
        width: 380,
        child: SfDateRangePickerTheme(
          data: SfDateRangePickerThemeData(
            brightness: Brightness.light,
            backgroundColor: Colors.white,
          ),
          child: SfDateRangePicker(
            controller: _startDateController,
            view: DateRangePickerView.month,
            monthViewSettings: const DateRangePickerMonthViewSettings(
              firstDayOfWeek: 7,
            ),
            allowViewNavigation: false,
            headerHeight: 60,
            headerStyle: const DateRangePickerHeaderStyle(
                backgroundColor: AppColor.purple,
                textAlign: TextAlign.center,
                textStyle: TextStyle(
                  fontSize: 22,
                  letterSpacing: 1,
                  color: Colors.white,
                )),
            selectionMode: DateRangePickerSelectionMode.single,
            minDate: DateTime.now(),
            onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
              setState(() {
                if (args.value is DateTime) {
                  userModel.startDate = args.value;
                }
              });
            },
            showActionButtons: true,
            cancelText: '取消',
            confirmText: '確定',
            onSubmit: (Object? value, ) {
              Navigator.pop(context);
            },

            onCancel: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  endDatePicker(){
    var userModel = context.read<UserModel>();
    return Center(
      child: SizedBox(
        height: 460,
        width: 380,
        child: SfDateRangePickerTheme(
          data: SfDateRangePickerThemeData(
            brightness: Brightness.light,
            backgroundColor: Colors.white,
          ),
          child: SfDateRangePicker(
            controller: _endDateController,
            view: DateRangePickerView.month,
            monthViewSettings: const DateRangePickerMonthViewSettings(
              firstDayOfWeek: 7,
            ),
            allowViewNavigation: false,
            headerHeight: 60,
            headerStyle: const DateRangePickerHeaderStyle(
                backgroundColor: AppColor.purple,
                textAlign: TextAlign.center,
                textStyle: TextStyle(
                  fontSize: 22,
                  letterSpacing: 1,
                  color: Colors.white,
                )),
            selectionMode: DateRangePickerSelectionMode.single,
            minDate: userModel.startDate.add(const Duration(days: 1)),
            onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
              setState(() {
                if (args.value is DateTime) {
                  userModel.endDate = args.value;
                }
              });
            },
            showActionButtons: true,
            cancelText: '取消',
            confirmText: '確定',
            onSubmit: (Object? value, ) {
              // print('chosen duration: $value');
              Navigator.pop(context);
            },
            onCancel: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  //指定時段
  weeklyTime(){
    var userModel = context.read<UserModel>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              const Text('日期：'),
              GestureDetector(
                  onTap: (){
                    showDialog<Widget>(
                        context: context,
                        builder: (BuildContext context) {
                          return getDateRangePicker();
                        });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Text('${DateFormat('MM / dd').format(userModel.startDate)}  -  ${DateFormat('MM / dd').format(userModel.endDate)}'),
                  )
              ),
            ],
          ),
        ), //日期區間
        const Divider(
          color: AppColor.purple,
          thickness: 2,
          height: 0,
        ),
        Container(
          alignment: Alignment.centerLeft,
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child:
          Consumer<UserModel>(builder: (context, userModel, child) =>
              GestureDetector(
                child:
                  Row(
                    children: [
                      const Text('星期：'),
                      (getWeekDayStrings() == null || getWeekDayStrings() == '')
                          ? const Text('選擇週間')
                          : Flexible(child: Text(getWeekDayStrings(),overflow: TextOverflow.visible,)),
                    ],
                  ),
                onTap: () async {
                  await showDialog<String>(
                      context: context,
                      builder: (BuildContext context) {
                        return PageWeekdayDialog(modelName: 'user_model',);
                      });
                  setState(() {});
                }),
          ),
        ), //週間星期
        const Divider(
          color: AppColor.purple,
          thickness: 2,
          height: 0,
        ),
        Container(
          alignment: Alignment.centerLeft,
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: GestureDetector(
            child: Text('開始時間：'+ userModel.startTime.to24hours()),
            onTap: (){
              _pickStartTime(context);
            },
          ),
        ), //開始時間
        const Divider(
          color: AppColor.purple,
          thickness: 2,
          height: 0,
        ),
        Container(
          alignment: Alignment.centerLeft,
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: GestureDetector(
            child: Text('結束時間：'+userModel.endTime.to24hours()),
            onTap: (){
              _pickEndTime(context);
            },
          ),

        ),//結束時間
      ],
    );
  }

  getWeekDayStrings(){
    List<String> dayStrings = [];
    var userModel = context.read<UserModel>();
    for(var day in userModel.checkWeekDays){
      if(day.isChecked){
        dayStrings.add(day.day);
      }
    }
    return dayStrings.join(',');
  }

  getDateRangePicker(){
    return Center(
      child: SizedBox(
        height: 460,
        width: 360,
        child: SfDateRangePickerTheme(
          data: SfDateRangePickerThemeData(
            brightness: Brightness.light,
            backgroundColor: Colors.white,
          ),
          child: SfDateRangePicker(
            controller: _dateRangePickerController,
            view: DateRangePickerView.month,
            monthViewSettings: const DateRangePickerMonthViewSettings(
              firstDayOfWeek: 7,
            ),
            headerHeight: 60,
            headerStyle: const DateRangePickerHeaderStyle(
                backgroundColor: AppColor.purple,
                textAlign: TextAlign.center,
                textStyle: TextStyle(
                  fontSize: 22,
                  letterSpacing: 3,
                  color: Colors.white,
                )),
            selectionMode: DateRangePickerSelectionMode.range,
            minDate: DateTime.now(),
            onSelectionChanged: selectionChanged,
            showActionButtons: true,
            cancelText: '取消',
            confirmText: '確定',
            onSubmit: (Object? value, ) {
              Navigator.pop(context);
            },
            onCancel: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  void selectionChanged(DateRangePickerSelectionChangedArgs args) {
    var userModel = context.read<UserModel>();
    setState(() {
      userModel.startDate = args.value.startDate;
      userModel.endDate = args.value.endDate ?? args.value.startDate;
    });
  }

  Future<void> _pickStartTime(BuildContext context) async {
    var userModel = context.read<UserModel>();
    final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: userModel.startTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,);
      },);
    if (picked != null && picked != userModel.startTime) {

      if(picked.minute > 0 && picked.minute < 15){
        userModel.startTime = TimeOfDay(hour: picked.hour, minute: 0);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("時間自動以30分鐘為單位調整！"),));
      } else if ((picked.minute >= 15 && picked.minute <30) || (picked.minute > 30 && picked.minute <45)){
        userModel.startTime = TimeOfDay(hour: picked.hour, minute: 30);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("時間自動以30分鐘為單位調整！"),));
      } else if (picked.minute >= 45 && picked.minute <= 59) {
        userModel.startTime = TimeOfDay(hour: picked.hour + 1, minute: 0);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("時間自動以30分鐘為單位調整！"),));
      }else{
        userModel.startTime = TimeOfDay(hour: picked.hour, minute: picked.minute);
      }

      setState(() {});
    }
  }

  Future<void> _pickEndTime(BuildContext context) async {
    var userModel = context.read<UserModel>();
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: userModel.endTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null && picked != userModel.endTime) {

      if(picked.minute > 0 && picked.minute < 15){
        userModel.endTime = TimeOfDay(hour: picked.hour, minute: 0);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("時間自動以30分鐘為單位調整！"),));
      } else if ((picked.minute >= 15 && picked.minute <30) || (picked.minute > 30 && picked.minute <45)){
        userModel.endTime = TimeOfDay(hour: picked.hour, minute: 30);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("時間自動以30分鐘為單位調整！"),));
      } else if (picked.minute >= 45 && picked.minute <= 59) {
        userModel.endTime = TimeOfDay(hour: picked.hour + 1, minute: 0);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("時間自動以30分鐘為單位調整！"),));
      }else{
        userModel.endTime = TimeOfDay(hour: picked.hour, minute: picked.minute);
      }

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

  Future _getLatestAppVersion () async {
    String path = ServerApi.PATH_GET_CURRENT_VERSION;
    try {
      final response = await http.get(ServerApi.standard(path: path));
      if (response.statusCode == 200){
        Map<String, dynamic> map = json.decode(utf8.decode(response.body.runes.toList()));

        var userModel = context.read<UserModel>();
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
