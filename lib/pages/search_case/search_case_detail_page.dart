import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttercare168/constant/review_stars.dart';
import 'package:fluttercare168/models/body_condition.dart';
import 'package:fluttercare168/models/user.dart';
import 'package:fluttercare168/widgets/custom_elevated_button.dart';
import 'package:fluttercare168/constant/color.dart';
import 'package:fluttercare168/constant/custom_tag.dart';
import 'package:fluttercare168/models/case.dart';
import 'package:fluttercare168/models/city.dart';
import 'package:fluttercare168/models/county.dart';
import 'package:fluttercare168/constant/server_api.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttercare168/models/service.dart';
import 'package:provider/provider.dart';
import '../../../../constant/custom_tag.dart';
import '../../models/disease_condition.dart';
import '../../notifier_model/user_model.dart';
import '../member/register/login_register.dart';

class SearchCaseDetailPage extends StatefulWidget {
  final Case theCase;
  const SearchCaseDetailPage({Key? key, required this.theCase}) : super(key: key);

  @override
  _SearchCaseDetailPageState createState() => _SearchCaseDetailPageState();
}

class _SearchCaseDetailPageState extends State<SearchCaseDetailPage> {

  Map<String, dynamic> searchCaseDetailMap = {};
  late Case searchCase;
  List<Service> searchCaseServices = [];
  List<DiseaseCondition> searchCaseDiseaseConditions = [];
  List<BodyCondition> searchCaseBodyConditions = [];
  List<String> searchCaseDiseaseNames = [];
  List<String> searchCaseConditionNames = [];
  List<String> searchCaseWeekDays = [];
  late User searchUser;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getSearchedCaseDetail();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        shadowColor: Colors.black26,
        title: const Text('案件資料'),),
      body: searchCaseDetailMap.isEmpty
          ? const Center(child: CircularProgressIndicator())
          :SingleChildScrollView(
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20,),
              Row(
                children: [
                  checkUserImage(searchUser.image),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('委託人'),
                            Padding(
                              padding: const EdgeInsets.only(right: 20),
                              child: searchCase.isTaken == false ? CustomTag.caseOpen : CustomTag.caseClosed ,
                            )
                        ],),
                        Text( _getMrOrMSString(searchUser.name!, searchUser.gender!),style: const TextStyle(fontSize: 20),),
                        Wrap(
                          children: [
                            ReviewStars.getReviewStars(searchCase.avgOffenderRating!),
                            const SizedBox(width: 10,),
                            Text('(評價${searchCase.numOffenderRating!})')
                        ],)
                    ],),
                  )
                ],
              ),
              const SizedBox(height: 10,),
              kRowContent('案件類型', '${searchCase.careType}'),
              kRowContent('案件地點', '${City.getCityNameFromId(searchCase.city!)} ${County.getCountyNameFromId(searchCase.county!)} ${_getRoadOrHospitalName()}'),
              caseTime(),
              const Divider(
                indent: 20,
                endIndent: 20,
                thickness: 0.5,
                color: AppColor.darkGrey,
              ),
              const SizedBox(height: 10,),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text('被照顧者資訊',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold, color: AppColor.purple),),
              ),
              (searchCase.gender=='M')?kRowContent('性別', '男'):kRowContent('性別', '女'),
              kRowContent('年齡', '${searchCase.age} 歲'),
              kRowContent('體重', '${searchCase.weight} 公斤'),
              kRowContent('疾病', (searchCaseDiseaseNames.isNotEmpty)?searchCaseDiseaseNames.join(','):'無'),
              kRowContent('補充說明', (searchCase.diseaseRemark==null)?'無':'${searchCase.diseaseRemark}'),
              kRowContent('身體狀況', (searchCaseConditionNames.isNotEmpty)?searchCaseConditionNames.join(','):'無'),
              kRowContent('補充說明', (searchCase.conditionsRemark==null)?'無':'${searchCase.conditionsRemark}'),
              const SizedBox(height: 10,),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text('需求服務項目',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold, color: AppColor.purple),),
              ),
              const SizedBox(height: 10,),
              neededServices(),
              Center(
                child: CustomElevatedButton(
                  text: '我可以接案',
                  color: AppColor.purple,
                  onPressed: (){
                    var userModel = context.read<UserModel>();
                    if(userModel.isLogin()){
                      _postApplyCase(searchCase.id!, userModel.token!);
                    } else {
                      if(searchUser.id != userModel.user!.id){
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginRegister(),
                            ));
                      }else{
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("不能接自己的案子！"),));
                      }
                    }
                  },
                ),
              ),
              const SizedBox(height: 40,),
            ],
        ),
      ),
    );
  }

  String _getRoadOrHospitalName(){
    if(searchCase.careType=='居家照顧'){
      if(searchCase.roadName!=null){
        return searchCase.roadName!;
      }else{
        return '';
      }
    }else{
      if(searchCase.hospitalName!=null){
        return searchCase.hospitalName!;
      }else{
        return '';
      }
    }
  }

  String _getMrOrMSString(String userName, String gender){
    print(gender);
    if(gender == '男'){
      return userName.substring(0,1) + '先生';
    }else{
      return userName.substring(0,1) + '小姐';
    }
  }

  checkUserImage(String? imgPath) {
    if (imgPath == null || imgPath == '') {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
        height: 90,
        width: 90,
        decoration: const BoxDecoration(shape: BoxShape.circle),
        child: const Icon(Icons.account_circle_rounded, size: 64, color: Colors.grey,),
      );
    } else {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
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

  careWeekDay(){
    List<String> weekDays = searchCase.weekday!.split(',');
    List<String> careDays = [];
    for (var day in weekDays){
      if(day == '1'){
        careDays.add('星期一');
      }
      if(day == '2'){
        careDays.add('星期二');
      }
      if(day == '3'){
        careDays.add('星期三');
      }
      if(day == '4'){
        careDays.add('星期四');
      }
      if(day == '5'){
        careDays.add('星期五');
      }
      if(day == '6'){
        careDays.add('星期六');
      }
      if(day == '0'){
        careDays.add('星期日');
      }
    }
    return careDays.join(', ');
  }

  caseTime(){
    if(searchCase.isContinuousTime == true){
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 4),
            child: Row(
              children: [
                const Text('案件時間  '),
                searchCase.isContinuousTime == true ? const Text('連續時間',style: TextStyle(color: Colors.red),): const Text('指定時段',style: TextStyle(color: Colors.red),),
              ],
            ),
          ),
          Row(
            children: [
              const Expanded(flex:2,child:SizedBox(),),
              Expanded(flex:7,child: Text('開始：'+ searchCase.startDatetime!+'('+ Case.getTime(searchCase.startTime!)+')\n結束：' + searchCase.endDatetime!+'('+ Case.getTime(searchCase.endTime!)+')')),
            ],
          ),
          ],
      );
    } else if (searchCase.isContinuousTime == false){
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 4),
            child: Row(
              children: [
                const Text('案件時間  '),
                searchCase.isContinuousTime == true ? const Text('連續時間',style: TextStyle(color: Colors.red),): const Text('指定時段',style: TextStyle(color: Colors.red),),
              ],
            ),
          ),
          Row(
            children: [
              const Expanded(flex:2,child:SizedBox(),),
              Expanded(flex:7,child: Text('${searchCase.startDatetime} ~ ${widget.theCase.endDatetime}'),)
            ],
          ),
          Row(
            children: [
              const Expanded(flex:2,child:SizedBox(),),
              (careWeekDay()!='')?
              Expanded(flex:7,child: Text(careWeekDay()),)
                  :
              Expanded(flex:7,child: Text(searchCase.weekday!),)
            ],
          ),
          Row(
            children: [
              const Expanded(flex:2,child:SizedBox(),),
              Expanded(flex:7,child: Text('${Case.getTime(searchCase.startTime!)} ~ ${Case.getTime(searchCase.endTime!)}')),
            ],
          ),
        ],
      );
    }
  }

  kRowContent(String title, String text){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 4),
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

  kNeededService(String text){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          const SizedBox(width: 20,),
          CustomTag.iconYes,
          const SizedBox(width: 10,),
          Text(text)
        ],
      ),
    );
  }

  neededServices(){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: searchCaseServices.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTag.iconYes,
                  const SizedBox(width: 10,),
                  searchCaseServices[index].remark != null ?
                  Expanded(
                      child: RichText(
                        text: TextSpan(
                          text: searchCaseServices[index].name,
                          style: DefaultTextStyle.of(context).style,
                          children: [
                            TextSpan(text: '\n'+_checkToChangeLine(searchCaseServices[index].remark!), style: const TextStyle(color: AppColor.darkGrey)),
                          ],
                        ),
                      )
                  )
                      : Text(searchCaseServices[index].name!),
                ],
              ),
              const SizedBox(height: 5),
            ],
          );
        },
      ),
    );
  }

  String _checkToChangeLine(String text){
    return text.replaceAll('※', '\n※');
  }

  Future _getSearchedCaseDetail() async {
    String path = ServerApi.PATH_SEARCH_CASES+widget.theCase.id.toString();
    try {
      final response = await http.get(ServerApi.standard(path: path),);
      if (response.statusCode == 200) {
        Map<String, dynamic> map = json.decode(utf8.decode(response.body.runes.toList()));
        searchCaseDetailMap = map;
        searchCase = Case.fromJson(searchCaseDetailMap);
        searchCaseServices = List<Service>.from(searchCaseDetailMap['services'].map((i) => Service.fromJson(i)));
        searchCaseDiseaseConditions = List<DiseaseCondition>.from(searchCaseDetailMap['disease'].map((i) => DiseaseCondition.fromJson(i)));
        searchCaseBodyConditions = List<BodyCondition>.from(searchCaseDetailMap['body_condition'].map((i) => BodyCondition.fromJson(i)));
        searchUser = User.fromJson(searchCaseDetailMap['user_detail']);

        for(var disease in searchCaseDiseaseConditions){
          searchCaseDiseaseNames.add(disease.name!);
        }
        for(var condition in searchCaseBodyConditions){
          searchCaseConditionNames.add(condition.name!);
        }

        setState(() {});
      }
    } catch (e) {
      print(e);
    }
  }

  Future _postApplyCase(int caseId, String token) async {
    String path = ServerApi.PATH_APPLY_CASE;

    try {

      final bodyParameters = {
        'case_id': caseId.toString(),
      };

      final response = await http.post(ServerApi.standard(path: path),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Token $token',
        },
        body: jsonEncode(bodyParameters),
      );

      print(response.statusCode);
      _printLongString(response.body);

      if(response.statusCode == 200){
        Map<String, dynamic> map = json.decode(utf8.decode(response.body.runes.toList()));
        String message = map['message'].toString();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message),));
      }else{
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("系統錯誤，請稍後再試！"),));
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
