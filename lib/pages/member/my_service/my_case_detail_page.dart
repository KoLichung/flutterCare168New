import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttercare168/constant/color.dart';
import 'package:fluttercare168/constant/review_stars.dart';
import 'package:fluttercare168/models/body_condition.dart';
import 'package:fluttercare168/models/case.dart';
import 'package:fluttercare168/models/disease_condition.dart';
import 'package:fluttercare168/models/order.dart';
import 'package:fluttercare168/models/service_increase_money.dart';
import 'package:fluttercare168/pages/member/my_service/my_case_detail_write_review_dialog.dart';
import 'package:fluttercare168/pages/member/my_service/my_case_detail_read_review_dialog.dart';
import 'package:fluttercare168/models/city.dart';
import 'package:fluttercare168/models/county.dart';
import 'package:fluttercare168/constant/server_api.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttercare168/notifier_model/user_model.dart';
import 'package:provider/provider.dart';
import 'package:fluttercare168/models/service.dart';
import 'package:fluttercare168/models/review.dart';
import '../../../constant/custom_tag.dart';
import 'package:url_launcher/url_launcher.dart';

class MyCaseDetailPage extends StatefulWidget {
  final Case theCase;
  const MyCaseDetailPage({Key? key, required this.theCase}) : super(key: key);
  @override
  _MyCaseDetailPageState createState() => _MyCaseDetailPageState();
}

class _MyCaseDetailPageState extends State<MyCaseDetailPage> {

  Map<String, dynamic> myCaseDetailMap = {};
  Case? myCase;
  List<Service> myCaseServices = [];
  List<DiseaseCondition> myCaseDiseaseConditions = [];
  List<BodyCondition> myCaseBodyConditions = [];
  Review? myCaseReview;
  Order? myCaseOrder;
  List<String> myCaseDiseaseNames = [];
  List<String> myCaseConditionNames = [];

  bool _hasCallSupport = false;
  Future<void>? _launched;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getMyCaseDetail();
    canLaunchUrl(Uri(scheme: 'tel', path: '123')).then((bool result) {
      setState(() {
        _hasCallSupport = result;
      });
    });
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.theCase.startDatetime!}~${widget.theCase.endDatetime!}',style: const TextStyle(fontSize: 16),),),
      body: myCaseDetailMap.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(primary: AppColor.purple, elevation: 0),
                      child: const Text('看護證明'),
                      onPressed: ()async{
                        Uri _url = Uri.parse('https://care168.com.tw/my_simplfy_certificate?case=${widget.theCase.id}');
                        if (!await launchUrl(_url)) {
                          throw 'Could not launch $_url';
                        }
                      },
                    ), //看護證明button
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text('案件資訊', style: TextStyle(fontWeight: FontWeight.bold),),), //標題-案件資訊
                    Row(
                      children: [
                        Expanded(flex: 7,child: Text('委託人 ${myCase!.neederName!}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),)),
                        (myCaseReview!.caseOffenderRating != 0.0)
                            ? Expanded(
                                flex: 5,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(primary: AppColor.purple, elevation: 0, padding: EdgeInsets.zero,),
                                  child: const Text('查看給委託人的評價'),
                                  onPressed: () {
                                     showDialog<String>(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return MyCaseDetailReadReviewDialog(name: myCase!.name!, review: myCaseReview!,);
                                        });
                          },
                        ),)
                            : Expanded(
                          flex: 5,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                elevation: 0,
                                primary: AppColor.green
                            ),
                            child: const Text('給委託人評價'),
                            onPressed: () async {
                              await showDialog<String>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return MyCaseDetailWriteReviewDialog(name: widget.theCase.name!,review: myCaseReview!,);
                                  });
                              print('here');
                              _getMyCaseDetail();
                            },
                          ),
                        )
                      ],
                    ), //委託人姓名
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                            flex:2,
                            child: Text('聯絡電話')),
                        Expanded(
                          flex: 8,
                          child: GestureDetector(
                            child: Text(myCase!.neederPhone!,style: const TextStyle(color: Colors.blue),),
                            onTap: _hasCallSupport
                                ? () => setState(() {
                              _launched = _makePhoneCall(myCase!.neederPhone!);
                            })
                                : null,),
                        ),
                      ],
                    ),
                    kRowContent('案件類型',myCase!.careType!), //案件類型
                    Row(
                      children: [
                        const Text('案件地點  '),
                        Text(City.getCityNameFromId(myCase!.city!)),
                        Text(County.getCountyNameFromId(myCase!.county!)),
                        (myCase!.careType == '醫院看護')?
                        Text(' ${myCase!.hospitalName!}')
                            :
                        Text(' ${myCase!.roadName!}'),
                      ],
                    ),
                    caseTime(),
                    const SizedBox(height: 20,),
                    const Text('被照顧者聯絡人', style: TextStyle(fontWeight: FontWeight.bold),),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                            flex:4,
                            child: Text('聯絡人姓名')),
                        Expanded(
                          flex: 8,
                          child: Text(myCase!.emergencycontactName!),
                        ),
                      ],
                    ), //緊急聯絡人
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                            flex:4,
                            child: Text('與被照顧者關係')),
                        Expanded(
                          flex: 8,
                          child: Text(myCase!.emergencycontactRelation!),
                        ),
                      ],
                    ), //緊急聯絡人關係
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                            flex:4,
                            child: Text('聯絡電話')),
                        Expanded(
                          flex: 8,
                          child: GestureDetector(
                            child: Text(myCase!.emergencycontactPhone!,style: const TextStyle(color: Colors.blue),),
                            onTap: _hasCallSupport
                                ? () => setState(() {
                              _launched = _makePhoneCall(myCase!.emergencycontactPhone!);
                            })
                                : null,),
                        ),
                      ],
                    ), //緊急聯絡電話
                    const Padding(
                      padding: EdgeInsets.fromLTRB(0,15,0,8),
                      child: Text('案件金額', style: TextStyle(fontWeight: FontWeight.bold),),
                    ), //標題-案件金額
                    Container(
                      padding: const EdgeInsets.all(10),
                      color: const Color(0xffF2F2F2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Text('基本費用', style: TextStyle(fontWeight: FontWeight.bold),),
                          ), //基本費用
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('\$${myCaseOrder!.wageHour.toString()} x ${myCaseOrder!.workHours.toString()}小時'),
                              Text('\$${myCaseOrder!.baseMoney.toString()}'),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('交通費 \$${myCaseOrder!.transferFee} x ${myCaseOrder!.numOfTransfer}趟'),
                              Text('\$${myCaseOrder!.amountTransferFee}'),
                            ],
                          ),//時薪x時數
                          const SizedBox(height: 10,),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Text('加價項目', style: TextStyle(fontWeight: FontWeight.bold),),
                          ), //加價項目
                          neededServicesExtraPrice(),
                          const Divider(color: Colors.black,thickness: 1,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('服務費用金額', style: TextStyle(fontWeight: FontWeight.bold),),
                              Text('\$${myCaseOrder!.totalMoney.toString()}', style: TextStyle(fontWeight: FontWeight.bold),),
                            ],
                          ), //
                          // const SizedBox(height: 10,),
                          // const Text('扣除平台費用', style: TextStyle(fontWeight: FontWeight.bold),),//扣除平台費用
                          const SizedBox(height: 18,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('藍新金流交易手續費 -${myCaseOrder!.newebpay_percent}%', ),
                              Text('- \$${myCaseOrder!.newebpay_money.toString()}'),
                            ],
                          ), //藍新費用
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('平台服務費 -${myCaseOrder!.platformPercent}%',),
                              Text('- \$${myCaseOrder!.platformMoney.toString()}'),
                            ],
                          ), //平台服務費
                          const Divider(color: Colors.black,thickness: 1,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Text('實領金額', style: TextStyle(fontWeight: FontWeight.bold),),
                              ),
                              Text('\$${myCaseOrder!.servant_money.toString()}',style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),),
                            ],
                          ),
                        ],
                      ),
                    ), //金額計算
                    const Padding(
                      padding: EdgeInsets.fromLTRB(0,15,0,8),
                      child: Text('案主給我的評價', style: TextStyle(fontWeight: FontWeight.bold),),
                    ), //標題-案主給我的評價
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      color: const Color(0xffF2F2F2),
                      child: myCaseReview!.servantRating == 0.0? const Text('尚未評價') : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ReviewStars.getReviewStars(myCaseReview!.servantRating!),
                          const SizedBox(height: 10,),
                          Text('"${myCaseReview!.servantComment!}"'),
                        ],
                      ),
                    ),//我的評價
                    const SizedBox(height: 10,),
                    const Divider(thickness: 1,),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(0,15,0,8),
                      child: Text('被照顧者資訊', style: TextStyle(fontWeight: FontWeight.bold),),
                    ), //標題-被照顧者資訊
                    kRowContent('姓名',myCase!.name!),
                    kRowContent('性別',myCase!.gender=='M'?'男':'女'),
                    kRowContent('體重',myCase!.weight.toString()+ ' 公斤'),
                    kRowContent('年齡',myCase!.age.toString()+ ' 歲'),
                    kRowContent('疾病',myCaseDiseaseNames.join(',')),
                    kRowContent('疾病說明',myCase!.diseaseRemark!),
                    kRowContent('身體狀況',myCaseConditionNames.join(',')),
                    kRowContent('補充說明', myCase!.conditionsRemark!),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(0,15,0,8),
                      child: Text('需求服務項目', style: TextStyle(fontWeight: FontWeight.bold),),
                    ), //標題-需求服務項目
                    neededServices(),
                  ],
                ),
        ),
      ),
    );
  }

  _getNewebpayFee(int totalMoney){
    return (totalMoney*0.028).round();
  }

  kRowContent(String title, String text){
    return Row(
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
    );
  }

  careWeekDay(){
    List<String> weekDays = myCase!.weekday!.split(',');
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
    if(myCase!.isContinuousTime == true){
      return Column(
        children: [
          Row(
            children: [
              const Text('案件時間  '),
              myCase!.isContinuousTime == true ? const Text('連續時間',style: TextStyle(color: Colors.red),): const Text('指定時段',style: TextStyle(color: Colors.red),),
            ],
          ),
          Row(
            children: [
              const Expanded(flex:2,child:SizedBox(),),
              Expanded(flex:8,child: Text('開始：'+ myCase!.startDatetime!+'('+ Case.getTime(myCase!.startTime!)+')\n結束：' + myCase!.endDatetime!+'('+ Case.getTime(myCase!.endTime!)+')')),
            ],
          ),
        ],
      );
    } else if (myCase!.isContinuousTime == false){
      return Column(
        children: [
          Row(
            children: [
              const Text('案件時間  '),
              myCase!.isContinuousTime == true ? const Text('連續時間',style: TextStyle(color: Colors.red),): const Text('指定時段',style: TextStyle(color: Colors.red),),
            ],
          ),
          Row(
            children: [
              const Expanded(flex:2,child:SizedBox(),),
              Expanded(flex:8,child: Text('${myCase!.startDatetime} ~ ${widget.theCase.endDatetime}'),)
            ],
          ),
          Row(
            children: [
              const Expanded(flex:2,child:SizedBox(),),
              Expanded(flex:8,child: Text(careWeekDay()),)
            ],
          ),
          Row(
            children: [
              const Expanded(flex:2,child:SizedBox(),),
              Expanded(flex:8,child: Text('${Case.getTime(myCase!.startTime!)} ~ ${Case.getTime(myCase!.endTime!)}')),
            ],
          ),
        ],
      );
    }
  }

  neededServicesExtraPrice(){
    return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: myCaseOrder!.increaseServices!.length,
        itemBuilder:(context, index){
          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${Service.getServiceNameFromId(myCaseOrder!.increaseServices![index].service!)} \n加 ${myCaseOrder!.increaseServices![index].increasePercent}% '),
              Text('\$${myCaseOrder!.increaseServices![index].increaseMoney}'),
            ],
          );
        });
  }

  neededServices(){
   return ListView.builder(
     physics: const NeverScrollableScrollPhysics(),
     scrollDirection: Axis.vertical,
     shrinkWrap: true,
     itemCount: myCaseServices.length,
     itemBuilder: (context, index) {
       return Column(
         children: [
           Row(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               CustomTag.iconYes,
               const SizedBox(width: 10,),
               (myCaseServices[index].remark != null)? 
               Expanded(
                   child: RichText(
                   text: TextSpan(
                     text: myCaseServices[index].name,
                     style: DefaultTextStyle.of(context).style,
                     children: <TextSpan>[
                       TextSpan(text: '\n'+_checkToChangeLine(myCaseServices[index].remark!), style: const TextStyle(color: AppColor.darkGrey)),
                     ],
                   ),
                 )
               ) : Text(myCaseServices[index].name!),
             ],
           ),
           const SizedBox(height: 5),
         ],
       );
     },
   );
  }

  String _checkToChangeLine(String text){
    return text.replaceAll('※', '\n※');
  }
  
  Future _getMyCaseDetail() async {
    var userModel = context.read<UserModel>();
    print(userModel.token);
    String path = ServerApi.PATH_SERVANT_CASES+widget.theCase.id.toString();
    // try {
      final response = await http.get(ServerApi.standard(path: path),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'Authorization': 'token ${userModel.token!}'},
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> map = json.decode(utf8.decode(response.body.runes.toList()));
        myCaseDetailMap = map;
        myCase = Case.fromJson(myCaseDetailMap);
        myCaseServices = List<Service>.from(myCaseDetailMap['services'].map((i) => Service.fromJson(i)));
        myCaseDiseaseConditions = List<DiseaseCondition>.from(myCaseDetailMap['disease'].map((i) => DiseaseCondition.fromJson(i)));
        myCaseBodyConditions = List<BodyCondition>.from(myCaseDetailMap['body_condition'].map((i) => BodyCondition.fromJson(i)));
        myCaseReview = Review.fromJson(myCaseDetailMap['review']);
        myCaseOrder = Order.fromJson(myCaseDetailMap['order']);

        for(var disease in myCaseDiseaseConditions){
          myCaseDiseaseNames.add(disease.name!);
        }
        for(var condition in myCaseBodyConditions){
          myCaseConditionNames.add(condition.name!);
        }
        setState(() {

        });
      }
    // } catch (e) {
    //   print(e);
    // }
  }


}
