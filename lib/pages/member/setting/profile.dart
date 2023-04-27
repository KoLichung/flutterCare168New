import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttercare168/constant/color.dart';
import 'package:fluttercare168/pages/member/setting/profile_edit.dart';
import 'package:fluttercare168/widgets/custom_elevated_button.dart';
import 'package:provider/provider.dart';
import 'package:fluttercare168/notifier_model/user_model.dart';

import 'edit_user_password.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  // String? userGender;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var userModel = context.read<UserModel>();
    print(userModel.user!.gender);

    // if(userModel.user!.gender! == '女'){
    //   userGender = '女';
    // } else {
    //   userGender = '男';
    // }
    return Scaffold(
      appBar: AppBar(
        title: const Text('基本資料'),
        actions: [
          TextButton(
            child: const Text('修改資料',style: TextStyle(color: Colors.white),),
            onPressed: (){
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileEdit(),
                  ));
            },)],),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Consumer<UserModel>(builder: (context, userModel, child) =>
                checkUserImage(userModel.user!.image),
            ),
            Consumer<UserModel>(builder: (context, userModel, child) =>
                Text(userModel.user!.name!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
            ),
            const Divider(thickness: 1,height: 40,color: Colors.black26,),
            Row(
              children: [
                const Text('性別：'),
                Consumer<UserModel>(builder: (context, userModel, child) =>
                    Text(userModel.user!.gender == null
                        ? '未提供'
                        : (userModel.user!.gender! == '女' ? '女' :'男')
                    )
                ),
              ],
            ),
            const Divider(thickness: 1,height: 40,color: Colors.black26,),
            Row(
              children: [
                const Text('手機號碼：'),
                Consumer<UserModel>(builder: (context, userModel, child) =>
                    RichText(
                      text: TextSpan(
                        text: userModel.user!.phone,
                        style: Theme.of(context).textTheme.bodyText2,
                        // children: const <TextSpan>[
                        //   TextSpan(text: ' (已透過簡訊驗證)', style: TextStyle(fontSize: 14)),
                        // ],
                      ),
                    )
                )
              ],
            ),
            const Divider(thickness: 1,height: 40,color: Colors.black26,),
            Row(
              children: [
                const Text('電子郵件：'),
                Consumer<UserModel>(builder: (context, userModel, child) =>
                    Text(userModel.user!.email == null ? '未提供' : userModel.user!.email!),
                ),
              ],
            ),
            SizedBox(height: 50),
            Consumer<UserModel>(builder: (context, userModel, child) =>
            (!userModel.isLineLogin)?
              CustomElevatedButton(
                text: '修改密碼',
                color: AppColor.purple,
                onPressed: (){
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const EditUserPassword()));
                },
              ):
              Container(),
            ),
            // const Divider(thickness: 1,height: 40,color: Colors.black26,),
            // Row(
            //   children: [
            //     const Text('綁定LINE帳號：'),
            //     userModel.isLineLogin ? ElevatedButton(
            //       style: ElevatedButton.styleFrom(primary: AppColor.grey, elevation: 0),
            //       child: const Text('已綁定LINE'),
            //       onPressed: null,) : ElevatedButton(
            //       style: ElevatedButton.styleFrom(primary: const Color(0xff00c300), elevation: 0),
            //       child: const Text('立刻綁定LINE'),
            //       onPressed: (){},)
            //   ],
            // ),
          ],
        ),
      ),
    );
  }

  checkUserImage(String? imgPath){
    if(imgPath == null || imgPath == ''){
      return Container(
        margin: const EdgeInsets.all(20),
        height: 120,
        width: 120,
        decoration: const BoxDecoration(shape: BoxShape.circle),
        child: const Icon(Icons.account_circle_rounded,size: 64,color: Colors.grey,),
      );
    } else {
      return Container(
        margin: const EdgeInsets.all(20),
        height: 120,
        width: 120,
        decoration: BoxDecoration(
          color: Colors.grey,
          shape: BoxShape.circle,
          image: DecorationImage(
              image: NetworkImage(imgPath),
              fit: BoxFit.cover
          ),
        ),
      );
    }
  }


}
