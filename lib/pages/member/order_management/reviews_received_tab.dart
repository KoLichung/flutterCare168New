import 'package:flutter/material.dart';
import 'package:fluttercare168/constant/review_stars.dart';
import 'package:fluttercare168/constant/server_api.dart';
import 'package:fluttercare168/models/review.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttercare168/notifier_model/user_model.dart';
import 'package:provider/provider.dart';

class ReviewsReceivedTab extends StatefulWidget {
  const ReviewsReceivedTab({Key? key}) : super(key: key);
  @override
  _ReviewsReceivedTabState createState() => _ReviewsReceivedTabState();
}

class _ReviewsReceivedTabState extends State<ReviewsReceivedTab> {
  List<Review> receivedReviewList = [];
  void initState() {
    // TODO: implement initState
    super.initState();
    _getReceivedReviewList();
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 20,),
        receivedReviewList.isEmpty ? const Text('尚無評價') : Text('總共 ${receivedReviewList[0].userRatingNums!} 筆評價  |  平均 ${receivedReviewList[0].userAvgRate!} 顆星'),
        const SizedBox(height: 10,),
        receivedReviewList.isEmpty ? ReviewStars.star0 : ReviewStars.getReviewStars(receivedReviewList[0].userAvgRate!),
        const SizedBox(height: 10,),
        const Divider(color: Color(0xffC0C0C0),),
        ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: receivedReviewList.length,
            itemBuilder: (BuildContext context,int i){
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Row(
                      children: [
                        Container(
                          height: 60,
                          width: 60,
                          decoration: const BoxDecoration(
                              color: Colors.red, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 10,),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(receivedReviewList[i].servantName!),
                                  ReviewStars.getReviewStars(receivedReviewList[i].caseOffenderRating!)
                                ],
                              ),
                              Text('${receivedReviewList[i].startDatetime} ~ ${receivedReviewList[i].endDatetime}  |  ${receivedReviewList[i].isContinuousTime == 'True' ? '連續時間' : '指定時段'}  |  ${receivedReviewList[i].careType}',style: const TextStyle(fontSize: 12),)],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22,0,20,10),
                    child: Text(receivedReviewList[i].caseOffenderComment!),
                  ),
                  const Divider(
                    color: Color(0xffC0C0C0),
                  ),
                ],
              );
            }
        ),
      ],
    );
  }
  Future _getReceivedReviewList() async {
    var userModel = context.read<UserModel>();
    String path = ServerApi.PATH_REVIEW;
    try {
      final response = await http.get(ServerApi.standard(path: path, queryParameters: {
        'review_type':'received',
      }),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'Authorization': 'token ${userModel.token!}'},
      );
      if (response.statusCode == 200) {
        List<dynamic> parsedListJson = json.decode(utf8.decode(response.body.runes.toList()));
        List<Review> data = List<Review>.from(parsedListJson.map((i) => Review.fromJson(i)));
        receivedReviewList = data;
        setState(() {});
      }
    } catch (e) {
      print(e);
    }
  }
}
