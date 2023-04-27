import 'dart:core';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttercare168/constant/color.dart';
import 'package:fluttercare168/constant/server_api.dart';
import 'package:fluttercare168/models/user_week_day_time.dart';
import 'package:fluttercare168/notifier_model/service_model.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../notifier_model/user_model.dart';
import '../../../models/language.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class MyServiceSettingBasic extends StatefulWidget {
  const MyServiceSettingBasic({Key? key}) : super(key: key);

  @override
  _MyServiceSettingBasicState createState() => _MyServiceSettingBasicState();
}

extension TimeOfDayConverter on TimeOfDay {
  String to24hours() {
    final hour = this.hour.toString().padLeft(2, "0");
    final min = this.minute.toString().padLeft(2, "0");
    return "$hour:$min";
  }
}

class _MyServiceSettingBasicState extends State<MyServiceSettingBasic> {

  Gender?  _gender;

  List<String> weekDays = ['一', '二', '三', '四', '五', '六', '日']; //UI要用到的七個Row

  TimeOfDay initialStartTime = const TimeOfDay(hour: 0, minute: 0); //UI預設時段
  TimeOfDay initialEndTime = const TimeOfDay(hour: 24, minute: 0);

  List<String> allLanguages = []; //UI顯示的所有 languages

  TextEditingController otherLanController = TextEditingController();
  TextEditingController indigenousLanController = TextEditingController();

  bool isLoading = false;

  double? oldStartTime;
  double? oldEndTime;

  @override
  void initState() {
    super.initState();
    allLanguages = Language.getLanguageNames();
    var serviceModel = context.read<ServiceModel>();
    if(serviceModel.checkUserWeekDayTimes.isEmpty){
      isLoading = true;
      getWeekDayTimesList();
      getLanguageList();
    }

    var userModel = context.read<UserModel>();
    if(serviceModel.gender == null ){
      if(userModel.user!.gender =='M'){
        serviceModel.gender = Gender.male;
      } else if(userModel.user!.gender =='F'){
        serviceModel.gender = Gender.female;
      }
    }

  }

  @override
  Widget build(BuildContext context) {
    var serviceModel = context.read<ServiceModel>();
    if (serviceModel.checkUserWeekDayTimes.where((element) => element.isChecked == true).isEmpty){
      serviceModel.isContinuousTime = true;
    }else{
      serviceModel.isContinuousTime = false;
    }

    if(isLoading){
      return const Center(child:CircularProgressIndicator());
    } else {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('您的性別', style: TextStyle(fontWeight: FontWeight.bold),),
              Row(
                children: [
                  SizedBox(
                    width: 30,
                    child: Radio<Gender>(
                      activeColor: Colors.black54,
                      value: Gender.male,
                      groupValue: serviceModel.gender,
                      onChanged: (Gender? value) {
                        setState(() {
                          _gender = value!;
                          Provider.of<ServiceModel>(context, listen: false).changeServiceGender(_gender!);
                        });
                      },
                    ),
                  ),
                  const Text('男'),
                  const SizedBox(width: 10,),
                  SizedBox(
                    width: 30,
                    child: Radio<Gender>(
                      activeColor: Colors.black54,
                      value: Gender.female,
                      groupValue: serviceModel.gender,
                      onChanged: (Gender? value) {
                        setState(() {
                          _gender = value!;
                          Provider.of<ServiceModel>(context, listen: false).changeServiceGender(_gender!);
                        });
                      },
                    ),
                  ),
                  const Text('女')
                ],
              ), //性別
              const SizedBox(height: 10,),
              const Text('服務時段', style: TextStyle(fontWeight: FontWeight.bold),),
              const SizedBox(height: 10,),
              Row(
                children: [
                  SizedBox(
                    width: 30,
                    height: 30,
                    child: Checkbox(
                      checkColor:Colors.white,
                      activeColor: AppColor.purple,
                      //如果都沒有任何時段 check, 就是所有時段皆可
                      value: serviceModel.checkUserWeekDayTimes.where((element) => element.isChecked == true).isEmpty,
                      onChanged: (bool? value){
                        print(value);
                        if(value == true){
                          //如果任何時段皆可, 則其他時段 check 無作用
                          for(var item in serviceModel.checkUserWeekDayTimes){
                            item.isChecked = false;
                          }
                        }else{
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("請直接勾選您可以服務的時段！")));
                        }
                        setState(() {});
                      },
                    ),
                  ),
                  const Text('任何時段皆可'),
                ],
              ),
              showWeekDays(serviceModel.checkUserWeekDayTimes),
              const SizedBox(height: 16,),
              const Text('可溝通語言', style: TextStyle(fontWeight: FontWeight.bold),),
              const SizedBox(height: 10,),
              showLanguageCheckBoxes(),
            ],
          ),
        ),
      );
    }
  }

  showWeekDays(List<CheckUserWeekDayTime> weekDayTimes){
    List<Row> weekDayTimeRowList = [];
    weekDayTimes.asMap().forEach((index, weekDayTime) {
      weekDayTimeRowList.add(Row(
        children: [
          SizedBox(
            width: 30,
            height: 30,
            child: Checkbox(
              checkColor:Colors.white,
              activeColor: AppColor.purple,
              value: weekDayTime.isChecked,
              onChanged: (bool? value){
                setState(() {
                  weekDayTime.isChecked = value;
                });
              },
            ),
          ),
          Text('週${weekDays[index]}，時段：'),
          GestureDetector(
            child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color:  const Color(0xffE5E5E5)
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 4),
                child: Text(getStartTime(int.parse(weekDayTime.userWeekDayTime!.weekday!)))
            ),
            onTap: (){
              pickStartTime(context, int.parse(weekDayTime.userWeekDayTime!.weekday!));
            },
          ),
          const Text('  ~  '),
          GestureDetector(
            child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color:  const Color(0xffE5E5E5)
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 4),
                child: Text(getEndTime(int.parse(weekDayTime.userWeekDayTime!.weekday!)))
            ),
            onTap: (){
              pickEndTime(context,int.parse(weekDayTime.userWeekDayTime!.weekday!));
            },
          ),
        ],
      ));
    });
    return Column(children: weekDayTimeRowList,);
  }

  getTimeDoubleToString(double time){
    var hour = time.floor();
    double minute = time - hour;
    String theMinute =  (minute * 60).toStringAsFixed(0);
    if(theMinute == '0'){
      String theTime = '${hour.toString().padLeft(2, "0")}:00';
      return theTime;
    } else {
      String theTime = '${hour.toString().padLeft(2, "0")}:$theMinute';
      return theTime;
    }
  }

  String getStartTime(int weekDay){
    //顯示的時間
    var serviceModel = context.read<ServiceModel>();
    for(var item in serviceModel.checkUserWeekDayTimes){
      if(int.parse(item.userWeekDayTime!.weekday!) == weekDay){
        return getTimeDoubleToString(item.userWeekDayTime!.startTime!);
      }
    }
    return initialStartTime.to24hours();
  }

  String getEndTime(int weekDay){
    var serviceModel = context.read<ServiceModel>();
    for(var item  in serviceModel.checkUserWeekDayTimes){
      if(int.parse(item.userWeekDayTime!.weekday!) == weekDay){
        return getTimeDoubleToString(item.userWeekDayTime!.endTime!);
      }
    }
    return initialEndTime.to24hours();
  }

  Future<void> pickStartTime(BuildContext context, int weekDay) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialStartTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null && picked != initialStartTime) {

      var serviceModel = context.read<ServiceModel>();
      CheckUserWeekDayTime checkUserWeekDayTime = serviceModel.checkUserWeekDayTimes.where((element) => int.parse(element.userWeekDayTime!.weekday!) == weekDay).first;
      // print(checkUserWeekDayTime.userWeekDayTime!.weekday!);
      checkUserWeekDayTime.userWeekDayTime!.startTime = picked.hour + picked.minute/60;

      setState(() {});
    }
  }

  TimeOfDay stringToTimeOfDay(String tod) {
    final format = DateFormat.Hm();
    return TimeOfDay.fromDateTime(format.parse(tod));
  }

  Future<void> pickEndTime(BuildContext context, int weekDay) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialEndTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null && picked != initialEndTime) {
      var serviceModel = context.read<ServiceModel>();
      CheckUserWeekDayTime checkUserWeekDayTime = serviceModel.checkUserWeekDayTimes.where((element) => int.parse(element.userWeekDayTime!.weekday!) == weekDay).first;
      // print(checkUserWeekDayTime.userWeekDayTime!.weekday!);
      checkUserWeekDayTime.userWeekDayTime!.endTime = picked.hour + picked.minute/60;

      setState(() {});
    }
  }

  Wrap showLanguageCheckBoxes(){
    List<Wrap> boxes = [];
    for(var i = 1; i<= allLanguages.length; i++){
      // i=5; 原住民語 // i=8; 其他
      if(i==5){
        boxes.add(Wrap(
          spacing: -8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Checkbox(
                checkColor:Colors.white,
                activeColor: AppColor.purple,
                value: checkIsLanguageChecked(i),
                onChanged: (bool? value){
                  setState(() {
                    onChangedIsLanguageChecked(i,checkIsLanguageChecked(i));
                  });
                }),
            Text(allLanguages[i-1]),
            Container(
              width: 120,
              height: 40,
              margin: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
              child: TextField(
                controller: indigenousLanController,
                onChanged: (text){
                  var serviceModel = context.read<ServiceModel>();
                  if(serviceModel.checkedUserLanguages.where((element) => element.language==5).isNotEmpty){
                    serviceModel.checkedUserLanguages.where((element) => element.language==5).first.remark = text;
                  }
                },
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 0.0,horizontal: 10),
                  border: OutlineInputBorder(
                      borderRadius:BorderRadius.all(Radius.circular(3),),
                      borderSide: BorderSide.none
                  ),
                  filled: true,
                  fillColor: Color(0xffE5E5E5),
                ),
              ),
            ),
          ],
        ));
      } else if (i == 8){
        boxes.add(Wrap(
          spacing: -8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Checkbox(
                checkColor:Colors.white,
                activeColor: AppColor.purple,
                value: checkIsLanguageChecked(i),
                onChanged: (bool? value){
                  setState(() {
                    onChangedIsLanguageChecked(i,checkIsLanguageChecked(i));
                  });
                }),
            Text(allLanguages[i-1]),
            Container(
              width: 120,
              height: 40,
              margin: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
              child: TextField(
                controller: otherLanController,
                onChanged: (text){
                  var serviceModel = context.read<ServiceModel>();
                  if(serviceModel.checkedUserLanguages.where((element) => element.language==8).isNotEmpty){
                    serviceModel.checkedUserLanguages.where((element) => element.language==8).first.remark = text;
                  }
                },
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 0.0,horizontal: 10),
                  border: OutlineInputBorder(
                      borderRadius:BorderRadius.all(Radius.circular(3),),
                      borderSide: BorderSide.none
                  ),
                  filled: true,
                  fillColor: Color(0xffE5E5E5),
                ),
              ),
            ),
          ],
        ));
      } else {
        boxes.add(Wrap(
          spacing: -8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              height: 60,
              child: Checkbox(
                  checkColor:Colors.white,
                  activeColor: AppColor.purple,
                  value: checkIsLanguageChecked(i),
                  onChanged: (bool? value){
                    setState(() {
                      onChangedIsLanguageChecked(i,checkIsLanguageChecked(i));
                    });
                  }),
            ),
            Text(allLanguages[i-1])
          ],
        ));
      }
    }
    return Wrap(
      children: boxes,
    );
  }

  checkIsLanguageChecked(int languageChoice){
    var serviceModel = context.read<ServiceModel>();
    for(var choice in serviceModel.checkedUserLanguages){
      if(choice.language == languageChoice){
        return true;
      }
    }
    return false;
  }

  onChangedIsLanguageChecked(int languageChoice, bool? value){
    var serviceModel = context.read<ServiceModel>();
    if (value! == true){
      serviceModel.checkedUserLanguages.removeWhere((element) => element.language! == languageChoice);
      value = false;
    } else if (value == false){
      serviceModel.checkedUserLanguages.add(Language(language: languageChoice));
      value = true;
    }
  }

  Future getWeekDayTimesList()async{
    var userModel = context.read<UserModel>();
    String path = ServerApi.PATH_USER_WEEK_DAY_TIMES;
    try {
      final response = await http.get(ServerApi.standard(path: path),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'Authorization': 'token ${userModel.token!}'},
      );
      if (response.statusCode == 200) {

        List<dynamic> parsedListJson = json.decode(utf8.decode(response.body.runes.toList()));
        List<UserWeekDayTime> checkedUserWeekDayTimes = List<UserWeekDayTime>.from(parsedListJson.map((i) => UserWeekDayTime.fromJson(i)));

        var serviceModel = context.read<ServiceModel>();

        //add 7 week_day_time to service model
        for(var i=1; i<=7 ; i++){
          //weekday = 1, 2, 3, 4, 5, 6, 0
          //int.parse("0"), "1", int.parse("2"), "3"
          // [checkUserWeekDayTime(1), 2, 3, 4, 5, 6, 7]
          int weekday = 0;
          if(i!=7){
            weekday = i;
          }

          if(checkedUserWeekDayTimes.where((element) => int.parse(element.weekday!) == weekday).isEmpty){
            serviceModel.checkUserWeekDayTimes.add(
              CheckUserWeekDayTime(isChecked: false, userWeekDayTime: UserWeekDayTime(weekday: weekday.toString(), startTime: 0.0, endTime: 24.0) )
            );
          }else{
            serviceModel.checkUserWeekDayTimes.add(
              CheckUserWeekDayTime(isChecked: true, userWeekDayTime: checkedUserWeekDayTimes.firstWhere((element) => int.parse(element.weekday!) == weekday))
            );
          }

        }

        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future getLanguageList()async{
    var userModel = context.read<UserModel>();
    String path = ServerApi.PATH_USER_LANGUAGES;
    try {
      final response = await http.get(ServerApi.standard(path: path),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'Authorization': 'token ${userModel.token!}'},
      );
      if (response.statusCode == 200) {

        List<dynamic> parsedListJson = json.decode(utf8.decode(response.body.runes.toList()));
        List<Language> languanges = List<Language>.from(parsedListJson.map((i) => Language.fromJson(i)));

        var serviceModel = context.read<ServiceModel>();
        serviceModel.checkedUserLanguages= languanges;

        for(var choice in serviceModel.checkedUserLanguages){
          if(choice.language == 5){
            //原住民語
            indigenousLanController.text = choice.remark!;
          }
          if(choice.language == 8 ){
            //其他
            otherLanController.text = choice.remark!;
          }
        }
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print(e);
    }
  }
}
