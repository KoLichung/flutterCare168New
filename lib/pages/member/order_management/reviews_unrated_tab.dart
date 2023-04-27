import 'package:flutter/material.dart';
import 'package:fluttercare168/constant/custom_tag.dart';
import 'package:fluttercare168/constant/server_api.dart';
import 'package:fluttercare168/models/review.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'write_review_to_carer_dialog.dart';
import 'package:fluttercare168/notifier_model/user_model.dart';
import 'package:provider/provider.dart';

class ReviewsUnratedTab extends StatefulWidget {
  const ReviewsUnratedTab({Key? key}) : super(key: key);

  @override
  _ReviewsUnratedTabState createState() => _ReviewsUnratedTabState();
}

class _ReviewsUnratedTabState extends State<ReviewsUnratedTab> {
  List<Review> unratedReviewList = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getUnratedReviewList();
  }
  @override
  Widget build(BuildContext context) {

    if(unratedReviewList.isEmpty){
      return const Center(child: Text('沒有待評價~'),);
    } else {
      return ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: unratedReviewList.length,
          itemBuilder: (BuildContext context,int i){
            return Column(
              children: [
                GestureDetector(
                  onTap: () async {
                    var data = await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return WriteReviewToCarerDialog(review: unratedReviewList[i],);
                        });
                    if(data == 'reload') {
                      print('return text = $data');
                      setState(() {
                        print('return text inside setState = $data');
                        _getUnratedReviewList();
                      });
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [unratedReviewList[i].careType == '居家照顧' ? CustomTag.homeCare : CustomTag.hospitalCare,],),
                        const SizedBox(height: 4,),
                        Text('${unratedReviewList[i].startDatetime} ~ ${unratedReviewList[i].endDatetime} | ${unratedReviewList[i].isContinuousTime == "True" ? '連續時間' : '指定時段'}',style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 16)),
                        const SizedBox(height: 4,),
                        Text('${unratedReviewList[i].servantName!} 還在等您的評價~！',style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 16))
                      ],
                    ),
                  ),
                ),
                const Divider(color: Color(0xffC0C0C0),),
              ],
            );
          }
      );
    }
  }
  Future _getUnratedReviewList() async {
    var userModel = context.read<UserModel>();
    String path = ServerApi.PATH_REVIEW;
    try {
      final response = await http.get(ServerApi.standard(path: path, queryParameters: {
        'review_type':'unrated',
      }),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'Authorization': 'token ${userModel.token!}'},
      );
      if (response.statusCode == 200) {
        List<dynamic> parsedListJson = json.decode(utf8.decode(response.body.runes.toList()));
        List<Review> data = List<Review>.from(parsedListJson.map((i) => Review.fromJson(i)));
        unratedReviewList = data;
        setState(() {});
      }
    } catch (e) {
      print(e);
    }
  }
}
