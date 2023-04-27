import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:fluttercare168/constant/color.dart';
import 'package:fluttercare168/constant/server_api.dart';
import 'package:fluttercare168/widgets/custom_elevated_button.dart';
import 'package:fluttercare168/widgets/custom_small_purple_button.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

import '../../../notifier_model/user_model.dart';


class ShareMyService extends StatefulWidget {
  const ShareMyService({Key? key}) : super(key: key);

  @override
  _ShareMyServiceState createState() => _ShareMyServiceState();
}

class _ShareMyServiceState extends State<ShareMyService> {

  @override
  Widget build(BuildContext context) {
    var userModel = context.read<UserModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('推廣我的服務'),),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('我的頁面網址', style: TextStyle(fontWeight: FontWeight.bold),),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6,vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(4),),
                  child: Text(ServerApi.getCarerUrl(userModel.user!.id!).toString()),
                )),
                const SizedBox(width: 10,),
                CustomSmallPurpleButton(
                  text: '複製',
                  onPressed: (){
                    Clipboard.setData(ClipboardData(text:  ServerApi.getCarerUrl(userModel.user!.id!).toString() ));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("已複製到剪貼簿")));
                  }
                ),
                const SizedBox(width: 10,),
                CustomSmallPurpleButton(
                  text: '分享',
                  onPressed: (){
                    Share.share('這是我的照顧服務資訊頁面！\nCare168-第三方預約照護平台保障雙方權益好安心。\n${ServerApi.getCarerUrl(userModel.user!.id!).toString()}');
                  }
                ),
              ],
            ),


          ],
        ),
      ),
    );
  }
}
