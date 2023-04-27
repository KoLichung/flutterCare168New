import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttercare168/constant/custom_tag.dart';
import 'package:fluttercare168/models/carer.dart';
import 'package:fluttercare168/models/case.dart';
import 'package:fluttercare168/pages/member/order_management/my_booking_detail_page.dart';
import 'package:fluttercare168/constant/server_api.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttercare168/notifier_model/user_model.dart';
import 'package:provider/provider.dart';

import '../../../models/city.dart';
import '../../../models/county.dart';

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({Key? key}) : super(key: key);

  @override
  _MyBookingsPageState createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  List<Case> myBookingList = [];
  // Carer myBookingCarer = Carer();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getMyBookingList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我發的需求案件'),),
      body: ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: myBookingList.length,
          itemBuilder: (BuildContext context,int i){
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                checkCaseStatus(myBookingList[i].state!),
                                const SizedBox(width: 6,),
                                myBookingList[i].careType == '居家照顧' ? CustomTag.homeCare : CustomTag.hospitalCare,
                              ],
                            ),
                            const SizedBox(height: 10,),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${myBookingList[i].startDatetime!}~${myBookingList[i].endDatetime!}' ),
                                // Row(
                                //   children: [
                                //     const Text('時間類型：'),
                                //     myBookingList[i].isContinuousTime == true ? const Text('連續時間') : const Text('指定時段'),
                                //   ],
                                // ),
                                (myBookingList[i].servant!=null)
                                    ? Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('服務者：'+ myBookingList[i].servant!.name!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                                          Row(
                                            children: [
                                              Text(City.getCityNameFromId(myBookingList[i].city!)),
                                              Text(County.getCountyNameFromId(myBookingList[i].county!)),
                                              (myBookingList[i].careType == '醫院看護')
                                                  ? Text(' ${myBookingList[i].hospitalName!}')
                                                  : Text(' ${myBookingList[i].roadName!}'),
                                            ],
                                          ),
                                        ],
                                      )
                                    : Row(
                                  children: [
                                    // const Text('地點：'),
                                    Text(City.getCityNameFromId(myBookingList[i].city!)),
                                    Text(County.getCountyNameFromId(myBookingList[i].county!)),
                                    (myBookingList[i].careType == '醫院看護')
                                        ? Text(' ${myBookingList[i].hospitalName!}')
                                        : Text(' ${myBookingList[i].roadName!}'),
                                  ],
                                ),
                                // Row(
                                //   children: [
                                //     // const Text('地點：'),
                                //     Text(City.getCityNameFromId(myBookingList[i].city!)),
                                //     Text(County.getCountyNameFromId(myBookingList[i].county!)),
                                //     (myBookingList[i].careType == '醫院看護')
                                //         ? Text(' ${myBookingList[i].hospitalName!}')
                                //         : Text(' ${myBookingList[i].roadName!}'),
                                //   ],
                                // ),
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward_ios),
                          onPressed: (){
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MyBookingDetailPage(theCase: myBookingList[i],),
                                ));
                          },
                        )
                      ],
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
                    MaterialPageRoute(
                      builder: (context) => MyBookingDetailPage(theCase: myBookingList[i],),
                    ));
              },
            );
          }
      ),
    );
  }

  checkCaseStatus(String status){
    if(status == 'unTaken'){
      return CustomTag.statusUnTaken;
    } else if(status == 'unComplete'){
      return CustomTag.statusUnComplete;
    } else if (status == 'Complete'){
      return CustomTag.statusComplete;
    } else if (status == 'Canceled'){
      return CustomTag.statusCanceled;
    } else if (status == 'endEarly'){
      return CustomTag.statusEndEarly;
    } else {
      return Text('');
    }
  }

  Future _getMyBookingList() async {
    var userModel = context.read<UserModel>();
    String path = ServerApi.PATH_NEED_CASES;
    try {
      final response = await http.get(ServerApi.standard(path: path),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'Authorization': 'token ${userModel.token!}'},
      );
      if (response.statusCode == 200) {
        List<dynamic> parsedListJson = json.decode(utf8.decode(response.body.runes.toList()));
        List<Case> data = List<Case>.from(parsedListJson.map((i) => Case.fromJson(i)));
        myBookingList = data;

        setState(() {});
      }
    } catch (e) {
      print(e);
    }
  }
}
