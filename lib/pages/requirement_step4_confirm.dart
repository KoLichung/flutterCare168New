import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttercare168/constant/color.dart';
import 'package:fluttercare168/constant/review_stars.dart';
import 'package:fluttercare168/constant/custom_tag.dart';
import 'package:fluttercare168/constant/server_api.dart';
import 'package:fluttercare168/models/carer.dart';
import 'package:fluttercare168/models/city.dart';
import 'package:fluttercare168/models/county.dart';
import 'package:fluttercare168/notifier_model/require_model.dart';
import 'package:fluttercare168/notifier_model/user_model.dart';
import 'package:fluttercare168/pages/search_carer/search_carer_detail.dart';
import 'package:provider/provider.dart';
import 'package:fluttercare168/constant/format_converter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttercare168/constant/enum.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/language.dart';


class RequirementStep4Confirm extends StatefulWidget {
  const RequirementStep4Confirm({Key? key}) : super(key: key);

  @override
  _RequirementStep4ConfirmState createState() => _RequirementStep4ConfirmState();
}

class _RequirementStep4ConfirmState extends State<RequirementStep4Confirm> {

  bool isChecked = false;
  List<CheckServantChoice> searchedCarerList = [];
  // List<String> weekDayStrings = [];
  int? startTime;
  int? endTime;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var requireModel = context.read<RequireModel>();
    startTime = int.parse(requireModel.startTime.to24hours().substring(0,2));
    endTime = int.parse(requireModel.endTime.to24hours().substring(0,2));
    _getServantList();
  }
  @override
  Widget build(BuildContext context) {
    var requireModel = context.read<RequireModel>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('填寫需求單'),
        actions: [
          TextButton(
              child: const Text('取消需求單',style: TextStyle(color: Colors.white),) ,
              onPressed: (){
                Navigator.of(context).popUntil((route) => route.isFirst);
                requireModel.clearRequireModelData();
              })
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomTag.requirementStep4,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20,),
                  kSectionTitle('您的需求'),
                  kRowContent('需求類型', (requireModel.careTypeGroupValue == 0) ? '居家照顧' : '醫院看護'),
                  kRowContent('需求地點', (requireModel.careTypeGroupValue == 0)?'${requireModel.city.name} ${requireModel.district.name} ${requireModel.roadName}':'${requireModel.city.name} ${requireModel.district.name} ${requireModel.hospitalName}'),
                  requireModel.timeType == TimeType.continuous
                    ? kRowContent('需求時間', '連續時間 \n${requireModel.startDate.toString().substring(0,10)}(${requireModel.startTime.to24hours()}) ~ \n${requireModel.endDate.toString().substring(0,10)}(${requireModel.endTime.to24hours()})')
                    : kRowContent('需求時間', '指定時段 \n${requireModel.startDate.toString().substring(0,10)} ~ ${requireModel.endDate.toString().substring(0,10)}\n${getWeekDayStrings()}\n${requireModel.startTime.to24hours()}~${requireModel.endTime.to24hours()}'),
                  kSectionTitle('被照顧者資訊'),
                  requireModel.patientGender == Gender.female
                      ? kRowContent('性別', '女')
                      : kRowContent('性別', '男'),
                  kRowContent('年齡', '${requireModel.patientAge} 歲'),
                  kRowContent('體重', '${requireModel.patientWeight} 公斤'),
                  kRowContent('疾病', checkDisease()),
                  kRowContent('補充說明', '${requireModel.patientDiseaseNote == null ? '無' :requireModel.patientDiseaseNote}  '),
                  kRowContent('身體狀況',  checkBodyIssue()),
                  kRowContent('補充說明', '${requireModel.patientBodyNote == null ? '無' : requireModel.patientBodyNote}'),
                  const SizedBox(height: 10,),
                  kSectionTitle('需求服務項目'),
                  checkBasicService(),
                  kSectionTitle('加價服務項目'),
                  checkExtraService(),
                  const SizedBox(height: 10,),
                  kSectionTitle('被照顧者聯絡人'),
                  const Text('(確認付款預訂完成，接案服務者才可看見此資訊)',style: TextStyle(color: AppColor.grey, fontSize: 14),),
                  const SizedBox(height: 5,),
                  Text('姓名：${requireModel.emergencyContactName}'),
                  Text('與被照顧者關係：${requireModel.emergencyContactRelation}'),
                  Text('聯絡電話：${requireModel.emergencyContactPhone}'),
                  const SizedBox(height: 10,),
                  searchedCarerList.isEmpty
                      ? Container()
                      : Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Text('向服務者發出訂單，詢問是否可以接案\n往右滑點選更多（最多可選擇5位）➡', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold),),
                            ),
                            showRecommendCarers(),
                          ],),
                ],
              ),
              ElevatedButton(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30,vertical: 8),
                  child: Text('確認送出',style: const TextStyle(fontSize: 18),),
                ),
                style: ElevatedButton.styleFrom(primary: AppColor.green, elevation: 0),
                onPressed: (){
                  _postCreateCase();
                },
              ),
              const SizedBox(height: 40,),
            ],
          ),
        ),
      ),
    );
  }

  getWeekDayStrings(){
    List<String> dayStrings = [];
    var requireModel = context.read<RequireModel>();
    for(var day in requireModel.checkWeekDays){
      if(day.isChecked){
        dayStrings.add(day.day);
      }
    }
    return dayStrings.join(',');
  }

  getWeekDayIntStrings(){
    List<String> dayStrings = [];
    var requireModel = context.read<RequireModel>();
    for(var day in requireModel.checkWeekDays){
      if(day.isChecked){
        dayStrings.add(day.weekDay.toString());
      }
    }
    return dayStrings.join(',');
  }

  getWeekDayInts(){
    List<int> weekDayInts = [];
    var userModel = context.read<UserModel>();
    for(var day in userModel.checkWeekDays){
      if(day.day == '星期一' && day.isChecked == true){
        weekDayInts.add(1);
      }
      if(day.day == '星期二' && day.isChecked == true){
        weekDayInts.add(2);
      }
      if(day.day == '星期三' && day.isChecked == true){
        weekDayInts.add(3);
      }
      if(day.day == '星期四' && day.isChecked == true){
        weekDayInts.add(4);
      }
      if(day.day == '星期五' && day.isChecked == true){
        weekDayInts.add(5);
      }
      if(day.day == '星期六' && day.isChecked == true){
        weekDayInts.add(6);
      }
      if(day.day == '星期日' && day.isChecked == true){
        weekDayInts.add(7);
      }
    }
    return weekDayInts;
  }

  kSectionTitle(String title){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold),),
    );

  }

  kRowContent(String title, String text){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(title),
          ),
          Expanded(
            flex: 8,
            child: Text(text),
          ),
        ],
      ),
    );

  }

  checkDisease(){
    var requireModel = context.read<RequireModel>();
    List<String> diseaseNameStrings = [];
    for (var item in requireModel.checkDiseaseChoices){
      if(item.isChecked == true){
        diseaseNameStrings.add(item.diseaseName!);
      }
    }
    if(diseaseNameStrings.isEmpty){
      return '無';
    } else {
      return diseaseNameStrings.join(', ');
    }

  }

  checkBodyIssue(){
    var requireModel = context.read<RequireModel>();
    List<String> bodyIssueStrings = [];
    for (var item in requireModel.checkBodyChoices){
      if(item.isChecked == true){
        bodyIssueStrings.add(item.bodyCondition!);
      }
    }
    if(bodyIssueStrings.isEmpty){
      return '無';
    } else {
      return bodyIssueStrings.join(', ');
    }
  }

  Widget checkBasicService(){
    var requireModel = context.read<RequireModel>();
    List<Column> basicServices = [];
    for (var item in requireModel.checkBasicServiceChoices){
      if(item.isChecked == true){
        basicServices.add(
            Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: CustomTag.iconYes,
                    ),
                    const SizedBox(width: 6,),
                    item.service!.remark == null
                        ? Text(item.service!.name!)
                        : Expanded(child: RichText(
                              text: TextSpan(
                                text: item.service!.name,
                                style: const TextStyle(fontSize: 16, color: Colors.black),
                                children: <TextSpan>[
                                  TextSpan(text: '\n${item.service!.remark}', style: const TextStyle(color: Colors.grey, fontSize: 14)),
                                ],
                              ),
                            ),
                          )
                ],),
                const SizedBox(height: 6,)
              ],
        ));
      }
    }
    return Column(children: basicServices);
  }

  Widget checkExtraService(){
    var requireModel = context.read<RequireModel>();
    List<Column> extraServices = [];
    for (var item in requireModel.checkExtraServiceChoices){
      if(item.isChecked == true){
        extraServices.add(
            Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: CustomTag.iconYes,
                    ),
                    const SizedBox(width: 6,),
                    Text(item.service!.name!),
                  ],),
                const SizedBox(height: 10,)
              ],
            ));
      }
    }
    return Column(children: extraServices);
  }

  showRecommendCarers(){
    return SizedBox(
      height: 520,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: searchedCarerList.length,
          itemBuilder: (BuildContext context,int i){
            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  padding: const EdgeInsets.all(10),
                  height: 470,
                  width: 320,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 1,),
                    borderRadius: BorderRadius.circular(4),),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                          onTap: ()async{
                            Uri url = Uri.parse(ServerApi.getCarerUrl(searchedCarerList[i].servant!.id!).toString());
                            if (!await launchUrl(url)) {
                            throw 'Could not launch $url';
                            }
                          },
                          child: Center(child: checkCarerImage(searchedCarerList[i].servant!.image),)),
                      Center(
                          child: Text(_getMrOrMSString(searchedCarerList[i].servant!.name!,searchedCarerList[i].servant!.gender!), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),)),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ReviewStars.getReviewStars(searchedCarerList[i].servant!.servantAvgRating!),
                            const SizedBox(width: 10,),
                            Text('評價${searchedCarerList[i].servant!.ratingNums}'),
                          ],
                        ),
                      const SizedBox(height: 10,),
                      checkCareType(i),
                      const SizedBox(height: 10,),
                      Container(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          alignment: Alignment.centerLeft,
                          child: Text('溝通語言：\n'+getLauangesString(searchedCarerList[i].servant!.languages!))),
                      Container(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          alignment: Alignment.centerLeft,
                          child: const Text('服務地區：')),
                      Text(checkCarerLocation(searchedCarerList[i].servant!.locations!)),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Checkbox(
                      checkColor:Colors.white,
                      activeColor: AppColor.purple,
                      value: searchedCarerList[i].isChecked,
                      onChanged: (bool? value){
                        if(value!){
                          // 檢查是否超過 5 個 checked
                          if(searchedCarerList.where((element) => element.isChecked == true).length==5){
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("最多只能選 5 位服務員詢問！"),));
                          }else{
                            setState(() {
                              searchedCarerList[i].isChecked = value!;
                            });
                          }
                        }else{
                          setState(() {
                            searchedCarerList[i].isChecked = value!;
                          });
                        }
                      },
                    ),
                    const Text('選擇'),
                  ],
                ),
              ],
            );
          }),
    );
  }

  checkCarerImage(String? imgPath) {
    if (imgPath == null || imgPath == '') {
      return Container(
        margin: const EdgeInsets.all(10),
        height: 90,
        width: 90,
        decoration: const BoxDecoration(shape: BoxShape.circle),
        child: const Icon(Icons.account_circle_rounded, size: 64, color: Colors.grey,),
      );
    } else {
      return Container(
        margin: const EdgeInsets.all(10),
        height: 90,
        width: 90,
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

  checkCareType(int i) {
    if (searchedCarerList[i].servant!.isHome == true && searchedCarerList[i].servant!.isHospital == true) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 6,),
          CustomTag.homeCare,
          const SizedBox(height: 2,),
          Text('時薪\$${_getWageWords(searchedCarerList[i].servant!.homeHourWage!)}｜半天\$${_getWageWords(searchedCarerList[i].servant!.homeHalfDayWage!)}｜全天\$${_getWageWords(searchedCarerList[i].servant!.homeOneDayWage!)}'),
          const SizedBox(height: 6,),
          CustomTag.hospitalCare,
          const SizedBox(height: 2,),
          Text('時薪\$${_getWageWords(searchedCarerList[i].servant!.hospitalHourWage!)}｜半天\$${_getWageWords(searchedCarerList[i].servant!.hospitalHalfDayWage!)}｜全天\$${_getWageWords(searchedCarerList[i].servant!.hospitalOneDayWage!)}'),
        ],
      );
    } else if (searchedCarerList[i].servant!.isHome == true && searchedCarerList[i].servant!.isHospital == false) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children:[CustomTag.homeCare],),
          const SizedBox(height: 10,),
          Text('時薪\$${_getWageWords(searchedCarerList[i].servant!.homeHourWage!)}｜半天 \$${_getWageWords(searchedCarerList[i].servant!.homeHalfDayWage!)}｜全天\$${_getWageWords(searchedCarerList[i].servant!.homeOneDayWage!)}'),
        ],
      );
    } else if (searchedCarerList[i].servant!.isHospital == true && searchedCarerList[i].servant!.isHome == false) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children:[CustomTag.hospitalCare],),
          const SizedBox(height: 10,),
          Text('時薪\$${_getWageWords(searchedCarerList[i].servant!.hospitalHourWage!)}｜半天\$${_getWageWords(searchedCarerList[i].servant!.hospitalHalfDayWage!)}｜全天\$${_getWageWords(searchedCarerList[i].servant!.hospitalOneDayWage!)}'),
        ],
      );
    }
    print('something wrong');
    return Container();
  }

  String _getWageWords(int wage){
    if(wage != 0){
      return wage.toString();
    }else{
      return '無服務';
    }
  }

  getLauangesString(List<Language> languages){
    List<String> languageStrings = [];
    for (var language in languages){
      if(language.remark==null || language.remark==''){
        languageStrings.add('${language.languageName}');
      }else{
        languageStrings.add('${language.languageName}(${language.remark})');
      }
    }
    return languageStrings.join(' ');
  }

  checkCarerLocation(List<Locations> locations) {
    List<String> locationStrings = [];
    var requireModel = context.read<RequireModel>();
    for (var location in locations) {
      if(requireModel.city.id == location.city) {
        locationStrings.add('${City.getCityNameFromId(location.city!)} 交通費\$${location.transferFee!.toString()}\n');
      }
    }
    return locationStrings.join('');
  }

  String _getMrOrMSString(String userName, String gender){
    if(gender == 'M'){
      return userName.substring(0,1) + '先生';
    }else{
      return userName.substring(0,1) + '小姐';
    }
  }

  Future _getServantList() async {
    var requireModel = context.read<RequireModel>();
    String path = ServerApi.PATH_SEARCH_SERVANTS;
    try {
      final response = await http.get(
          ServerApi.standard(path: path, queryParameters: {
            'care_type': requireModel.careTypeGroupValue == 0 ? 'home' : 'hospital',
            'city': requireModel.city.id.toString(),
            'county': requireModel.district.id.toString(),
            'is_continuous_time': requireModel.timeType == TimeType.continuous ? 'true' : 'false',
            'weekdays': getWeekDayInts().toString(),
            'start_end_time':'$startTime:$endTime',
            'start_datetime': requireModel.startDate.toString().substring(0, 10),
            'end_datetime': requireModel.endDate.toString().substring(0, 10),
            'is_random': 'true',
          }
          ));
      if (response.statusCode == 200) {
        // print(response.body);
        List<dynamic> parsedListJson = json.decode(utf8.decode(response.body.runes.toList()));
        List<Carer> data = List<Carer>.from(parsedListJson.map((i) => Carer.fromJson(i)));
        for(var item in data){
          searchedCarerList.add(CheckServantChoice(isChecked: false, servant: item));
        }
        setState(() {});
      }
    } catch (e) {
      print(e);
    }
  }

  Future _postCreateCase() async {
    String path = ServerApi.PATH_CREATE_CASE;

    var userModel = context.read<UserModel>();
    var requireModel = context.read<RequireModel>();

    requireModel.checkDiseaseChoices.removeWhere((element) => element.isChecked==false);
    String diseaseString = requireModel.checkDiseaseChoices.map((item) => item.diseaseId!).toList().toString().replaceAll('[', '').replaceAll(']', '').replaceAll(' ', '');

    requireModel.checkBodyChoices.removeWhere((element) => element.isChecked==false);
    String bodyConditionsString =  requireModel.checkBodyChoices.map((item) => item.bodyConditionId!).toList().toString().replaceAll('[', '').replaceAll(']', '').replaceAll(' ', '');

    requireModel.checkExtraServiceChoices.removeWhere((element) => element.isChecked==false);
    requireModel.checkBasicServiceChoices.removeWhere((element) => element.isChecked==false);
    List<int> serviceIds = requireModel.checkExtraServiceChoices.map((item) => item.serviceId!).toList() + requireModel.checkBasicServiceChoices.map((item) => item.serviceId!).toList();
    String serviceIdString = serviceIds.toString().replaceAll('[', '').replaceAll(']', '').replaceAll(' ', '');

    searchedCarerList.removeWhere((element) => element.isChecked == false);
    String servantIdsString = searchedCarerList.map((item) => item.servant!.id!).toList().toString().replaceAll('[', '').replaceAll(']', '').replaceAll(' ', '');

    try {
      final queryParameters = {
        'county': requireModel.district.id.toString(),
        'start_date': DateFormat('yyyy-MM-dd').format(requireModel.startDate),
        'end_date': DateFormat('yyyy-MM-dd').format(requireModel.endDate),
        'start_time': requireModel.startTime.to24hours(),
        'end_time': requireModel.endTime.to24hours(),
      };

      final bodyParameters = {
        'care_type': (requireModel.careTypeGroupValue==0)?'home':'hospital',
        'is_continuous_time': requireModel.timeType==TimeType.continuous?'true':'false',
        'weekday':getWeekDayIntStrings(),
        'name': requireModel.patientName,
        'gender': requireModel.patientGender==Gender.male?'M':'F',
        'age': requireModel.patientAge!,
        'weight': requireModel.patientWeight!,
        'disease': diseaseString,
        'disease_remark': requireModel.patientDiseaseNote,
        'body_condition': bodyConditionsString,
        'conditions_remark': requireModel.patientBodyNote,
        'service': serviceIdString,
        'emergencycontact_name': requireModel.emergencyContactName,
        'emergencycontact_relation': requireModel.emergencyContactRelation,
        'emergencycontact_phone': requireModel.emergencyContactPhone,
        'servant_ids': servantIdsString,
        'road_name':requireModel.roadName==null?'':requireModel.roadName!,
        'hospital_name':requireModel.hospitalName==null?'':requireModel.hospitalName!,
      };

      final response = await http.post(ServerApi.standard(path: path,queryParameters: queryParameters),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Token ${userModel.token!}',
          },
          body: jsonEncode(bodyParameters),
      );

      print(bodyParameters);
      print(response.statusCode);
      _printLongString(response.body);

      if(response.statusCode == 200){
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("成功發出需求單！"),));
        requireModel.clearRequireModelData();
        Navigator.popUntil(context, (route) => route.isFirst);
      }else{
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("無法產生需求單，請稍後再試！"),));
      }

    } catch (e) {
      print(e);
      return "error";
    }
  }

  void _printLongString(String text) {
    final RegExp pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern.allMatches(text).forEach((RegExpMatch match) =>   print(match.group(0)));
  }

}

class CheckServantChoice{
  bool? isChecked;
  Carer? servant;

  CheckServantChoice({
    required this.isChecked,
    required this.servant,
  });
}
