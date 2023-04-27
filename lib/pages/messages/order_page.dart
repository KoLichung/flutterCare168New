import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttercare168/constant/color.dart';
import 'package:fluttercare168/constant/review_stars.dart';
import 'package:fluttercare168/models/body_condition.dart';
import 'package:fluttercare168/models/carer.dart';
import 'package:fluttercare168/models/city.dart';
import 'package:fluttercare168/models/county.dart';
import 'package:fluttercare168/models/disease_condition.dart';
import 'package:fluttercare168/constant/custom_tag.dart';
import 'package:fluttercare168/models/case.dart';
import 'package:fluttercare168/constant/server_api.dart';
import 'package:fluttercare168/models/order.dart';
import 'package:fluttercare168/pages/messages/cancel_order_dialog.dart';
import 'package:fluttercare168/pages/messages/order_webview.dart';
import 'package:fluttercare168/widgets/custom_elevated_button.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttercare168/models/service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../../constant/custom_tag.dart';
import 'package:fluttercare168/notifier_model/user_model.dart';
import 'package:provider/provider.dart';
import 'package:fluttercare168/models/review.dart';
import '../../../models/service_increase_money.dart';
import '../../notifier_model/booking_model.dart';
import '../../widgets/custom_button.dart';
import 'package:intl/intl.dart';

import '../search_carer/booking_step1_detail.dart';
import 'messages.dart';

class OrderPage extends StatefulWidget {

  final int orderId;

  const OrderPage({Key? key,required this.orderId}) : super(key: key);

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  Map<String, dynamic> orderDetailMap = {};
  Case orderCase = Case();
  // Carer orderCarer = Carer();
  Order? theOrder;
  List<Service> orderServices = [];
  List<DiseaseCondition> orderDiseaseConditions = [];
  List<BodyCondition> orderBodyConditions = [];
  List<String> orderDiseaseNames = [];
  List<String> orderConditionNames = [];
  List<String> orderWeekDays = [];
  List<ServiceIncreaseMoney> increaseServiceMoneys = [];//沒回傳
  List<Service> carerServices=[];

  bool _hasCallSupport = false;
  Future<void>? _launched;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getOrderDetail(widget.orderId);
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
    // if(theOrder!=null) {
    //   print(theOrder!.servant);
    //   print(theOrder!.servant!.id);
    // }

    return Scaffold(
      appBar: AppBar(
        title: const Text('訂單')),
      body: (orderDetailMap.isEmpty)
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _getOrderStateBanner(),
                  const SizedBox(height: 20,),
                  (theOrder!.servant!=null)
                      ? Row(
                    children: [
                      (theOrder!.servant!.image!=null)?
                      checkUserImage(theOrder!.servant!.image!):
                      checkUserImage(''),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  child: Text(theOrder!.servant!.name!,style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                                  onTap: ()async{
                                    Uri url = Uri.parse(ServerApi.getCarerUrl(theOrder!.servant!.id!).toString());
                                    if (!await launchUrl(url)) {
                                      throw 'Could not launch $url';
                                    }
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 20),
                                  child: _orderStateTag(),
                                )
                              ],),
                            const SizedBox(height: 5,),
                            Row(
                              children: [
                                theOrder!.servant!.servantAvgRating! == 0.0 ? const Text('') : Text(theOrder!.servant!.servantAvgRating!.toString()),
                                const SizedBox(width: 5,),
                                ReviewStars.getReviewStars(theOrder!.servant!.servantAvgRating!),
                                Text(' (${theOrder!.servant!.ratingNums!})'),
                              ],
                            ),
                            const SizedBox(height: 5,),
                            (orderCase.careType == '居家照顧') ? Text('時薪 \$${_getWageWords(theOrder!.servant!.homeHourWage!)} / 半天 \$${_getWageWords(theOrder!.servant!.homeHalfDayWage!)} / 全天 \$${_getWageWords(theOrder!.servant!.homeOneDayWage!)}') : Text('時薪 \$${_getWageWords(theOrder!.servant!.hospitalHourWage!)} / 半天 \$${_getWageWords(theOrder!.servant!.hospitalHalfDayWage!)} / 全天 \$${_getWageWords(theOrder!.servant!.hospitalOneDayWage!)}')
                          ],),
                      )
                    ],
                  )
                      : Container(),
                  const SizedBox(height: 10,),
                  // kRowContent('需求類型', orderCase.careType!),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 8.0),
                    child: Row(children: [
                      const Text('需求類型  '),
                      const SizedBox(width: 5,),
                      Text(orderCase.careType!),
                    ],),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 8.0),
                    child: Row(children: [
                      const Text('需求地點  '),
                      const SizedBox(width: 5,),
                      Text(City.getCityNameFromId(orderCase.city!)),
                      const SizedBox(width: 5,),
                      (orderCase.county!=null)? Text(County.getCountyNameFromId(orderCase.county!)) : Container(),
                      const SizedBox(width: 5,),
                      Text(_getRoadOrHospitalName()),
                    ],),
                  ),
                  caseTime(),
                  const Divider(
                    indent: 20,
                    endIndent: 20,
                    thickness: 0.5,
                    color: AppColor.darkGrey,
                  ),
                  (theOrder!.state=='paid')
                      ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text('聯絡電話',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold, color: AppColor.purple),),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Expanded(
                              flex: 3,
                              child: Text('服務者'),
                            ),
                            Expanded(
                              flex: 6,
                              child: Row(
                                children: [
                                  Text(orderCase.servant!.name!),
                                  const SizedBox(width: 10,),
                                  GestureDetector(
                                      child: Text(orderCase.servant!.phone!,style: const TextStyle(color: Colors.blue),),
                                      onTap: _hasCallSupport
                                            ? () => setState(() {
                                                _launched = _makePhoneCall(orderCase.servant!.phone!);
                                              })
                                            : null,
                                  ),
                                ],
                              ),
                            ),

                          ],
                        ),
                      ), //接案者服務者
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Expanded(
                              flex: 3,
                              child: Text('委託人'),
                            ),
                            Expanded(
                              flex: 6,
                              child: Row(
                                children: [
                                  Text(orderCase.userDetail!.name!),
                                  const SizedBox(width: 10,),
                                  GestureDetector(
                                      child: Text(orderCase.userDetail!.phone!,style: const TextStyle(color: Colors.blue),),
                                    onTap:  _hasCallSupport
                                        ? () => setState(() {
                                      _launched = _makePhoneCall(orderCase.userDetail!.phone!);
                                    })
                                        : null,
                                  ),
                                ],
                              ),
                            ),

                          ],
                        ),
                      ), //發案者委託人
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Expanded(
                              flex: 3,
                              child: Text('被照顧者聯絡人'),
                            ),
                            Expanded(
                              flex: 6,
                              child: Row(
                                children: [
                                  Text(orderCase.emergencycontactName!),
                                  const SizedBox(width: 10,),
                                  GestureDetector(
                                      child: Text(orderCase.emergencycontactPhone!,style: const TextStyle(color: Colors.blue),),
                                      onTap: _hasCallSupport
                                              ? () => setState(() {
                                                  _launched = _makePhoneCall(orderCase.emergencycontactPhone!);
                                                })
                                              : null,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ), //被照顧者聯絡人
                    ],
                  )
                      : Container(),
                  const SizedBox(height: 10,),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text('被照顧者資訊',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold, color: AppColor.purple),),
                  ),
                  const SizedBox(height: 10,),
                  (theOrder!.state=='paid') ? kRowContent('被照顧者姓名', orderCase.name!) : Container(),
                  (orderCase.gender=='M') ? kRowContent('性別', '男') : kRowContent('性別', '女'),
                  kRowContent('年齡', orderCase.age!.toString() + ' 歲'),
                  kRowContent('體重', orderCase.weight!.toString()+ ' 公斤'),
                  kRowContent('疾病', orderDiseaseNames.join(',')),
                  (orderCase.diseaseRemark!=null)?kRowContent('補充說明', orderCase.diseaseRemark!):Container(),
                  kRowContent('身體狀況', orderConditionNames.join(',')),
                  (orderCase.conditionsRemark!=null)?kRowContent('補充說明', orderCase.conditionsRemark!):Container(),
                  const SizedBox(height: 10,),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20,0,20,20),
                    child: Text('需求服務項目',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold, color: AppColor.purple),),
                  ),
                  neededServices(),
                  const SizedBox(height: 10,),
                  const Divider(
                    indent: 20,
                    endIndent: 20,
                    thickness: 0.5,
                    color: AppColor.darkGrey,
                  ),
                   Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child:
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('服務費用',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold, color: AppColor.purple)),
                        Text('※以服務費用計算平均時薪，四捨五入取到個位數。', style: TextStyle(color: AppColor.darkGrey)),
                      ]),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
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
                            Text('\$${theOrder!.wageHour} x ${theOrder!.workHours!.toStringAsFixed(1)}小時'),
                            Text('\$${theOrder!.baseMoney}'),
                          ],
                        ), //時薪x時數
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('交通費 \$${theOrder!.transferFee} x ${theOrder!.numOfTransfer}趟'),
                            Text('\$${theOrder!.amountTransferFee}'),
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
                            Text('\$${theOrder!.totalMoney}',style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // neededServices(),
                  const SizedBox(height: 20,),
                  _getNeederButton(),
                  const SizedBox(height: 40,),
                ],
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

  String _getRoadOrHospitalName(){
    if(orderCase.careType=='居家照顧'){
      if(orderCase.roadName!=null){
        return orderCase.roadName!;
      }else{
        return '';
      }
    }else{
      if(orderCase.hospitalName!=null){
        return orderCase.hospitalName!;
      }else{
        return '';
      }
    }
  }

  _getNeederButton(){
    var userModel = context.read<UserModel>();
    // print(userModel.user!.id);
    // print(orderCase.user);

    if(orderCase != null && userModel.user!.id == orderCase.user!){
      if (theOrder!.state=="paid"){
        DateTime tempDateTime = DateTime.parse(theOrder!.endDatetime!.substring(0,19)).add(const Duration(hours: 8));
        if(DateTime.now().isAfter(tempDateTime) || theOrder!.is_early_termination! == true){
          return Column(
            children: [
              Center(
                child: CustomElevatedButton(
                  text: '訂單已結束',
                  color: AppColor.green,
                  onPressed: (){
                  },
                ),
              ),
            ],
          );
        }else{
          DateTime tempDateTimeBefore12 = DateTime.parse(theOrder!.endDatetime!.substring(0,19)).add(const Duration(hours: 8-12));
          //結束前 24 hr 內, 不可提前結束
          if (DateTime.now().isAfter(tempDateTimeBefore12)){
            return Container();
          }else{
            return Column(
              children: [
                Center(
                  child: CustomElevatedButton(
                    text: '取消訂單 或 提前結束',
                    color: AppColor.purple,
                    onPressed: ()async{
                      final result = await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return CancelOrderDialog(theOrder: theOrder!);
                          });
                      if(result){
                        _postCancelOrder(theOrder!.id!);
                      }
                    },
                  ),
                ),
              ],
            );
          }
        }

      }else if(theOrder!.state=="unPaid"){
        return Column(
          children: [
            Center(
              child: CustomButton(
                text: '前往付款',
                color: Colors.red,
                onPressed: ()async{

                  final confirmBack = await _showConfirmDialog(context);
                  if(confirmBack){
                    String url = ServerApi.host+'newebpayApi/mpg_trade?order_id='+theOrder!.id!.toString();
                    final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context)=> OrderWebview(initUrl: url))
                    );
                    if(result=="reload"){
                      print("reload the page");
                      _getOrderDetail(widget.orderId);
                    }
                  }
                },
              ),
            ),
            Center(
              child: CustomElevatedButton(
                text: '修改訂單',
                color: AppColor.purple,
                onPressed: (){
                  var bookingModel = context.read<BookingModel>();
                  bookingModel.setBookingModelByCase(orderCase, theOrder!.servant!, orderDiseaseConditions, orderBodyConditions, orderServices, carerServices);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookingStep1Detail(careType: bookingModel.careType, city: bookingModel.city!),
                      ));
                },
              ),
            ),
          ],
        );
      }
    }
    return Container();
  }

  Future _showConfirmDialog(BuildContext context) {
    // Init
    AlertDialog dialog = AlertDialog(
      title: Text("Care168提醒您～！"),
      content: Text('付款下單前，請您先向服務者確認是否可以接案，以確保您的權益^_^'),
      actions: [
        ElevatedButton(
            child: Text("返回"),
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
            child: Text("下一步"),
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

  _getOrderStateBanner(){

      // print(theOrder!.createdAt);
      // DateTime tempDateTime = DateTime.parse(theOrder!.createdAt!.substring(0,19));
      // print(tempDateTime);
      // print(DateTime.now());
      // print(DateTime.now().difference(tempDateTime));

      if(theOrder!=null && theOrder!.state=='unPaid'){
        DateTime? orderCreateDateTime;
        try{
           orderCreateDateTime = DateTime.parse(theOrder!.createdAt!.substring(0,19)).add(const Duration(hours: 8));
        }catch(e){
           orderCreateDateTime = DateTime.now();
        }


        if (orderCase.servant == null) {
          if (DateTime.now().difference(orderCreateDateTime).inHours >= 6) {
            return Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              alignment: Alignment.center,
              color: Colors.red,
              child: Text('超過 6 小時，\n訂單已失效~', style: TextStyle(color: Colors.white), textAlign: TextAlign.center),
            );
          } else {
            return Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              alignment: Alignment.center,
              color: Colors.red,
              child: Text('成立時間: ${DateFormat('yyyy-MM-dd – kk:mm').format(orderCreateDateTime)}!\n提醒您，如未付款，\n此訂單將於6小時後，自動失效~', style: TextStyle(color: Colors.white), textAlign: TextAlign.center),
            );
          }
        }else{
          return Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
            alignment: Alignment.center,
            color: Colors.green,
            child: Text('此案已被他人承接！', style: TextStyle(color: Colors.white), textAlign: TextAlign.center),
          );
        }

    }else if (theOrder != null && theOrder!.state=='paid'){
        // order state 是 paid
        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
          alignment: Alignment.center,
          color: Colors.green,
          child: Text('服務者已接此案！', style: TextStyle(color: Colors.white), textAlign: TextAlign.center),
        );

    }else if (theOrder != null && theOrder!.state=='canceled'){
        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
          alignment: Alignment.center,
          color: Colors.black12,
          child: Text('訂單已取消！', style: TextStyle(color: Colors.white), textAlign: TextAlign.center),
        );
    }else{
        return Container();
    }
  }

  _orderStateTag(){
    if(theOrder!=null){
      if(theOrder!.state=='unPaid'){
        return CustomTag.theTag('未付款', Colors.red,false);
      }else if (theOrder!.state=='paid'){
        return CustomTag.theTag('已付款', Colors.green,false);
      }else{
        return CustomTag.theTag('已取消', Colors.grey,false);
      }
    }else{
      return Container();
    }
  }

  checkUserImage(String? imgPath){
    if(imgPath == null || imgPath == ''){
      return GestureDetector(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 15),
          height: 80,
          width: 80,
          decoration: const BoxDecoration(shape: BoxShape.circle),
          child: const Icon(Icons.account_circle_rounded,size: 64,color: Colors.grey,),
        ),
        onTap: ()async{
          Uri url = Uri.parse(ServerApi.getCarerUrl(theOrder!.servant!.id!).toString());
          if (!await launchUrl(url)) {
            throw 'Could not launch $url';
          }
        },
      );
    } else {
      return GestureDetector(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 15),
          height: 80,
          width: 80,
          decoration: BoxDecoration(
            color: Colors.grey,
            shape: BoxShape.circle,
            image: DecorationImage(
                image: NetworkImage(imgPath),
                fit: BoxFit.cover
            ),
          ),
        ),
        onTap: ()async{
          Uri url = Uri.parse(ServerApi.getCarerUrl(theOrder!.servant!.id!).toString());
          if (!await launchUrl(url)) {
            throw 'Could not launch $url';
          }
        },
      );
    }
  }

  caseTime(){
    if(orderCase.isContinuousTime == true){
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 4),
            child: Row(
              children: const [
                Text('案件時間  '),
                const SizedBox(width: 5,),
                Text('連續時間',style: TextStyle(color: Colors.red),),
              ],
            ),
          ),
          Row(
            children: [
              const Expanded(flex:2,child:SizedBox(),),
              const SizedBox(width: 5,),
              Expanded(flex:8,child: Text('開始：'+ orderCase.startDatetime!+'('+ Case.getTime(orderCase.startTime!)+')\n結束：' + orderCase.endDatetime!+'('+ Case.getTime(orderCase.endTime!)+')')),
            ],
          ),
        ],
      );
    } else if (orderCase.isContinuousTime == false){
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 4),
        child: Column(
          children: [
            Row(
              children: const [
                Text('案件時間  '),
                const SizedBox(width: 5,),
                Text('指定時段',style: TextStyle(color: Colors.red),),
              ],
            ),
            Row(
              children: [
                const Expanded(flex:2,child:SizedBox(),),
                const SizedBox(width: 5,),
                Expanded(flex:8,child: Text('${orderCase.startDatetime} ~ ${orderCase.endDatetime}'),)
              ],
            ),
            Row(
              children: [
                const Expanded(flex:2,child:SizedBox(),),
                const SizedBox(width: 5,),
                Expanded(flex:8,child: Text(careWeekDay()),)
              ],
            ),
            Row(
              children: [
                const Expanded(flex:2,child:SizedBox(),),
                const SizedBox(width: 5,),
                Expanded(flex:8,child: Text('${Case.getTime(orderCase.startTime!)} ~ ${Case.getTime(orderCase.endTime!)}')),
              ],
            ),
          ],
        ),
      );
    }
  }

  careWeekDay(){
    List<String> weekDays = orderCase.weekday!.split(',');
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

  checkNeedServices(){
    List<String> needServiceStrings = [];
    for(var service in orderServices){
      needServiceStrings.add(service.name!);
    }
    return needServiceStrings;
  }

  neededServices(){
    List<Padding> needServices = [];
    for(var service in orderServices){
      needServices.add(
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTag.iconYes,
              const SizedBox(width: 10,),
              (service.remark != null)?
                Expanded(child:
                  RichText(
                    text: TextSpan(
                      text: service.name,
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                      children: <TextSpan>[
                        TextSpan(text: '\n'+_checkToChangeLine(service.remark!), style: const TextStyle(color: AppColor.darkGrey)),
                      ],
                    ),
                  )
                )
                    :
                Text(service.name!),
            ],
          ),
        )
      );
    }
    return Column(children: needServices,);
  }
  
  String _checkToChangeLine(String text){
    return text.replaceAll('※', '\n※');
  }

  neededServicesExtraPrice(){
    return ListView.builder(
        scrollDirection: Axis.vertical,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: increaseServiceMoneys.length,
        itemBuilder:(context, index){
          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${Service.getServiceNameFromId(increaseServiceMoneys[index].service!)} + ${increaseServiceMoneys[index].increasePercent} % '),
              Text('\$${increaseServiceMoneys[index].increaseMoney}'),
            ],);
        });
  }

  kRowContent(String title, String text){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(title),
          ),
          Expanded(
            flex: 6,
            child: Text(text),
          ),
        ],
      ),
    );

  }

  Future _getOrderDetail(int orderId) async {
    var userModel = context.read<UserModel>();
    String path = ServerApi.PATH_ORDERS + orderId.toString();
    print(userModel.token);
    try {
      final response = await http.get(ServerApi.standard(path: path),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'Authorization': 'token ${userModel.token!}'},
      );
      // print(response.body);
      if (response.statusCode == 200) {
        Map<String, dynamic> map = json.decode(utf8.decode(response.body.runes.toList()));
        orderDetailMap = map;
        theOrder = Order.fromJson(orderDetailMap);
        orderCase = Case.fromJson(orderDetailMap['related_case']);
        // orderCarer = Carer.fromJson(orderDetailMap['servants']);
        orderServices = List<Service>.from(orderDetailMap['related_case']['services'].map((i) => Service.fromJson(i)));
        orderDiseaseConditions = List<DiseaseCondition>.from(orderDetailMap['related_case']['disease'].map((i) => DiseaseCondition.fromJson(i)));
        orderBodyConditions = List<BodyCondition>.from(orderDetailMap['related_case']['body_condition'].map((i) => BodyCondition.fromJson(i)));

        increaseServiceMoneys = List<ServiceIncreaseMoney>.from(orderDetailMap['increase_services'].map((i) => ServiceIncreaseMoney.fromJson(i)));

        for(var disease in orderDiseaseConditions){
          orderDiseaseNames.add(disease.name!);
        }
        for(var condition in orderBodyConditions){
          orderConditionNames.add(condition.name!);
        }

        _getServantServices(theOrder!.servant!.id!);
        setState(() {});
      }
    } catch (e) {
      print(e);
    }
  }

  Future _getServantServices(int servantId) async {
    String path = ServerApi.PATH_SEARCH_SERVANTS + servantId.toString();
    try {
      final response = await http.get(
          ServerApi.standard(path: path));
      if (response.statusCode == 200) {
        // print(response.body);
        Map<String, dynamic> map = json.decode(utf8.decode(response.body.runes.toList()));
        carerServices = List<Service>.from(map['services'].map((i) => Service.fromJson(i)));
      }
    } catch (e) {
      print(e);
    }
  }

  Future _postCancelOrder(int orderId) async{
    var userModel = context.read<UserModel>();

    String path = ServerApi.PATH_CANCEL_ORDER;

    DateTime now = DateTime.now();
    // print(now.toString());
    // print(DateFormat('yyyy-MM-dd – kk:mm').format(now));
    print(DateFormat('yyyy-MM-dd,kk:mm').format(now));

    final queryParams = {
      'order_id': orderId.toString(),
      'end_datetime': DateFormat('yyyy-MM-dd,kk:mm').format(now),
    };

    final response = await http.post(ServerApi.standard(path: path,queryParameters: queryParams),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Token ${userModel.token!}',
      },
    );

    print(response.statusCode);
    _printLongString(response.body);

    if(response.statusCode == 200){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("成功取消訂單！請至聊聊訊息查看～"),));
      // userModel.setUserUnReadNum(userModel.user!.totalUnReadNum!+1);
      // Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(
            builder: (context) => const Messages(),
          )
          , (route) => route.isFirst);
    }else{
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("取消失敗，請聯繫平台客服！"),));
    }

  }

  void _printLongString(String text) {
    final RegExp pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern.allMatches(text).forEach((RegExpMatch match) =>   print(match.group(0)));
  }

}
