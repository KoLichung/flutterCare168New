import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttercare168/constant/color.dart';
import 'package:fluttercare168/constant/review_stars.dart';
import '../../../models/review.dart';


class MyBookingDetailReadReviewDialog extends StatefulWidget {
  final String name;
  final Review review;
  const MyBookingDetailReadReviewDialog({Key? key, required this.name, required this.review}) : super(key: key);
  @override
  _MyBookingDetailReadReviewDialogState createState() => _MyBookingDetailReadReviewDialogState();
}

class _MyBookingDetailReadReviewDialogState extends State<MyBookingDetailReadReviewDialog> {

  @override
  Widget build(BuildContext context) {

    return AlertDialog(
      contentPadding: const EdgeInsets.all(0),
      content: Container(
        height: 350,
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
            Text('我給服務者 ${widget.review.servantName} 的評價',style: const TextStyle(fontWeight: FontWeight.bold),),
            const Divider(color: Colors.black, thickness: 1, height: 30,),
            widget.review.servantRatingCreatedAt == null ? const Text('') : Text((widget.review.servantRatingCreatedAt!).substring(0,10), style: const TextStyle(fontSize: 14),),
            const SizedBox(height: 10,),
            ReviewStars.getReviewStars(widget.review.servantRating!),
            const SizedBox(height: 10,),
            Expanded(
              child: Text('"${widget.review.servantComment}"'),
            )
          ],
        ),
      ),
    );
  }
}


