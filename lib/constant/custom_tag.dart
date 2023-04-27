import 'package:flutter/material.dart';
import 'color.dart';

class CustomTag{

  static theTag(String text, Color theColor, bool isBold){
    return Container(
        width: ( text.length != 4 ) ? 80 : null,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 6,vertical: 3),
        decoration: BoxDecoration(
          border: Border.all(
            color: theColor,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(4),),
        child: isBold
            ? Text(text, style: TextStyle(color: theColor, fontWeight: FontWeight.w900))
            : Text(text, style: TextStyle(color: theColor),
        ));
  }

  static final homeCare = theTag('居家照顧', AppColor.purple, false);
  static final hospitalCare = theTag('醫院看護', AppColor.purple, false);
  static final continuousTime = theTag('連續時間', AppColor.purple, false);
  static final weeklyTime = theTag('指定時段', AppColor.purple, false);

  static final topArticle = theTag('置頂', AppColor.purple, false);

  //案件狀態
  static final statusUnTaken = theTag('未承接', Colors.blueAccent,true);
  static final statusUnComplete = theTag('未完成', AppColor.red,true);
  static final statusComplete = theTag('已完成', AppColor.green,true);
  static final statusCanceled = theTag('已取消', AppColor.grey,true);
  static final statusEndEarly = theTag('提前結束', AppColor.orange,true);

  static final caseOpen = theTag('尚未找到服務者', AppColor.green, false);
  static final caseClosed = theTag('案件已關閉', AppColor.darkGrey, false);
  static final caseTaken = theTag('此案已承接', AppColor.green, false);
  static final notAgreedTakingCaseYet = theTag('服務者尚未同意接案', AppColor.green, false);

  //用在服務項目列表
  static final iconYes = Container(
      width: 20,
      height: 20,
      child: const Icon(Icons.done, size: 14, color: Colors.white,),
      decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColor.green));
  static final iconNo = Container(
      width: 20,
      height: 20,
      child: const Icon(Icons.clear_outlined, size: 14, color: Colors.white,),
      decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.red));


  //填寫訂單步驟
  static final bookingStep1 = Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
      stepElementOn('1', '填寫資料'),
      stepElementOff('2', '照護地點'),
      stepElementOff('3', ' 聯絡人 '),
      stepElementOff('4', '送出訂單'),
    ],
  );
  static final bookingStep2 = Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
      stepElementOn('1', '填寫資料'),
      stepElementOn('2', '照護地點'),
      stepElementOff('3', ' 聯絡人 '),
      stepElementOff('4', '送出訂單'),
    ],
  );
  static final bookingStep3 = Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
      stepElementOn('1', '填寫資料'),
      stepElementOn('2', '照護地點'),
      stepElementOn('3', ' 聯絡人 '),
      stepElementOff('4', '送出訂單'),
    ],
  );
  static final bookingStep4 = Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
      stepElementOn('1', '填寫資料'),
      stepElementOn('2', '照護地點'),
      stepElementOn('3', ' 聯絡人 '),
      stepElementOn('4', '送出訂單'),
    ],
  );

  //填寫需求單步驟
  static final requirementStep1 = Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
      stepElementOn('1', '需求資料'),
      stepElementOff('2', '被照顧者'),
      stepElementOff('3', ' 聯絡人 '),
      stepElementOff('4', '確認送出'),
    ],
  );
  static final requirementStep2 = Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
      stepElementOn('1', '需求資料'),
      stepElementOn('2', '被照顧者'),
      stepElementOff('3', ' 聯絡人 '),
      stepElementOff('4', '確認送出'),
    ],
  );
  static final requirementStep3 = Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
      stepElementOn('1', '需求資料'),
      stepElementOn('2', '被照顧者'),
      stepElementOn('3', ' 聯絡人 '),
      stepElementOff('4', '確認送出'),
    ],
  );
  static final requirementStep4 = Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
      stepElementOn('1', '需求資料'),
      stepElementOn('2', '被照顧者'),
      stepElementOn('3', ' 聯絡人 '),
      stepElementOn('4', '確認送出'),
    ],
  );

  static stepElementOn(String stepNum, String stepTitle){
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6,horizontal: 5),
      decoration: BoxDecoration(
        color: AppColor.purple,
        borderRadius: BorderRadius.circular(4),),
      child: Column(
        children: [
          Container(
              alignment: Alignment.center,
              width: 20,
              height: 20,
              child: Text(stepNum,style: const TextStyle(color: AppColor.purple)),
              decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white)),
          const SizedBox(height: 4,),
          Text(stepTitle,style: const TextStyle(color: Colors.white),)
        ],
      ),
    );
  }

  static stepElementOff(String stepNum, String stepTitle){
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6,horizontal: 5),
      decoration: BoxDecoration(
        color: Colors.grey[350],
        borderRadius: BorderRadius.circular(4),),
      child: Column(
        children: [
          Container(
              alignment: Alignment.center,
              width: 20,
              height: 20,
              child: Text(stepNum,style: TextStyle(color: Colors.grey[350],)),
              decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white)),
          const SizedBox(height: 4,),
          Text(stepTitle,style: const TextStyle(color: Colors.white),)
        ],
      ),
    );
  }

}

