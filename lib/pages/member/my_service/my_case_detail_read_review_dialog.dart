import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttercare168/constant/color.dart';
import 'package:fluttercare168/constant/review_stars.dart';
import '../../../models/review.dart';


class MyCaseDetailReadReviewDialog extends StatefulWidget {
  final String name;
  final Review review;
  const MyCaseDetailReadReviewDialog({Key? key, required this.name, required this.review}) : super(key: key);
  @override
  _MyCaseDetailReadReviewDialogState createState() => _MyCaseDetailReadReviewDialogState();
}

class _MyCaseDetailReadReviewDialogState extends State<MyCaseDetailReadReviewDialog> {

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
            Text('我給委託人的評價',style: const TextStyle(fontWeight: FontWeight.bold),),
            const Divider(color: Colors.black, thickness: 1, height: 30,),
            widget.review.caseOffenderRatingCreatedAt == null ? const Text('') : Text((widget.review.caseOffenderRatingCreatedAt!).substring(0,10), style: const TextStyle(fontSize: 14),),
            const SizedBox(height: 10,),
            ReviewStars.getReviewStars(widget.review.caseOffenderRating!),
            const SizedBox(height: 10,),
            Expanded(
              child: Text('"${widget.review.caseOffenderComment}"'),
            )
          ],
        ),
      ),
    );
  }
}


