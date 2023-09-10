import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttercare168/pages/member/register/login_register.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fluttercare168/constant/color.dart';
import 'package:fluttercare168/constant/custom_tag.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user.dart';
import '../../notifier_model/user_model.dart';
import 'search_case_detail_page.dart';
import '../../constant/color.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import '../city_dialog.dart';
import 'package:fluttercare168/models/city.dart';
import 'package:fluttercare168/models/county.dart';
import 'package:intl/intl.dart';
import '../messages/messages.dart';
import '../care_type_dialog.dart';
import 'package:fluttercare168/constant/server_api.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttercare168/models/case.dart';

//找案件
class SearchCasePage extends StatefulWidget {
  const SearchCasePage({Key? key}) : super(key: key);
  @override
  _SearchCaseStatePage createState() => _SearchCaseStatePage();
}

extension TimeOfDayConverter on TimeOfDay {
  String to24hours() {
    final hour = this.hour.toString().padLeft(2, "0");
    final min = this.minute.toString().padLeft(2, "0");
    return "$hour:$min";
  }
}

class _SearchCaseStatePage extends State<SearchCasePage> {

  List<Case> newCaseList = [];
  List<String> cityList = City.getCityNames();
  List<String> typeList = ['居家照顧','醫院看護',];
  DateTime startDate = DateTime.now();
  // DateTime endDate = DateTime.now().add(const Duration(days: 14));
  final DateRangePickerController _dateRangePickerController = DateRangePickerController();

  List<String> chosenConditionsStrings =[];
  String? chosenCityString;
  String? chosenCareTypeString;
  String? chosenDurationDateString;

  //for getCaseList
  int? paramCity;
  String? paramStartDate;
  String? paramEndDate;
  String? paramCareType;

  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //city=6, start_datetime=2022-07-10&end_datetime=2022-08-05&care_type=hospital
    print(startDate);

    isLoading = true;
    _getCaseList(paramCity, paramStartDate, paramCareType);
    _getUserTokenAndRefreshUser();
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
    return Scaffold(
      appBar: AppBar(
          elevation: 2,
          shadowColor: Colors.black26,
          title: const Text('找案件'),
          bottom: PreferredSize(
            preferredSize: chosenConditionsStrings.isEmpty? const Size.fromHeight(105) : const Size.fromHeight(118) ,
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 4),
                    color: Colors.white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                          child: SizedBox(
                            height: 50,
                            child: Row(
                              children: const [
                                Text('縣市', style: TextStyle(fontSize: 17),),
                                Icon(Icons.arrow_drop_down),
                              ],
                            ),
                          ),
                          onTap: () async {
                            final String? city = await showDialog<String>(
                            context: context,
                            builder: (BuildContext context) {
                              return CityDialog();
                            });
                            if(city!=null){
                              setState(() {
                                if(chosenCityString==null){
                                  chosenConditionsStrings.add(city);
                                  chosenCityString = city;
                                }else if (chosenCityString != city){
                                  chosenConditionsStrings.remove(chosenCityString);
                                  chosenConditionsStrings.add(city);
                                  chosenCityString = city;
                                }
                                int theCityId = City.getIdFromCityName(chosenCityString!);
                                paramCity = theCityId;

                                isLoading = true;
                                _getCaseList(paramCity, paramStartDate, paramCareType);
                              });
                            }
                          },
                        ),
                        GestureDetector(
                          child: Row(
                            children: const [
                              Text('開始日期',style: TextStyle(fontSize: 17),),
                              Icon(Icons.arrow_drop_down),
                            ],
                          ),
                          onTap: () async {
                            final String? date = await showDialog<String>(
                                context: context,
                                builder: (BuildContext context) {
                                  return getDateRangePicker();
                                });
                            if(date!=null){
                              setState(() {
                                if(chosenDurationDateString==null){
                                  chosenConditionsStrings.add(date);
                                  chosenDurationDateString = date;
                                }else if (chosenDurationDateString != date){
                                  chosenConditionsStrings.remove(chosenDurationDateString);
                                  chosenConditionsStrings.add(date);
                                  chosenDurationDateString = date;
                                }

                                isLoading = true;
                                _getCaseList(paramCity, paramStartDate, paramCareType);
                              });
                            }
                          },
                        ),
                        GestureDetector(
                          child: Row(
                            children: const [
                              Text('看護類型', style: TextStyle(fontSize: 17),),
                              Icon(Icons.arrow_drop_down),
                            ],
                          ),
                          onTap: () async {
                            final String? careType = await showDialog<String>(
                                context: context,
                                builder: (BuildContext context) {
                                  return CareTypeDialog();
                                });
                            if(careType!=null){
                              setState(() {
                                if(chosenCareTypeString==null){
                                  chosenConditionsStrings.add(careType);
                                  chosenCareTypeString = careType;
                                }else if (chosenCareTypeString != careType){
                                  chosenConditionsStrings.remove(chosenCareTypeString);
                                  chosenConditionsStrings.add(careType);
                                  chosenCareTypeString = careType;
                                }
                                if(chosenCareTypeString == '居家照顧'){
                                  paramCareType = 'home';
                                }else if (chosenCareTypeString == '醫院看護'){
                                  paramCareType = 'hospital';
                                }

                                isLoading = true;
                                _getCaseList(paramCity, paramStartDate, paramCareType);
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: (chosenConditionsStrings.isNotEmpty),
                    child: Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 8),
                      color: const Color(0xffF2F2F2),
                      height: 60,
                      child: ListView.builder(
                          itemCount: chosenConditionsStrings.length,
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          itemBuilder: (BuildContext context,int i){
                            return Container(
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.only(left: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.grey),
                              ),
                              child: Row(
                                children: [
                                  Text(chosenConditionsStrings[i], style: const TextStyle(fontSize: 14,color: Colors.grey),),
                                  IconButton(
                                      visualDensity: VisualDensity.comfortable,
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(Icons.clear,size: 16,color: Colors.grey,),
                                      onPressed:(){
                                        setState(() {
                                          if(chosenConditionsStrings[i] == chosenCareTypeString){
                                            chosenCareTypeString = null;
                                            paramCareType = null;
                                          }
                                          if(chosenConditionsStrings[i] == chosenCityString){
                                            chosenCityString = null;
                                            paramCity = null;
                                          }
                                          if(chosenConditionsStrings[i] == chosenDurationDateString){
                                            chosenDurationDateString = null;
                                            paramStartDate = null;
                                            // paramEndDate = null;
                                          }
                                          chosenConditionsStrings.removeAt(i);

                                          isLoading = true;
                                          _getCaseList(paramCity, paramStartDate, paramCareType);
                                        });
                                      }
                                  ),
                                ],
                              ),
                            );
                          }),
                    ),
                  ),
                  const Divider(height: 2,),
                  TextButton(
                    child: const Text('馬上填寫需求單',style: TextStyle(decoration: TextDecoration.underline, color: AppColor.purple, fontSize: 15),),
                    onPressed: (){
                      var userModel = context.read<UserModel>();
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
                  const SizedBox(height: 0),
                  const Divider(height: 0,),
                ],
              ),
            ),
          ),
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
      body:(isLoading)?
      const Center(child: CircularProgressIndicator())
          :
      (newCaseList.isNotEmpty)?
      Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          const SizedBox(height: 0),
          Expanded(
            child: ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: newCaseList.length,
                itemBuilder: (BuildContext context,int i){
                  careWeekDay(int i){
                    List<String> weekDays = newCaseList[i].weekday!.split(',');
                    List<String> careDays = [];
                    for (var day in weekDays){
                      if(day == '1' || day == '星期一'){
                        careDays.add('一');
                      }
                      if(day == '2'|| day == '星期二'){
                        careDays.add('二');
                      }
                      if(day == '3'|| day == '星期三'){
                        careDays.add('三');
                      }
                      if(day == '4'|| day == '星期四'){
                        careDays.add('四');
                      }
                      if(day == '5'|| day == '星期五'){
                        careDays.add('五');
                      }
                      if(day == '6'|| day == '星期六'){
                        careDays.add('六');
                      }
                      if(day == '0'|| day == '星期日'){
                        careDays.add('日');
                      }
                    }
                    return careDays.join(', ');
                  }
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      children: [
                        Center(
                          child: Container(
                              width: 320,
                              // color: Colors.lightBlue,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        newCaseList[i].careType == '居家照顧' ? CustomTag.homeCare : CustomTag.hospitalCare,
                                        const SizedBox(width: 6,),
                                        newCaseList[i].isContinuousTime == true ? CustomTag.continuousTime : CustomTag.weeklyTime
                                      ],),
                                    const SizedBox(height: 10,),
                                    newCaseList[i].isContinuousTime == true
                                        ? Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('開始日期：${newCaseList[i].startDatetime!}(${Case.getTime(newCaseList[i].startTime!)})'),
                                        Text('結束日期：${newCaseList[i].endDatetime!}(${Case.getTime(newCaseList[i].endTime!)})'),
                                        Row(
                                          // mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(City.getCityNameFromId(newCaseList[i].city!),),
                                            (newCaseList[i].county!=null)?Text(County.getCountyNameFromId(newCaseList[i].county!)):Container(),
                                            Text(' ${_getRoadOrHospitalName(newCaseList[i])}'),
                                          ],
                                        ),
                                      ],
                                    )
                                        : Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('開始日期：${newCaseList[i].startDatetime!}'),
                                        Text('結束日期：${newCaseList[i].endDatetime!}'),
                                        Text('星期：星期${careWeekDay(i)}'),
                                        // Text('星期：星期${careWeekDay(i)!=''?careWeekDay(i):newCaseList[i].weekday!}'),
                                        Text('時段：${Case.getTime(newCaseList[i].startTime!)} ~ ${Case.getTime(newCaseList[i].endTime!)}'),
                                        Row(
                                          // mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(City.getCityNameFromId(newCaseList[i].city!),),
                                            (newCaseList[i].county!=null)?Text(County.getCountyNameFromId(newCaseList[i].county!)):Container(),
                                            Text(' ${_getRoadOrHospitalName(newCaseList[i])}'),
                                          ],
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              )
                          ),
                        ),
                        const Divider(
                          color: Color(0xffC0C0C0),
                        ),
                      ],
                    ),
                    onTap: (){
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SearchCaseDetailPage(theCase: newCaseList[i]),));
                    },
                  );
                }
            ),
          ),
        ],
      )
          :
      const Center(
        child: Text('此搜索條件無案件資料！'),
      ),
    );
  }


  String _getRoadOrHospitalName(Case theCase){
    if(theCase.careType=='居家照顧'){
      if(theCase.roadName!=null){
        return theCase.roadName!;
      }else{
        return '';
      }
    }else{
      if(theCase.hospitalName!=null){
        return theCase.hospitalName!;
      }else{
        return '';
      }
    }
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
            // enablePastDates: false,
            minDate: DateTime.now().add(Duration(days: 1)),
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
            // selectionMode: DateRangePickerSelectionMode.range,
            selectionMode: DateRangePickerSelectionMode.single,
            // minDate: DateTime.now(),
            onSelectionChanged: selectionChanged,
            showActionButtons: true,
            cancelText: '取消',
            confirmText: '確定',
            onSubmit: (Object? value) {
              print('chosen duration: ${value}');
              // String? dateDuration = '${DateFormat('MM / dd').format(startDate)} ~ ${DateFormat('MM / dd').format(endDate)}';
              if(value == null){
                startDate = DateTime.now().add(const Duration(days: 1));
              }
              String? dateDuration = '${DateFormat('MM / dd').format(startDate)} 之後';
              setState(() {
                paramStartDate= DateFormat('yyyy-MM-dd').format(startDate);
                // paramEndDate= DateFormat('yyyy-MM-dd').format(endDate);
              });
              // Navigator.pop(context,dateDuration);
              Navigator.pop(context,dateDuration);
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
    //點開 dialog 後有四個可能：
    //一個是 change 日期但沒按確定
    //一個是 change 日期後按確定
    //一個是 什麼都不點就按確定
    //一個是 什麼都不點就關掉
    // 分成 change value 有值 和 沒值
    // if(change value 有值){
    //  if(change value 等於今天){
    //    change value 的日期要加一天
    //  } else {
    //    change value = change value}
    // } else {
    //  change value 沒值，change value = 明天的日期
    // }
    setState(() {
      DateFormat formatter = DateFormat('yyyy-MM-dd');
      String formattedStartDate = formatter.format(startDate);
      String formattedArgValue = formatter.format(args.value);
      if(args.value!= null){
        if(formattedArgValue == formattedStartDate){
          startDate = DateTime.now().add(const Duration(days: 1));
        } else {
          startDate = args.value;
        }
      } else {
        startDate = args.value;
      }
    });
  }

  //city=6, start_datetime=2022-07-10&end_datetime=2022-08-05&care_type=hospital
  Future _getCaseList(int? cityId, String? startDatetime, String? careType) async {
    String path = ServerApi.PATH_SEARCH_CASES;
    // try {
      var mapParams = Map<String, String>();
      if(cityId != null){
        mapParams['city'] = cityId.toString();
      }
      if(startDatetime!=null){
        mapParams['start_datetime'] = startDatetime;
      }
      // if(endDatetime!=null){
      //   mapParams['end_datetime'] = endDatetime;
      // }
      if(careType!=null){
        mapParams['care_type'] = careType;
      }

      final response = await http.get(ServerApi.standard(path: path, queryParameters: mapParams));
      if (response.statusCode == 200) {
        // print(response.body);
        List<dynamic> parsedListJson = json.decode(utf8.decode(response.body.runes.toList()));
        List<Case> data = List<Case>.from(parsedListJson.map((i) => Case.fromJson(i)));
        newCaseList = data;
        setState(() {
          isLoading = false;
        });
      }
    // } catch (e) {
    //   print(e);
    // }
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
}
