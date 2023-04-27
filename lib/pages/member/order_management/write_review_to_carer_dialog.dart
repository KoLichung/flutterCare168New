import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttercare168/constant/color.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttercare168/models/review.dart';
import 'package:fluttercare168/widgets/custom_elevated_button.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../constant/server_api.dart';
import 'package:provider/provider.dart';
import 'package:fluttercare168/notifier_model/user_model.dart';


class WriteReviewToCarerDialog extends StatefulWidget {
  final Review review;
  const WriteReviewToCarerDialog({Key? key, required this.review}) : super(key: key);

  @override
  _WriteReviewToCarerDialogState createState() => new _WriteReviewToCarerDialogState();
}

class _WriteReviewToCarerDialogState extends State<WriteReviewToCarerDialog> {
  TextEditingController reviewController = TextEditingController();
  double? stars;
  bool isShowWarningMsg = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(0),
      content: Container(
        height: isShowWarningMsg? 410 : 380,
        width: 360,
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                child: Container(
                  width: 24,
                  height: 24,
                  child: const Icon(Icons.clear, size: 16,color: Colors.white,),
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColor.purple),
                ),
                onTap: (){
                  Navigator.pop(context);
                },
              ),
            ),
            Text('給服務者評價',style: const TextStyle(fontWeight: FontWeight.bold),),
            const SizedBox(height: 10,),
            RatingBar.builder(
              initialRating: 0,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.yellow,
              ),
              onRatingUpdate: (rating) {
                print(rating);//rating type = double
                setState(() {
                  stars=rating;
                });
              },
            ),
            const SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.fromLTRB(10,10,10,0),
              child: TextField(
                maxLines: 8,
                controller: reviewController,
                decoration: const InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 1,color: AppColor.purple),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 1,color: AppColor.purple),
                  ),
                  hintText: '請輸入您的評價 (150字內)',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),
            Visibility(
              visible: isShowWarningMsg,
              child: const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text('請輸入完整評價!!',style: TextStyle(color: Colors.red, fontSize: 14),),
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.only(bottom: 10),
          child: CustomElevatedButton(
              text: '確定送出',
              color: AppColor.purple,
              onPressed: (){
                if(stars == null || reviewController.text ==''){
                  setState(() {
                    isShowWarningMsg = true;
                  });
                } else {
                  String returnText = 'reload';
                  Navigator.pop(context,returnText);
                  var userModel = context.read<UserModel>();
                  _putUpdateGiveCarerReview(userModel.token!, stars.toString(), reviewController.text);
                }
              }),
        ),
      ],
    );
  }
  Future _putUpdateGiveCarerReview (String token, String stars, String comment)async{
    String path = ServerApi.PATH_REVIEW + widget.review.id.toString() + '/';
    try{
      final bodyParams ={
        'servant_rating':stars,
        'servant_comment':comment,
      };
      final response = await http.put(ServerApi.standard(path:path, queryParameters: bodyParams),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'token $token'
        },
        body: jsonEncode(bodyParams),
      );
      // print(response.statusCode);
      if(response.statusCode == 200){
        print('success update review');
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("評價已送出！"),
            )
        );
      }
    } catch (e){
      print(e);
    }
  }
}


