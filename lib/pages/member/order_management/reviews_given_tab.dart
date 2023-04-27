import 'package:flutter/material.dart';
import 'package:fluttercare168/constant/review_stars.dart';
import 'package:fluttercare168/constant/server_api.dart';
import 'package:fluttercare168/models/review.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttercare168/notifier_model/user_model.dart';
import 'package:provider/provider.dart';

class ReviewsGivenTab extends StatefulWidget {
  const ReviewsGivenTab({Key? key}) : super(key: key);
  @override
  _ReviewsGivenTabState createState() => _ReviewsGivenTabState();
}
//我的評價 (我給的評價)
class _ReviewsGivenTabState extends State<ReviewsGivenTab> {
  List<Review> givenReviewList = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getGivenReviewList();
  }
  @override
  Widget build(BuildContext context) {
    if(givenReviewList.isEmpty){
      return const Center(child: Text('您還沒有寫過任何評價~'),);
    } else {
      return ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: givenReviewList.length,
          itemBuilder: (BuildContext context,int i){
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Row(
                    children: [
                      //這裡應該是要servant image
                      checkCarerImage(givenReviewList[i].servantImage),
                      const SizedBox(width: 10,),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${givenReviewList[i].servantName}'),
                                ReviewStars.getReviewStars(givenReviewList[i].servantRating!),
                              ],
                            ),
                            Text('${givenReviewList[i].startDatetime} ~ ${givenReviewList[i].endDatetime}  |  ${givenReviewList[i].isContinuousTime == 'True' ? '連續時間' : '指定時段'}  |  ${givenReviewList[i].careType}',style: const TextStyle(fontSize: 12),)],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(22,0,20,10),
                  child: Text('"${givenReviewList[i].servantComment!}"'),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: Align(
                      alignment: Alignment.bottomRight,
                      child: Text('建立於 ${givenReviewList[i].servantRatingCreatedAt!.substring(0,10)}',style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12),)),
                ),
                const Divider(color: Color(0xffC0C0C0),),
              ],
            );
          }
      );
    }
  }

  checkCarerImage(String? imgPath) {
    if (imgPath == null || imgPath == '') {
      return Container(
        height: 60,
        width: 60,
        decoration: const BoxDecoration(shape: BoxShape.circle),
        child: const Icon(Icons.account_circle_rounded, size: 64, color: Colors.grey,),
      );
    } else {
      return Container(
        height: 60,
        width: 60,
        decoration: BoxDecoration(
          color: Colors.grey,
          shape: BoxShape.circle,
          image: DecorationImage(
              image: NetworkImage(ServerApi.host + imgPath),
              fit: BoxFit.cover
          ),
        ),
      );
    }
  }

  Future _getGivenReviewList() async {
    var userModel = context.read<UserModel>();
    String path = ServerApi.PATH_REVIEW;
    try {
      final response = await http.get(ServerApi.standard(path: path, queryParameters: {
        'review_type':'given',
      }),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'Authorization': 'token ${userModel.token!}'},
      );
      if (response.statusCode == 200) {
        List<dynamic> parsedListJson = json.decode(utf8.decode(response.body.runes.toList()));
        List<Review> data = List<Review>.from(parsedListJson.map((i) => Review.fromJson(i)));
        givenReviewList = data;
        setState(() {});
      }
    } catch (e) {
      print(e);
    }
  }
}
