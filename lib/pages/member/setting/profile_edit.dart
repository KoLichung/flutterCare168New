import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttercare168/widgets/custom_icon_text_button.dart';
import 'package:fluttercare168/widgets/custom_small_purple_button.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:fluttercare168/notifier_model/user_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../constant/server_api.dart';


class ProfileEdit extends StatefulWidget {
  const ProfileEdit({Key? key}) : super(key: key);

  @override
  _ProfileEditState createState() => _ProfileEditState();
}

class _ProfileEditState extends State<ProfileEdit> {

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  String _gender = 'M';

  XFile? avatarImage;
  double maxWidth = 360;
  double maxHeight= 360;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var userModel = context.read<UserModel>();
    nameController.text = userModel.user!.name!;
    phoneController.text = userModel.user!.phone!;
    (userModel.user!.email == null || userModel.user!.email! == '') ? emailController.text == '' : emailController.text = userModel.user!.email!;
    userModel.user!.gender == '女' ? _gender = 'F' : _gender = 'M';
  }

  @override
  Widget build(BuildContext context) {
    var userModel = context.read<UserModel>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('修改資料'),
        actions: [
          TextButton(
            child: const Text('儲存',style: TextStyle(color: Colors.white),),
            onPressed: (){
              var userModel = context.read<UserModel>();
              _putUpdateProfile(userModel.token!, nameController.text, _gender, phoneController.text, emailController.text );
              userModel.updateProfile(nameController.text, (_gender=='M')?'男':'女', phoneController.text, emailController.text);
              },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Consumer<UserModel>(builder: (context, userModel, child) =>
              avatarImage == null
                  ? checkUserImage(userModel.user!.image)
                  : Container(
                margin: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
                height: 120,
                width: 120,
                child: ClipOval(
                  child: Image.file(File(avatarImage!.path), fit: BoxFit.cover),
                ),
              ),),
              CustomIconTextButton(
                  iconData: Icons.add_circle_outline,
                  text: '上傳頭像',
                  onPressed: () async {
                    final ImagePicker _picker = ImagePicker();
                    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery, maxWidth: maxWidth, maxHeight: maxHeight);
                    if(pickedFile == null) return;
                    avatarImage = pickedFile;
                    _putUpdateAvatar(avatarImage!,userModel.token!);

                    //在這邊要更新(notify) 有在 listen userImage 的地方
                    //但是，image是用路徑來顯示圖片，所以代表要 get user again ？
                    // userModel.updateUserAvatar(user.timeType!);

                    setState(() {});
                  }),
              const SizedBox(height: 10,),
              const Text('建議為正方形圖片',style: TextStyle(fontWeight: FontWeight.bold),),
              const Text('注意！圖像選擇上傳後即會更新！',style: TextStyle(fontWeight: FontWeight.bold),),
              const Divider(thickness: 1,height: 40,color: Colors.black26,),
              Row(
                children: [
                  const Text('姓名：'),
                  const SizedBox(width: 10,),
                  Expanded(
                    child: TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 0.0,horizontal: 10),
                        border: OutlineInputBorder(
                            borderRadius:BorderRadius.all(Radius.circular(3),
                            ),
                            borderSide: BorderSide.none
                        ),
                        filled: true,
                        fillColor: Color(0xffE5E5E5),
                      ),
                    ),
                  ),
                ],
              ), //姓名
              const Divider(thickness: 1,height: 40,color: Colors.black26,),
              Row(
                children: [
                  const Text('性別：'),
                  const SizedBox(width: 10,),
                  Radio<String>(
                    activeColor: Colors.black54,
                    value: 'M',
                    groupValue: _gender,
                    onChanged: (String? value) {
                      setState(() {
                        _gender = value!;
                      });
                    },
                  ),
                  const Text('男'),
                  Radio<String>(
                    activeColor: Colors.black54,
                    value: 'F',
                    groupValue: _gender,
                    onChanged: (String? value) {
                      setState(() {
                        _gender = value!;
                      });
                    },
                  ),
                  const Text('女')
                ],
              ), //性別
              const Divider(thickness: 1,height: 40,color: Colors.black26,),
              Row(
                children: [
                  const Text('手機號碼：'),
                  const SizedBox(width: 10,),
                  Expanded(
                    child: TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 0.0,horizontal: 10),
                        border: OutlineInputBorder(
                            borderRadius:BorderRadius.all(Radius.circular(3),),
                            borderSide: BorderSide.none
                        ),
                        filled: true,
                        fillColor: Color(0xffE5E5E5),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10,),
                  // CustomSmallPurpleButton(text: '發送驗證簡訊', onPressed: (){})
                ],
              ), //手機號碼
              const Divider(thickness: 1,height: 40,color: Colors.black26,),
              Row(
                children: [
                  const Text('電子郵件：'),
                  const SizedBox(width: 10,),
                  Expanded(
                    child: TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 0.0,horizontal: 10),
                        border: OutlineInputBorder(
                            borderRadius:BorderRadius.all(Radius.circular(3),),
                            borderSide: BorderSide.none
                        ),
                        filled: true,
                        fillColor: Color(0xffE5E5E5),
                      ),
                    ),
                  ),
                ],
              ), //電子郵件
            ],
          ),
        ),
      ),
    );
  }

  checkUserImage(String? imgPath) {
    if (imgPath == null || imgPath == '') {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
        height: 120,
        width: 120,
        decoration: const BoxDecoration(shape: BoxShape.circle),
        child: const Icon(Icons.account_circle_rounded, size: 64, color: Colors.grey,),
      );
    } else {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
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

  Future _putUpdateAvatar(XFile image, String token)async{
    String path = ServerApi.PATH_UPDATE_USER_HEAD_IMAGE;
    var request = http.MultipartRequest('PUT', ServerApi.standard(path: path));
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Token $token',
    };

    request.headers.addAll(headers);
    print(request.headers);
    final file = await http.MultipartFile.fromPath('image', image.path);
    request.files.add(file);

    // request.fields['phone'] = userModel.user!.phone!;
    // request.fields['name'] = userModel.user!.name!;

    var response = await request.send();

    print('image upload status code ${response.statusCode}');
    if(response.statusCode == 200){
      String responseString = await response.stream.bytesToString();
      Map<String, dynamic> map = json.decode(utf8.decode(responseString.runes.toList()));
      String imageUrl = map['image'];

      var userModel = context.read<UserModel>();
      userModel.updateUserAvatar(ServerApi.host+imageUrl);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("圖片上傳成功!"),));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("上傳失敗，請再次上傳"),));
    }
    setState(() {});
  }

  Future _putUpdateProfile (String token, String? name, String? gender, String? phoneNumber, String? email)async{
    String path = ServerApi.PATH_USER_DATA;
    try{
      final bodyParams ={
        'name':name,
        'gender':gender,
        'phone': phoneNumber,
        'email': email,
      };

      final response = await http.put(ServerApi.standard(path:path),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'token $token'
        },
        body: jsonEncode(bodyParams),
      );
      print(response.body);
      if(response.statusCode == 200){
        print('success update profile');
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("成功更新！"),
            )
        );
      }

    } catch (e){
      print(e);
    }

  }

}
