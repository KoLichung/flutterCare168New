import 'package:flutter/cupertino.dart';
import 'package:fluttercare168/models/case.dart';
import 'package:fluttercare168/models/message.dart';
import 'package:flutter/material.dart';
import 'package:fluttercare168/pages/messages/order_page.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constant/color.dart';
import '../../constant/custom_tag.dart';
import 'package:http/http.dart' as http;
import '../../../../constant/custom_tag.dart';
import 'package:fluttercare168/notifier_model/user_model.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../constant/server_api.dart';
import '../../models/order.dart';

class MessageBubble extends StatefulWidget {
  final Message message;
  final Function onPressed;
  const MessageBubble({Key? key, required this.message, required this.onPressed}) : super(key: key);

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {

  // Map<String, dynamic> caseDetailMap = {};
  Case? theCase;
  Order? theOrder;

  // bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    final isMe = widget.message.messageIsMine!;
    final backgroundColor = isMe ? AppColor.purple : Colors.white;
    final color = isMe ? Colors.white : Colors.grey.shade700;

    if(widget.message.isThisMessageOnlyCase!=null && widget.message.isThisMessageOnlyCase!){
      theCase = widget.message.caseDetail!;
      theOrder = widget.message.orderDetail!;
    }

    return (widget.message.isThisMessageOnlyCase == false)
        ? (widget.message.image != null)
          ? Container(
            margin: const EdgeInsets.all(10),
            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
            child: GestureDetector(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.5,
                ),
                child: Image.network(widget.message.image!,fit: BoxFit.cover),
              ),
              onTap: () async {
                print('image tapped');
                Uri url = Uri.parse(widget.message.image!);
                if (!await launchUrl(url)) {
                  throw 'Could not launch $url';
                }
              },
            )
          )
          : Container(
            margin: const EdgeInsets.all(10),
            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 1,
                ),
                child: Column(
                  children: [
                    Material(
                      borderRadius: BorderRadius.circular(20),
                      color: backgroundColor,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        child: Text(_filterMeesagePhone(widget.message.content.toString()) , style: TextStyle(color: color, fontSize: 19),
                        ),
                      ),
                    ),
                    Text(getTimeString(widget.message.createAt!)),
                  ],
                ),
            ),
          )
        :  Container(
                color: Colors.white,
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.fromLTRB(0,4,0,12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          child: (theOrder!.servant!=null && theOrder!.servant!.image!=null)?
                          Container(
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              image: DecorationImage(
                                  image:NetworkImage(theOrder!.servant!.image!),
                                  fit:BoxFit.cover),),
                            height: 68,
                            width: 68,
                          )
                              :
                          Container(
                            margin: const EdgeInsets.only(right: 12),
                            height: 68,
                            width: 68,
                            decoration: const BoxDecoration(shape: BoxShape.circle),
                            child: const Icon(Icons.account_circle_rounded,size: 64,color: Colors.grey,),
                          ),
                          onTap: ()async{
                            Uri url = Uri.parse(ServerApi.getCarerUrl(theOrder!.servant!.id!).toString());
                            if (!await launchUrl(url)) {
                              throw 'Could not launch $url';
                            }
                          },
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                theCase!.careType == '居家照顧' ? CustomTag.homeCare : CustomTag.hospitalCare,
                                const SizedBox(width: 5,),
                                theCase!.isContinuousTime! ? CustomTag.continuousTime : CustomTag.weeklyTime,
                              ],
                            ),
                            const SizedBox(height: 5,),
                            // checkCarerLanguage(),
                            checkCarerWage(),
                          ],
                        ),
                      ],
                    ),
                    const Divider(),
                    Text('申請時間：${getTimeString(theOrder!.createdAt!)}',style: const TextStyle(fontWeight: FontWeight.bold),),
                    const SizedBox(height: 5,),
                    Text('服務時間：${theCase!.startDatetime!.substring(0,10)} ~ ${theCase!.endDatetime!.substring(0,10)}',style: const TextStyle(fontWeight: FontWeight.bold),),
                    const SizedBox(height: 5,),
                    Center(
                      child: ElevatedButton(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10,vertical: 4),
                          child: getCaseButtonText(),
                        ),
                        style: ElevatedButton.styleFrom(primary: AppColor.green, elevation: 0),
                        onPressed: (){
                          widget.onPressed();
                          //在這裡要 navigator 去訂單頁
                          // var userModel = context.read<UserModel>();
                          // if(theCase!.servant == null){
                          //   Navigator.push(
                          //   context,
                          //   MaterialPageRoute(builder: (context)=> const OrderPage()));
                          // }else{
                          //   if( (userModel.user!.id == theCase!.user) || (userModel.user!.id == theCase!.servant!.id) ){
                          //     Navigator.push(
                          //         context,
                          //         MaterialPageRoute(builder: (context)=> const OrderPage()));
                          //   }
                          // }
                        },
                      ),
                    ),
                  ],)
              );
  }



  String _filterMeesagePhone(String text){
    return text.replaceAll(RegExp('[0-9]{5,10}'), '［系統提醒：請勿在此輸入聯絡電話！］');
  }

  getTimeString(String createAt){
    DateTime tempDate = DateTime.parse(createAt).add(const Duration(hours: 8));
    return DateFormat('yyyy-MM-dd kk:mm').format(tempDate);
  }

  getCaseButtonText(){
    if(theCase!=null){
      if(theCase!.servant == null){
        return Text('查看訂單詳情');
      }else{
        var userModel = context.read<UserModel>();
        if( (userModel.user!.id == theCase!.user) || (userModel.user!.id == theCase!.servant!.id) ){
          return Text('查看訂單詳情');
        }else{
          return Text('此案已被其他服務者承接');
        }
      }
    }
    return Text('無案件訊息');
  }

  checkCarerWage(){
    // print(theOrder!.servant!);
    // print(theOrder!.servant!.isHome);
    // print(theOrder!.servant!.isHospital);
    // return Container();
    if(theOrder!.servant!.isHome! == true && theOrder!.servant!.isHospital! == true){
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('居家照顧'),
          Text('時薪 \$${_getWageWords(theOrder!.servant!.homeHourWage!)}｜半天 \$${_getWageWords(theOrder!.servant!.homeHalfDayWage!)}｜全天 \$${_getWageWords(theOrder!.servant!.homeOneDayWage!)} '),
          const Text('醫院看護'),
          Text('時薪 \$${_getWageWords(theOrder!.servant!.hospitalHourWage!)}｜半天 \$${_getWageWords(theOrder!.servant!.hospitalHalfDayWage!)}｜全天 \$${_getWageWords(theOrder!.servant!.hospitalOneDayWage!)} '),
        ],
      );
    } else if (theOrder!.servant!.isHome! == true && theOrder!.servant!.isHospital! == false){
      return  Text('時薪 \$${_getWageWords(theOrder!.servant!.homeHourWage!)}｜半天 \$${_getWageWords(theOrder!.servant!.homeHalfDayWage!)}｜全天 \$${_getWageWords(theOrder!.servant!.homeOneDayWage!)} ');
    } else if (theOrder!.servant!.isHome! == false  && theOrder!.servant!.isHospital! == true){
      return  Text('時薪 \$${_getWageWords(theOrder!.servant!.hospitalHourWage!)}｜半天 \$${_getWageWords(theOrder!.servant!.hospitalHalfDayWage!)}｜全天 \$${_getWageWords(theOrder!.servant!.hospitalOneDayWage!)}');
    }else{
      return Container();
    }
  }

  String _getWageWords(int wage){
    if(wage != 0){
      return wage.toString();
    }else{
      return '無服務';
    }
  }

  checkCarerLanguage(){
    print(theOrder!.servant!.languages);
    List<String> languageStrings = [];
    for(var language in theOrder!.servant!.languages!){
      if (language.languageName == '其他' || language.languageName == '原住民語'){
        languageStrings.add(language.languageName! + '(' + language.remark! + ')');
      } else {
        languageStrings.add(language.languageName!);
      }
    }
    return Text(languageStrings.join(','), overflow: TextOverflow.visible,);
  }

  // Future _getCaseDetail() async {
  //   var userModel = context.read<UserModel>();
  //   String path = ServerApi.PATH_NEED_CASES + widget.message.theCase.toString();
  //   try {
  //     final response = await http.get(ServerApi.standard(path: path),
  //       headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'Authorization': 'token ${userModel.token!}'},
  //     );
  //     // print(response.body);
  //     if (response.statusCode == 200) {
  //       Map<String, dynamic> map = json.decode(utf8.decode(response.body.runes.toList()));
  //       caseDetailMap = map;
  //       theCase = Case.fromJson(caseDetailMap);
  //       setState(() {
  //         isLoading = false;
  //       });
  //     }
  //   } catch (e) {
  //     print(e);
  //   }
  // }
}
