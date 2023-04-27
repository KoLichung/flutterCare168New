import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttercare168/constant/color.dart';
import 'package:fluttercare168/models/body_condition.dart';
import 'package:fluttercare168/models/city.dart';
import 'package:fluttercare168/models/county.dart';
import 'package:fluttercare168/models/disease_condition.dart';
import 'package:fluttercare168/constant/custom_tag.dart';
import 'package:fluttercare168/models/case.dart';
import 'package:fluttercare168/constant/server_api.dart';
import 'package:fluttercare168/models/order.dart';
import 'package:fluttercare168/pages/member/order_management/write_review_to_carer_dialog.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttercare168/models/service.dart';
import '../../../constant/custom_tag.dart';
import 'package:fluttercare168/notifier_model/user_model.dart';
import 'package:provider/provider.dart';
import 'package:fluttercare168/models/review.dart';
import '../../../models/service_increase_money.dart';
import 'my_booking_detail_read_review_dialog.dart';
import 'my_booking_detail_write_review_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class MyBookingDetailPage extends StatefulWidget {
  final Case theCase;
  const MyBookingDetailPage({Key? key, required this.theCase}) : super(key: key);
  @override
  _MyBookingDetailPageState createState() => _MyBookingDetailPageState();
}

class _MyBookingDetailPageState extends State<MyBookingDetailPage> {
  Map<String, dynamic> myBookingCaseDetailMap = {};
  Case? myBookingCase;
  Order? myBookingCaseOrder;
  List<Service> myBookingCaseServices = [];
  List<DiseaseCondition> myBookingCaseDiseaseConditions = [];
  List<BodyCondition> myBookingCaseBodyConditions = [];
  List<String> myBookingCaseDiseaseNames = [];
  List<String> myBookingCaseConditionNames = [];
  List<String> myBookingCaseWeekDays = [];
  Review? myBookingCaseReview;
  List<ServiceIncreaseMoney> myBookingCaseIncreaseMoney = [];
  late String carerName;



  bool _hasCallSupport = false;
  Future<void>? _launched;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getMyBookingCaseDetail();
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
        title: Text(widget.theCase.startDatetime!+'~'+widget.theCase.endDatetime!,style: TextStyle(fontSize: 16),),),
      body: myBookingCaseDetailMap.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('案件資訊', style: TextStyle(fontWeight: FontWeight.bold),),), //標題-案件資訊
                  (myBookingCase!.servant!=null && myBookingCase!.servantRating!=null)
                      ? Row(
                          children: [
                            Expanded(flex: 7,child: Text('服務者 ${myBookingCase!.servantName!}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),)),
                            // Expanded(flex: 5,child: Text(myBookingCase!.servantName!)),
                            (myBookingCaseReview !=null && myBookingCaseReview!.servantRating != 0.0
                                ? Expanded(
                                  flex: 5,
                                  child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(primary: AppColor.purple, elevation: 0, padding: EdgeInsets.zero,),
                                      child: const Text('查看給服務者的評價'),
                                      onPressed: () {
                                        showDialog<String>(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return MyBookingDetailReadReviewDialog(name: widget.theCase.name!, review: myBookingCaseReview!,);
                                            });
                                      },
                                    ),
                                )
                                : Expanded(
                                    flex: 5,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(elevation: 0, backgroundColor: AppColor.green),
                                      child: const Text('給服務者評價'),
                                      onPressed: () async{
                                        await showDialog<String>(
                                            context: context,
                                            builder: (BuildContext context) {
                                              // return MyBookingDetailWriteReviewDialog(theCase: myBookingCase!);
                                              return WriteReviewToCarerDialog(review: myBookingCaseReview!,);
                                            });
                                        _getMyBookingCaseDetail();
                                      },
                                    ),
                                  ))
                          ],
                        )
                      : Container(),
                  const SizedBox(height: 20,),
                  (myBookingCase!.servant!=null)
                    ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                            flex:2,
                            child: Text('聯絡電話')),
                        Expanded(
                          flex: 8,
                          child: GestureDetector(
                              child: Text(myBookingCase!.servant!.phone!,style: const TextStyle(color: Colors.blue),),
                              onTap: _hasCallSupport
                                  ? () => setState(() {
                                        _launched = _makePhoneCall(myBookingCase!.servant!.phone!);
                                     })
                                  : null,),
                        ),
                      ],
                    ) //服務者電話
                    : Container(),
                  kRowContent('案件類型',myBookingCase!.careType!), //案件類型
                  Row(
                    children: [
                      const Text('案件地點  '),
                      Text(City.getCityNameFromId(myBookingCase!.city!)),
                      Text(County.getCountyNameFromId(myBookingCase!.county!)),
                      (myBookingCase!.careType == '醫院看護')?
                      Text(' ${myBookingCase!.hospitalName!}')
                          :
                      Text(' ${myBookingCase!.roadName!}'),
                    ],
                  ),
                  caseTime(),
                  (myBookingCaseOrder!=null)
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                                      Text('\$ ${myBookingCaseOrder!.wageHour} x ${myBookingCaseOrder!.workHours}小時'),
                                      Text('\$${myBookingCaseOrder!.baseMoney}'),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('交通費 \$${myBookingCaseOrder!.transferFee} x ${myBookingCaseOrder!.numOfTransfer}趟'),
                                      Text('\$${myBookingCaseOrder!.amountTransferFee}'),
                                    ],
                                  ),
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
                                      const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 8.0),
                                        child: Text('總計', style: TextStyle(fontWeight: FontWeight.bold),),
                                      ),
                                      Text('\$${myBookingCaseOrder!.totalMoney}',style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),),
                                    ],
                                  ),
                                ],
                              ),
                            ), //金額計算
                            const Divider(height: 40, thickness: 1,),
                          ],
                      )
                      : Container(),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('被照顧者資訊', style: TextStyle(fontWeight: FontWeight.bold),),
                  ), //標題-被照顧者資訊
                  (myBookingCase!.gender=='M')?kRowContent('性別','男'):kRowContent('性別','女'),
                  kRowContent('體重', myBookingCase!.weight!.toString()+ ' 公斤'),
                  kRowContent('年齡', myBookingCase!.age!.toString()+ ' 歲'),
                  kRowContent('疾病',myBookingCaseDiseaseNames.join(',')),
                  (myBookingCase!.diseaseRemark!=null)? kRowContent('疾病說明',myBookingCase!.diseaseRemark!):Container(),
                  kRowContent('身體狀況',myBookingCaseConditionNames.join(',')),
                  (myBookingCase!.conditionsRemark!=null)?kRowContent('補充說明',myBookingCase!.conditionsRemark!):Container(),
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
  caseTime(){
    if(myBookingCase!.isContinuousTime == true){
      return Column(
        children: [
          Row(
            children: const [
              Text('案件時間  '),
              Text('連續時間',style: TextStyle(color: Colors.red),),
            ],
          ),
          Row(
            children: [
              const Expanded(flex:2,child:SizedBox(),),
              Expanded(flex:8,child: Text('開始：'+ myBookingCase!.startDatetime!+'('+ Case.getTime(myBookingCase!.startTime!)+')\n結束：' + myBookingCase!.endDatetime!+'('+ Case.getTime(myBookingCase!.endTime!)+')')),
            ],
          ),
        ],
      );
    } else if (myBookingCase!.isContinuousTime == false){
      return Column(
        children: [
          Row(
            children: const [
              Text('案件時間  '),
              Text('指定時段',style: TextStyle(color: Colors.red),),
            ],
          ),
          Row(
            children: [
              const Expanded(flex:2,child:SizedBox(),),
              Expanded(flex:8,child: Text('${myBookingCase!.startDatetime} ~ ${widget.theCase.endDatetime}'),)
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
              Expanded(flex:8,child: Text('${Case.getTime(myBookingCase!.startTime!)} ~ ${Case.getTime(myBookingCase!.endTime!)}')),
            ],
          ),
        ],
      );
    }
  }

  careWeekDay(){
    List<String> weekDays = myBookingCase!.weekday!.split(',');
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

  neededServicesExtraPrice(){
    return ListView.builder(
        scrollDirection: Axis.vertical,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: myBookingCaseOrder!.increaseServices!.length,
        itemBuilder:(context, index){
          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${Service.getServiceNameFromId(myBookingCaseOrder!.increaseServices![index].service!)} \n每小時加 ${myBookingCaseOrder!.increaseServices![index].increasePercent}% x ${myBookingCaseOrder!.workHours} 小時 '),
              Text('\$${myBookingCaseOrder!.increaseServices![index].increaseMoney}'),
            ],);
        });
  }

  neededServices(){
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: myBookingCaseServices.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTag.iconYes,
                const SizedBox(width: 10,),
                (myBookingCaseServices[index].remark != null)?
                Expanded(child:
                  RichText(
                    text: TextSpan(
                      text: myBookingCaseServices[index].name,
                      style: DefaultTextStyle.of(context).style,
                      children: <TextSpan>[
                        TextSpan(text: '\n'+_checkToChangeLine(myBookingCaseServices[index].remark!), style: const TextStyle(color: AppColor.darkGrey)),
                      ],
                    ),
                  )
                ) : Text(myBookingCaseServices[index].name!),
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

  Future _getMyBookingCaseDetail() async {
    var userModel = context.read<UserModel>();

    print(userModel.token);

    String path = ServerApi.PATH_NEED_CASES+widget.theCase.id.toString();
    // try {
      final response = await http.get(ServerApi.standard(path: path),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'Authorization': 'token ${userModel.token!}'},
      );
      // print(response.body);
      if (response.statusCode == 200) {
        Map<String, dynamic> map = json.decode(utf8.decode(response.body.runes.toList()));
        myBookingCaseDetailMap = map;
        myBookingCase = Case.fromJson(myBookingCaseDetailMap);
        if(myBookingCaseDetailMap['order']!=null){
          myBookingCaseOrder = Order.fromJson(myBookingCaseDetailMap['order']);
        }
        myBookingCaseServices = List<Service>.from(myBookingCaseDetailMap['services'].map((i) => Service.fromJson(i)));
        myBookingCaseDiseaseConditions = List<DiseaseCondition>.from(myBookingCaseDetailMap['disease'].map((i) => DiseaseCondition.fromJson(i)));
        myBookingCaseBodyConditions = List<BodyCondition>.from(myBookingCaseDetailMap['body_condition'].map((i) => BodyCondition.fromJson(i)));
        for(var disease in myBookingCaseDiseaseConditions){
          myBookingCaseDiseaseNames.add(disease.name!);
        }
        for(var condition in myBookingCaseBodyConditions){
          myBookingCaseConditionNames.add(condition.name!);
        }
        if(myBookingCaseDetailMap['review']!=null){
          myBookingCaseReview = Review.fromJson(myBookingCaseDetailMap['review']);
        }

        setState(() {});
      }
    // } catch (e) {
    //   print(e);
    // }
  }
}
