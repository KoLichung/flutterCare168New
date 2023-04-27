import 'package:flutter/material.dart';

class ReviewStars{

  static getReviewStars(num reviewStars){

    if(reviewStars < 1){
      return ReviewStars.star0;
    } else if(reviewStars == 1){
      return ReviewStars.star1;
    } else if(reviewStars > 1 && reviewStars <= 1.5){
      return ReviewStars.star15;
    } else if(reviewStars > 1.5 && reviewStars <= 2){
      return ReviewStars.star2;
    } else if(reviewStars > 2 && reviewStars <= 2.5){
      return ReviewStars.star25;
    } else if(reviewStars > 2.5 && reviewStars <= 3){
      return ReviewStars.star3;
    } else if(reviewStars > 3 && reviewStars <= 3.5){
      return ReviewStars.star35;
    } else if(reviewStars > 3.5 && reviewStars <= 4){
      return ReviewStars.star4;
    } else if(reviewStars > 4 && reviewStars <= 4.5){
      return ReviewStars.star45;
    } else if(reviewStars > 4.5 && reviewStars <=5){
      return ReviewStars.star5;
    }
  }

  static final star5 = Wrap(
    children: const [
      Icon(Icons.star, color: Color.fromRGBO(241, 191, 66, 1), size: 18,),
      Icon(Icons.star, color: Color.fromRGBO(241, 191, 66, 1), size: 18,),
      Icon(Icons.star, color: Color.fromRGBO(241, 191, 66, 1), size: 18,),
      Icon(Icons.star, color: Color.fromRGBO(241, 191, 66, 1), size: 18,),
      Icon(Icons.star, color: Color.fromRGBO(241, 191, 66, 1), size: 18,),
    ],
  );

  static final star45 = Wrap(
    children: const [
      Icon(Icons.star, color: Color.fromRGBO(241, 191, 66, 1), size: 18,),
      Icon(Icons.star, color: Color.fromRGBO(241, 191, 66, 1), size: 18,),
      Icon(Icons.star, color: Color.fromRGBO(241, 191, 66, 1), size: 18,),
      Icon(Icons.star, color: Color.fromRGBO(241, 191, 66, 1), size: 18,),
      Icon(Icons.star_half, color: Color.fromRGBO(241, 191, 66, 1), size: 18,),
    ],
  );

  static final star4 = Wrap(
    children: const [
      Icon(Icons.star, color: Color.fromRGBO(241, 191, 66, 1), size: 18,),
      Icon(Icons.star, color: Color.fromRGBO(241, 191, 66, 1), size: 18,),
      Icon(Icons.star, color: Color.fromRGBO(241, 191, 66, 1), size: 18,),
      Icon(Icons.star, color: Color.fromRGBO(241, 191, 66, 1), size: 18,),
      Icon(Icons.star, color: Color(0xffC0C0C0), size: 18,),
    ],
  );

  static final star35 = Wrap(
    children: const [
      Icon(Icons.star, color: Color.fromRGBO(241, 191, 66, 1), size: 18,),
      Icon(Icons.star, color: Color.fromRGBO(241, 191, 66, 1), size: 18,),
      Icon(Icons.star, color: Color.fromRGBO(241, 191, 66, 1), size: 18,),
      Icon(Icons.star_half, color: Color.fromRGBO(241, 191, 66, 1), size: 18,),
      Icon(Icons.star, color: Color(0xffC0C0C0), size: 18,),
    ],
  );

  static final star3 = Wrap(
    children: const [
      Icon(Icons.star, color: Color.fromRGBO(241, 191, 66, 1), size: 18,),
      Icon(Icons.star, color: Color.fromRGBO(241, 191, 66, 1), size: 18,),
      Icon(Icons.star, color: Color.fromRGBO(241, 191, 66, 1), size: 18,),
      Icon(Icons.star, color: Color(0xffC0C0C0), size: 18,),
      Icon(Icons.star, color: Color(0xffC0C0C0), size: 18,),
    ],
  );

  static final star25 = Wrap(
    children: const [
      Icon(Icons.star, color: Color.fromRGBO(241, 191, 66, 1), size: 18,),
      Icon(Icons.star, color: Color.fromRGBO(241, 191, 66, 1), size: 18,),
      Icon(Icons.star_half, color: Color.fromRGBO(241, 191, 66, 1), size: 18,),
      Icon(Icons.star, color: Color(0xffC0C0C0), size: 18,),
      Icon(Icons.star, color: Color(0xffC0C0C0), size: 18,),
    ],
  );

  static final star2 = Wrap(
    children: const [
      Icon(Icons.star, color: Color.fromRGBO(241, 191, 66, 1), size: 18,),
      Icon(Icons.star, color: Color.fromRGBO(241, 191, 66, 1), size: 18,),
      Icon(Icons.star, color: Color(0xffC0C0C0), size: 18,),
      Icon(Icons.star, color: Color(0xffC0C0C0), size: 18,),
      Icon(Icons.star, color: Color(0xffC0C0C0), size: 18,),
    ],
  );

  static final star15 = Wrap(
    children: const [
      Icon(Icons.star, color: Color.fromRGBO(241, 191, 66, 1), size: 18,),
      Icon(Icons.star_half, color: Color.fromRGBO(241, 191, 66, 1), size: 18,),
      Icon(Icons.star, color: Color(0xffC0C0C0), size: 18,),
      Icon(Icons.star, color: Color(0xffC0C0C0), size: 18,),
      Icon(Icons.star, color: Color(0xffC0C0C0), size: 18,),
    ],
  );

  static final star1 = Wrap(
    children: const [
      Icon(Icons.star, color: Color.fromRGBO(241, 191, 66, 1), size: 18,),
      Icon(Icons.star, color: Color(0xffC0C0C0), size: 18,),
      Icon(Icons.star, color: Color(0xffC0C0C0), size: 18,),
      Icon(Icons.star, color: Color(0xffC0C0C0), size: 18,),
      Icon(Icons.star, color: Color(0xffC0C0C0), size: 18,),
    ],
  );

  static final star0 = Wrap(
    children: const [
      Icon(Icons.star, color: Color(0xffC0C0C0), size: 18,),
      Icon(Icons.star, color: Color(0xffC0C0C0), size: 18,),
      Icon(Icons.star, color: Color(0xffC0C0C0), size: 18,),
      Icon(Icons.star, color: Color(0xffC0C0C0), size: 18,),
      Icon(Icons.star, color: Color(0xffC0C0C0), size: 18,),
    ],
  );

}