import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:fluttercare168/constant/color.dart';
import 'package:fluttercare168/constant/server_api.dart';
import 'package:fluttercare168/widgets/custom_elevated_button.dart';
import 'package:fluttercare168/widgets/custom_small_purple_button.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../notifier_model/user_model.dart';


class ApplyingPage extends StatelessWidget {

  const ApplyingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('申請成為服務者'),),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('您的資料審核中~\n請耐心等待，\n若有任何疑問，\n可以透過 LINE 聯繫管理員。',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            SizedBox(height: 15),
            CustomElevatedButton(text: 'LINE 官方客服', onPressed: ()async{
              Uri url = Uri.parse('https://page.line.me/876gfkog');
              var userModel = context.read<UserModel>();
              if (userModel.platformType != null && userModel.platformType == 'ios' ){
                if (!await launchUrl(url)) {
                  throw 'Could not launch $url';
                }
              }else{
                if (!await launchUrl(url,mode: LaunchMode.externalApplication)) {
                  throw 'Could not launch $url';
                }
              }
            }, color: Colors.green),
          ],
        ),
      ),
    );
  }
}
