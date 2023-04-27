import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttercare168/constant/review_stars.dart';
import 'package:fluttercare168/constant/custom_tag.dart';
import 'package:fluttercare168/models/case.dart';
import 'package:fluttercare168/pages/member/my_service/my_case_detail_page.dart';
import 'package:fluttercare168/models/city.dart';
import 'package:fluttercare168/models/county.dart';
import 'package:fluttercare168/constant/server_api.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttercare168/notifier_model/user_model.dart';
import 'package:provider/provider.dart';

class MyCasesPage extends StatefulWidget {
  const MyCasesPage({Key? key}) : super(key: key);

  @override
  _MyCasesPageState createState() => _MyCasesPageState();
}

class _MyCasesPageState extends State<MyCasesPage> {

  List<Case> myCasesList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getMyCasesList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我接的案'),),
      body: ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: myCasesList.length,
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
                                checkCaseStatus(myCasesList[i].state!),
                                const SizedBox(width: 6,),
                                myCasesList[i].careType == '居家照顧' ? CustomTag.homeCare : CustomTag.hospitalCare,
                              ],),
                            const SizedBox(height: 10,),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${myCasesList[i].startDatetime!}~${myCasesList[i].endDatetime!}' ),
                                // Row(
                                //   children: [
                                //     const Text('時間類型：'),
                                //     myCasesList[i].isContinuousTime == true ? const Text('連續時間') : const Text('指定時段'),
                                //   ],
                                // ),
                                Row(
                                  children: [
                                    myCasesList[i].neederName == null
                                        ? const Text('委託人：委託人帳號已刪除', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))
                                        : Text('委託人：${myCasesList[i].neederName!}',  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  ],
                                ),
                                Row(
                                  children: [
                                    // const Text('地點：'),
                                    Text(City.getCityNameFromId(myCasesList[i].city!)),
                                    Text(County.getCountyNameFromId(myCasesList[i].county!)),
                                    (myCasesList[i].careType == '醫院看護')?
                                    Text(' ${myCasesList[i].hospitalName!}')
                                        :
                                    Text(' ${myCasesList[i].roadName!}'),
                                  ],
                                ),
                                // Wrap(children: [
                                //   const Text('案主評價：',),
                                //   ReviewStars.getReviewStars(myCasesList[i].servantRating!),
                                // ],),
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
                                  builder: (context) => MyCaseDetailPage(theCase: myCasesList[i],),
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
                      builder: (context) => MyCaseDetailPage(theCase: myCasesList[i],),
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
      return const Text('');
    }
  }

  Future _getMyCasesList() async {
    var userModel = context.read<UserModel>();
    String path = ServerApi.PATH_SERVANT_CASES;
    try {
      final response = await http.get(ServerApi.standard(path: path),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'Authorization': 'token ${userModel.token!}'},
      );
      if (response.statusCode == 200) {
        // print(response.body);
        List<dynamic> parsedListJson = json.decode(utf8.decode(response.body.runes.toList()));
        List<Case> data = List<Case>.from(parsedListJson.map((i) => Case.fromJson(i)));
        myCasesList = data;
        setState(() {});
      }
    } catch (e) {
      print(e);
    }
  }


}
