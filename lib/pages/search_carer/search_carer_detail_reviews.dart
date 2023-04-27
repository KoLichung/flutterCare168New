import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fluttercare168/constant/review_stars.dart';
import 'package:fluttercare168/constant/server_api.dart';
import 'package:fluttercare168/models/review.dart';

class SearchCarerDetailReviews extends StatefulWidget {
  final List<Review> reviews;
  const SearchCarerDetailReviews({Key? key, required this.reviews}) : super(key: key);

  @override
  _SearchCarerDetailReviewsState createState() => _SearchCarerDetailReviewsState();
}

class _SearchCarerDetailReviewsState extends State<SearchCarerDetailReviews> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('所有評價'),),
      body:ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: widget.reviews.length,
              itemBuilder:(BuildContext context,int i){
                return  Container(
                  margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  color: const Color(0xffF2F2F2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          checkUserImage(widget.reviews[i].neederImage),
                          const SizedBox(width: 10,),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Text(widget.reviews[i].neederName!),
                                    // ReviewStars.getReviewStars(widget.reviews[i].servantRating!)
                                    (widget.reviews![i].neederName!=null)?
                                    Text(widget.reviews![i].neederName!)
                                        :
                                    Text("unknown"),
                                    ReviewStars.getReviewStars(widget.reviews![i].servantRating!)
                                  ],
                                ),
                                // Text('${widget.reviews[i].isContinuousTime! =='true' ? '連續時間' : '指定時段'}  |  ${widget.reviews[i].careType!}',style: const TextStyle(fontSize: 12),)
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15,),
                      Text('"${widget.reviews[i].servantComment!}"'),
                      const SizedBox(height: 15,),
                      Align(
                          alignment: Alignment.bottomRight,
                          child: Text('建立於 ${widget.reviews[i].servantRatingCreatedAt!.substring(0,10)}',style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12),)),
                    ],
                  ),
                );
              }),
    );
  }
  checkUserImage(String? imgPath) {
    if (imgPath == null || imgPath == '') {
      return Container(
        height: 70,
        width: 70,
        decoration: const BoxDecoration(shape: BoxShape.circle),
        child: const Icon(Icons.account_circle_rounded, size: 64, color: Colors.grey,),
      );
    } else {
      return Container(
        height: 70,
        width: 70,
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
}
