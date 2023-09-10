import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttercare168/constant/color.dart';
import 'package:fluttercare168/notifier_model/booking_model.dart';
import 'package:fluttercare168/constant/custom_tag.dart';
import 'package:fluttercare168/notifier_model/user_model.dart';
import 'package:provider/provider.dart';
import 'package:fluttercare168/constant/enum.dart';
import 'package:fluttercare168/constant/format_converter.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../../constant/server_api.dart';
import '../messages/messages.dart';

class BookingStep4Confirm extends StatefulWidget {
  const BookingStep4Confirm({Key? key}) : super(key: key);

  @override
  _BookingStep4ConfirmState createState() => _BookingStep4ConfirmState();
}

class _BookingStep4ConfirmState extends State<BookingStep4Confirm> {

  bool isAskOtherCarer = false;
  String bookingExplanation = '''
1. 若服務者超過 6 小時未回覆同意接案，訂單會自動取消。
2. 需求時數在一天之內，未滿 12 小時以每小時時薪計價；12 ~ 24 小時以半天價格之時薪計價；滿 24 小時以全天價格之時薪計價。
3. 服務前2天（48小時外）取消，免收取任何費用，可全額退款。48 小時內取消則無法全額退款。其他相關規定請看服務合約。''';

  int? hourWageInt;
  int? halfDayWageInt;
  int? fullDayWageInt;
  // String? totalHoursString; //carer總時數
  // List<int> extraServicePriceInts = []; //使用者所選的所有加價項目
  // int? extraServiceTotalPriceInt; //使用者所選加價項目的總價

  bool isCreating = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var bookingModel = context.read<BookingModel>();

    if(bookingModel.careType == CareType.homeCare){
      hourWageInt = bookingModel.carer?.homeHourWage;
      halfDayWageInt = bookingModel.carer?.homeHalfDayWage;
      fullDayWageInt = bookingModel.carer?.homeOneDayWage;
    } else {
      hourWageInt = bookingModel.carer?.hospitalHourWage;
      halfDayWageInt = bookingModel.carer?.hospitalHalfDayWage;
      fullDayWageInt = bookingModel.carer?.hospitalOneDayWage;
    }

    // if(bookingModel.startTime!.minute >= 0 && bookingModel.startTime!.minute < 30){
    //   bookingModel.startTime = TimeOfDay(hour: bookingModel.startTime!.hour, minute: 0);
    // } else if (bookingModel.startTime!.minute >= 30 && bookingModel.startTime!.minute <= 59){
    //   bookingModel.startTime = TimeOfDay(hour: bookingModel.startTime!.hour, minute: 30);
    // }
    // if(bookingModel.endTime!.minute >= 0 && bookingModel.endTime!.minute < 30){
    //   bookingModel.endTime = TimeOfDay(hour: bookingModel.endTime!.hour, minute: 0);
    // } else if (bookingModel.endTime!.minute >= 30 && bookingModel.endTime!.minute <= 59){
    //   bookingModel.endTime = TimeOfDay(hour: bookingModel.endTime!.hour, minute: 30);
    // }

    _calPrices();
  }

  @override
  Widget build(BuildContext context) {
    var bookingModel = context.read<BookingModel>();
    var userModel = context.read<UserModel>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('填寫訂單'),
        actions: [
          TextButton(
              child: const Text('取消預定',style: TextStyle(color: Colors.white),) ,
              onPressed: (){
                Navigator.of(context).popUntil((route) => route.isFirst);
                bookingModel.clearBookingModelData();
              })
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomTag.bookingStep4,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text('【 步驟 4 送出訂單】', style: TextStyle(color: AppColor.purple, fontWeight: FontWeight.bold),),
                        )
                  ),
                  kSectionTitle('照護類型：'),
                  (bookingModel.careType == CareType.homeCare) ? const Text('居家照顧') : const Text('醫院看護'),
                  kSectionTitle('需求時間：'),
                  (bookingModel.timeType == TimeType.continuous)
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('連續時間', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),),
                            Text('${bookingModel.startDate.toString().substring(0,10)}(${bookingModel.startTime!.to24hours()}) ~ \n${bookingModel.endDate.toString().substring(0,10)}(${bookingModel.endTime!.to24hours()})')
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('指定時段', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),),
                            Text('${bookingModel.startDate.toString().substring(0,10)} ~ ${bookingModel.endDate.toString().substring(0,10)}\n${getWeekDayStrings()}\n${bookingModel.startTime!.to24hours()}~${bookingModel.endTime!.to24hours()}'),
                          ],
                      ),
                  kSectionTitle('需求地點：'),
                  Text(bookingModel.city!.name!+bookingModel.district!.name!),
                  (bookingModel.careType==CareType.homeCare)?
                  Text('路名：${bookingModel.roadName!}')
                  :
                  Text('醫院名：${bookingModel.hospitalName!}'),
                  kSectionTitle('被照顧者資訊：'),
                  bookingModel.patientGender == Gender.female ? kRowContent('性別', '女') : kRowContent('性別', '男'),
                  kRowContent('年齡', '${bookingModel.patientAge} 歲'),
                  kRowContent('體重', '${bookingModel.patientWeight} 公斤'),
                  kRowContent('疾病', checkDisease()),
                  kRowContent('補充說明', '${bookingModel.patientDiseaseNote == null ? '無' : bookingModel.patientDiseaseNote}  '),
                  kRowContent('身體狀況',  checkBodyIssue()),
                  kRowContent('補充說明', '${bookingModel.patientBodyNote == null ? '無' : bookingModel.patientBodyNote}'),
                  kSectionTitle('需求服務項目：'),
                  checkBasicService(),
                  kSectionTitle('需求服務加價項目：'),
                  checkExtraService(),
                  kSectionTitle('緊急聯絡人'),
                  Text('姓名：${bookingModel.emergencyContactName}'),
                  Text('與被照顧者關係：${bookingModel.emergencyContactRelation}'),
                  Text('聯絡電話：${bookingModel.emergencyContactPhone}'),
                  const SizedBox(height: 15,),
                  kSectionTitle('服務者費率：'),
                  Text('每小時 \$$hourWageInt｜ 半天 \$${_getWageWords(halfDayWageInt!)}｜ 全天 \$${_getWageWords(fullDayWageInt!)}'),
                  const SizedBox(height: 15,),
                  kSectionTitle('費用計算：'),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 5),
                    color: const Color(0xfff2f2f2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        kSectionTitle('基本費用'),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('\$${bookingModel.wageHour} x ${bookingModel.workHours!.toStringAsFixed(1)} 小時'),
                            Text('\$${bookingModel.baseMoney}'),
                          ]),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('交通費 \$${bookingModel.transferFee} x ${bookingModel.numOfTransfer} 趟'),
                              Text('\$${bookingModel.amountOfTransfer}'),
                            ]),
                        // showBasicSalary(hourWage!, halfDayWage!, fullDayWage!),
                        SizedBox(height: 10),
                        kSectionTitle('加價項目'),
                        showExtraServiceSalary(hourWageInt!),
                        const Divider(thickness: 2,color: Colors.black,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            kSectionTitle('總計'),
                            Text('\$${bookingModel.totalMoney}',style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),)
                          ],)
                      ],
                    ),
                  ),
                  const SizedBox(height: 15,),
                  Text('※以服務費用計算平均時薪，四捨五入取到個位數。', style: TextStyle(color: AppColor.darkGrey)),
                  const SizedBox(height: 15,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 30,
                        height: 30,
                        child: Checkbox(
                          checkColor: Colors.white,
                          activeColor: AppColor.purple,
                          value: isAskOtherCarer,
                          onChanged: (bool? value){
                            setState(() {
                              isAskOtherCarer = value!;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: RichText(
                          text: const TextSpan(
                            text: '自動產生需求單徵詢所有服務者',
                            style: TextStyle(fontSize: 16, color: Colors.black),
                            children: <TextSpan>[
                              TextSpan(text: '\n需求單會隱藏您與被照顧者的個資，若有人回覆有意願，您會收到通知，您可再決定要向哪一位照顧者申請。', style: TextStyle(color: Colors.grey, fontSize: 14)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15,),
                  kSectionTitle('訂單說明：'),
                  Text(bookingExplanation),
                ],
              ),
              const SizedBox(height: 40,),
              ElevatedButton(
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30,vertical: 8),
                  child: Text('向服務者發出訂單',style: TextStyle(fontSize: 18),),
              ),
                style: ElevatedButton.styleFrom(primary: AppColor.green, elevation: 0),
                onPressed: (){
                  var bookingModel = context.read<BookingModel>();
                  if(bookingModel.baseMoney == null || bookingModel.baseMoney! <= 0 || bookingModel.workHours! <= 0){
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("金額或時間計算錯誤！無法發出訂單～如有疑問請聯繫平台客服。"),));
                  }else{
                    if(!isCreating) {
                      _postCreateOrEditCase();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("訂單處理中，請稍候！"),));
                    }else{
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("訂單處理中，請稍候！"),));
                    }
                  }
                },
              ),
              const SizedBox(height: 40,),
            ],
          ),
        ),
      ),
    );
  }

  String _getWageWords(int wage){
    if(wage != 0){
      return wage.toString();
    }else{
      return '無服務';
    }
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

  getWeekDayStrings(){
    List<String> dayStrings = [];
    var bookingModel = context.read<BookingModel>();
    for(var day in bookingModel.checkWeekDays){
      if(day.isChecked){
        dayStrings.add(day.day);
      }
    }
    return dayStrings.join(',');
  }

  checkDisease(){
    var bookingModel = context.read<BookingModel>();
    List<String> diseaseNameStrings = [];
    for (var item in bookingModel.checkDiseaseChoices){
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
    var bookingModel = context.read<BookingModel>();
    List<String> bodyIssueStrings = [];
    for (var item in bookingModel.checkBodyChoices){
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
    var bookingModel = context.read<BookingModel>();
    List<Column> basicServices = [];
    for (var item in bookingModel.checkBasicServiceChoices){
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
                        : Expanded(
                            child: RichText(
                              text: TextSpan(
                                text: item.service!.name,
                                style: const TextStyle(fontSize: 16, color: Colors.black),
                                children: <TextSpan>[
                                  TextSpan(text: '\n${item.service!.remark}', style: const TextStyle(color: Colors.grey, fontSize: 14)),
                                ],
                              ),
                            ),
                        ),
                  ],),
                const SizedBox(height: 6,)
              ],
            ));
      }
    }
    return Column(children: basicServices);
  }

  Widget checkExtraService(){
    var bookingModel = context.read<BookingModel>();
    List<Column> extraServices = [];
    for (var item in bookingModel.checkExtraServiceChoices){
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

  //算加價項目的錢，先用基本時薪算就好
  Widget showExtraServiceSalary(int hourWage){
    var bookingModel = context.read<BookingModel>();
    List<Row> increaseServicePriceRow = [];
    for(var item in bookingModel.orderIncreaseServices){
        increaseServicePriceRow.add(Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${item.service!.name!} 加 ${item.service!.increasePercent}% '),
              Text('\$${item.increaseMoney}'),
            ]));
    }
    return Column(children: increaseServicePriceRow,);
  }

  timeConverter(DateTime date, TimeOfDay time){
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  _calPrices(){
    var bookingModel = context.read<BookingModel>();

    print(bookingModel.startDate);
    print(bookingModel.endDate);

    DateTime theStartDate = DateTime(bookingModel.startDate!.year, bookingModel.startDate!.month, bookingModel.startDate!.day);
    DateTime theEndDate = DateTime(bookingModel.endDate!.year, bookingModel.endDate!.month, bookingModel.endDate!.day);

    print(theStartDate);
    print(theEndDate);
    int days = theEndDate.difference(theStartDate).inDays;

    // int days = bookingModel.endDate!.day - bookingModel.startDate!.day -1;
    //連續時間天數
    // int _continueDays = bookingModel.endDate!.difference(bookingModel.startDate!).inDays;

    double workHours = 0;
    double oneDayHours = 0;
    int numOfTransfer = 0;
    print('days $days');

    if( bookingModel.timeType == TimeType.continuous){
      //連續時間的天數有三種可能： 1.小於1天 (0) 2.等於1天(1) 3.大於1天 (>1)
      //日期是 dateTime 時間是 timeOfDay

      DateTime startDateTime = timeConverter(bookingModel.startDate!, bookingModel.startTime!);
      DateTime endDateTime = timeConverter(bookingModel.endDate!, bookingModel.endTime!);
      int diffMinutes = endDateTime.difference(startDateTime).inMinutes;
      // print('======== diffHours =  $diffHours');

      workHours  = (diffMinutes / 60);

      // if(days >= 2){
      //   print('days != 0 (跨1日以上) ');
      //   workHours = 24 - (bookingModel.startTime!.hour + bookingModel.startTime!.minute/60 );
      //   workHours = workHours + days * 24;
      //   workHours = workHours + (bookingModel.endTime!.hour + bookingModel.endTime!.minute/60 );
      // } else if (days >= 1){
      //   print('隔天');
      //   workHours = 24 - (bookingModel.startTime!.hour + bookingModel.startTime!.minute/60 );
      //   workHours = workHours + (bookingModel.endTime!.hour + bookingModel.endTime!.minute/60 );
      // } else if (days < 1 ){
      //   print('days =0 (當天內)');
      //   int hours = bookingModel.endTime!.hour - bookingModel.startTime!.hour;
      //   int minutes = bookingModel.endTime!.minute - bookingModel.startTime!.minute;
      //   if(minutes < 0){
      //     hours = hours -1;
      //     minutes = minutes + 60;
      //   }
      //   workHours = hours + minutes/60;
      //   if(workHours < 0){
      //     workHours = workHours + 24;
      //   }
      // }

      numOfTransfer = 1;

      //原本寫法
      // if(days >= 0){
      //   workHours = 24 - (bookingModel.startTime!.hour + bookingModel.startTime!.minute/60 );
      //   workHours = workHours + days * 24;
      //   workHours = workHours + (bookingModel.endTime!.hour + bookingModel.endTime!.minute/60 );
      // }else{
      //   int hours = bookingModel.endTime!.hour - bookingModel.startTime!.hour;
      //   int minutes = bookingModel.endTime!.minute - bookingModel.startTime!.minute;
      //   if(minutes < 0){
      //     hours = hours -1;
      //     minutes = minutes + 60;
      //   }
      //   workHours = hours + minutes/60;
      // }
      // numOfTransfer = 1;
    }else{
      int hours = bookingModel.endTime!.hour - bookingModel.startTime!.hour;
      int minutes = bookingModel.endTime!.minute - bookingModel.startTime!.minute;
      if(minutes < 0){
        hours = hours -1;
        minutes = minutes + 60;
      }
      oneDayHours = hours + minutes/60;

      print('oneDayHour $oneDayHours');

      // print(bookingModel.checkWeekDays);

      List<int> workWeekDays = bookingModel.checkWeekDays!.map((item) => (item.isChecked)?item.weekDay:-1).toList();
      workWeekDays.removeWhere((element) => element==-1);
      print('workWeekDays $workWeekDays');

      days = days+1;
      if(days >= 0){
        for(var i=0; i<days; i++){
          print('i $i');
          int weekDay = bookingModel.startDate!.add(Duration(days: i)).weekday;
          if(weekDay==7){
            weekDay=0;
          }
          print('week day $weekDay');
          if( workWeekDays.contains(weekDay) ){
            workHours = workHours + oneDayHours;
            numOfTransfer = numOfTransfer + 1;
          }
        }
      }else{
        workHours = oneDayHours;
        numOfTransfer = 1;
      }
    }
    bookingModel.workHours = workHours;

    if(bookingModel.timeType == TimeType.continuous){
        if(bookingModel.careType == CareType.homeCare){
          if(workHours<12){
            bookingModel.wageHour = bookingModel.carer!.homeHourWage;
          }else if(workHours>=12 && workHours <24){
            bookingModel.wageHour = (bookingModel.carer!.homeHalfDayWage! / 12).round();
          }else{
            bookingModel.wageHour = (bookingModel.carer!.homeOneDayWage! / 24).round();
          }
        }else{
          if(workHours<12){
            bookingModel.wageHour = bookingModel.carer!.hospitalHourWage;
          }else if(workHours>=12 && workHours <24){
            bookingModel.wageHour = (bookingModel.carer!.hospitalHalfDayWage! / 12).round();
          }else{
            bookingModel.wageHour = (bookingModel.carer!.hospitalOneDayWage! /24).round() ;
          }
        }
    }else{
      if(bookingModel.careType == CareType.homeCare){
        if(oneDayHours<12){
          bookingModel.wageHour = bookingModel.carer!.homeHourWage;
        }else if(oneDayHours>=12 && oneDayHours <24){
          bookingModel.wageHour = (bookingModel.carer!.homeHalfDayWage! / 12).round();
        }else{
          bookingModel.wageHour = (bookingModel.carer!.homeOneDayWage! / 24).round();
        }
      }else{
        if(oneDayHours<12){
          bookingModel.wageHour = bookingModel.carer!.hospitalHourWage;
        }else if(oneDayHours>=12 && oneDayHours <24){
          bookingModel.wageHour = (bookingModel.carer!.hospitalHalfDayWage! / 12).round();
        }else{
          bookingModel.wageHour = (bookingModel.carer!.hospitalOneDayWage! /24).round() ;
        }
      }
    }

    bookingModel.baseMoney = (bookingModel.wageHour! * bookingModel.workHours!).toInt();
    bookingModel.numOfTransfer = numOfTransfer;
    bookingModel.amountOfTransfer = bookingModel.transferFee! * bookingModel.numOfTransfer!;

    print('work hours $workHours');
    print('wage hour ${bookingModel.wageHour}');
    print('base money ${bookingModel.baseMoney}');

    print('transfer fee ${bookingModel.transferFee}');
    print('num of transfer ${bookingModel.numOfTransfer}');
    print('amount of transfer ${bookingModel.amountOfTransfer}');

    int totalMoney = bookingModel.baseMoney! + bookingModel.amountOfTransfer!;
    bookingModel.orderIncreaseServices = [];

    for(var item in bookingModel.checkExtraServiceChoices){
      if(item.isChecked==true){
        print('service ${item.service!.name}');
        print('increase percent ${item.service!.increasePercent}');
        int increaseMoney = (item.service!.increasePercent!/100*bookingModel.baseMoney!).toInt();
        print('increase moeny ${increaseMoney}');
        bookingModel.orderIncreaseServices.add(
            OrderIncreaseService(
                service: item.service!,
                increaseMoney: increaseMoney),
        );
        totalMoney = totalMoney + increaseMoney;
      }
    }

    bookingModel.totalMoney = totalMoney;
    print('total money ${bookingModel.totalMoney}');
  }

  Future _postCreateOrEditCase() async {
    isCreating = true;

    var bookingModel = context.read<BookingModel>();
    var userModel = context.read<UserModel>();

    String path = (bookingModel.caseId==0)?ServerApi.PATH_CREATE_SERVANT_ORDER:ServerApi.PATH_EDIT_CASE_ORDER;

    String weekdaysString = '';
    if(bookingModel.checkWeekDays!=null) {
      bookingModel.checkWeekDays!.removeWhere((element) => element.isChecked == false);
      weekdaysString = bookingModel.checkWeekDays!.map((item) => item.weekDay).toList().toString().replaceAll('[', '').replaceAll(']', '').replaceAll(' ', '');
    }

    bookingModel.checkDiseaseChoices.removeWhere((element) => element.isChecked==false);
    String diseaseString = bookingModel.checkDiseaseChoices.map((item) => item.diseaseId!).toList().toString().replaceAll('[', '').replaceAll(']', '').replaceAll(' ', '');

    bookingModel.checkBodyChoices.removeWhere((element) => element.isChecked==false);
    String bodyConditionsString =  bookingModel.checkBodyChoices.map((item) => item.bodyConditionId!).toList().toString().replaceAll('[', '').replaceAll(']', '').replaceAll(' ', '');

    bookingModel.checkExtraServiceChoices.removeWhere((element) => element.isChecked==false);
    bookingModel.checkBasicServiceChoices.removeWhere((element) => element.isChecked==false);
    List<int> serviceIds = bookingModel.checkExtraServiceChoices.map((item) => item.serviceId!).toList() + bookingModel.checkBasicServiceChoices.map((item) => item.serviceId!).toList();
    String serviceIdString = serviceIds.toString().replaceAll('[', '').replaceAll(']', '').replaceAll(' ', '');

    try {

      Map<String, String> queryParameters = {
        'county': bookingModel.district!.id.toString(),
        'start_date': DateFormat('yyyy-MM-dd').format(bookingModel.startDate!),
        'end_date': DateFormat('yyyy-MM-dd').format(bookingModel.endDate!),
        'start_time': bookingModel.startTime!.to24hours(),
        'end_time': bookingModel.endTime!.to24hours(),
        'servant_id': bookingModel.carer!.id.toString(),
        'weekday': weekdaysString,
      };

      if(bookingModel.caseId!=0){
        queryParameters['case_id']=bookingModel.caseId.toString();
      }

      final bodyParameters = {
        'care_type': (bookingModel.careType==CareType.homeCare)?'home':'hospital',
        'is_continuous_time': bookingModel.timeType==TimeType.continuous?'True':'False',
        'name': bookingModel.patientName,
        'needer_name': bookingModel.neederName,
        'gender': bookingModel.patientGender==Gender.male?'M':'F',
        'age': bookingModel.patientAge!,
        'weight': bookingModel.patientWeight!,
        'disease': diseaseString,
        'disease_remark': bookingModel.patientDiseaseNote,
        'body_condition': bodyConditionsString,
        'conditions_remark': bookingModel.patientBodyNote,
        'service': serviceIdString,
        'emergencycontact_name': bookingModel.emergencyContactName,
        'emergencycontact_relation': bookingModel.emergencyContactRelation,
        'emergencycontact_phone': bookingModel.emergencyContactPhone,
        'road_name':bookingModel.roadName==null?'':bookingModel.roadName!,
        'hospital_name':bookingModel.hospitalName==null?'':bookingModel.hospitalName!,
        'is_open_for_search':isAskOtherCarer?'True':'False',
      };

      print(queryParameters);
      print(bodyParameters);
      // print(userModel.token);

      final response = await http.post(ServerApi.standard(path: path,queryParameters: queryParameters),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Token ${userModel.token!}',
        },
        body: jsonEncode(bodyParameters),
      );

      // print(response.statusCode);
      // _printLongString(response.body);
      isCreating = false;

      if(response.statusCode == 200){
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("成功發出訂單！請至聊聊訊息查看～"),));
        // userModel.setUserUnReadNum(userModel.user!.totalUnReadNum!+1);
        // Navigator.popUntil(context, (route) => route.isFirst);
        bookingModel.clearBookingModelData();
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(
              builder: (context) => const Messages(),
            )
            , (route) => route.isFirst);
      }else{
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("無法產生訂單，請稍後再試！"),));
      }

    } catch (e) {
      print(e);
      isCreating = false;
      return "error";
    }
  }

  void _printLongString(String text) {
    final RegExp pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern.allMatches(text).forEach((RegExpMatch match) =>   print(match.group(0)));
  }

}


