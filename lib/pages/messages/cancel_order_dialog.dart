import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../constant/color.dart';
import '../../models/order.dart';
import '../../notifier_model/user_model.dart';

class CancelOrderDialog extends StatefulWidget {

  final Order theOrder;
   const CancelOrderDialog({Key? key, required this.theOrder});

  @override
  _CancelOrderDialogState createState() => _CancelOrderDialogState();
}

class _CancelOrderDialogState extends State<CancelOrderDialog> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: const EdgeInsets.all(0),
      title: Container(
        width: 300,
        padding: const EdgeInsets.all(10),
        color: AppColor.purple,
        child: const Text(
          '取消訂單或提前結束',
          style: TextStyle(color: Colors.white),
        ),
      ),
      contentPadding: const EdgeInsets.all(0),
      content: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Text('提醒您：\n取消訂單或提前結束，\n可能會產生部份費用，\n詳情請參閱會員條款「退款規則」。\n\n如需提前結束服務，請與服務者交接完成，再按確認即可。\n\n如遇”服務前”48小時內被照顧者送急診、隔離、往生等特殊情況，請直接與平台客服聯絡，我們將協助您全額退款。\n\n※按確認後，不可回復~')
      ),
      backgroundColor: AppColor.purple,
      actions: <Widget>[
        OutlinedButton(
            style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white)),
            onPressed: () {
              setState(() {
                Navigator.pop(context, false);
              });
            },
            child: const Text('返回', style: TextStyle(color: Colors.white))
        ),
        OutlinedButton(
            style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white)),
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text('確認', style: TextStyle(color: Colors.white))
        ),
      ],
    );
  }
}