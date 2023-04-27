import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttercare168/constant/server_api.dart';
import 'package:fluttercare168/notifier_model/service_model.dart';
import 'package:fluttercare168/widgets/custom_icon_text_button.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../../models/license.dart';
import '../../../notifier_model/user_model.dart';
import 'dart:convert';

class MyServiceSettingAbout extends StatefulWidget {
  const MyServiceSettingAbout({Key? key}) : super(key: key);
  @override
  _MyServiceSettingAboutState createState() => _MyServiceSettingAboutState();
}

class _MyServiceSettingAboutState extends State<MyServiceSettingAbout> {

  TextEditingController aboutMeController = TextEditingController();

  double maxWidth = 800;
  double maxHeight= 600;
  XFile? backGroundImage;
  List<License> licenseList= [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    licenseList = License.getAboutMeLicenses();
    _getLicenseList();

    var userModel = context.read<UserModel>();
    if(userModel.user!.aboutMe!=null){
      aboutMeController.text = userModel.user!.aboutMe!;
    }
  }

  @override
  Widget build(BuildContext context) {
    var userModel = context.read<UserModel>();
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _getLicenseRows()+[
            const SizedBox(height: 10,),
            const Text('關於我', style: TextStyle(fontWeight: FontWeight.bold),),
            const Text('確保會員權益請勿填寫個人聯絡方式', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),),
            const SizedBox(height: 10,),
            TextField(
              onChanged: (text){
                var serviceModel = context.read<ServiceModel>();
                serviceModel.aboutMe = aboutMeController.text;
              },
              maxLines: 6,
              controller: aboutMeController,
              decoration: const InputDecoration(
                filled: true,
                // fillColor: Color(0xffE5E5E5),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide.none
                )
              ),
            ),
            const SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('背景照片\n(建議為橫式長方形圖片)', style: TextStyle(fontWeight: FontWeight.bold),),
                CustomIconTextButton(
                    iconData: Icons.image_outlined,
                    text: '選擇照片',
                    onPressed: ()async{
                      final ImagePicker _picker = ImagePicker();
                      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery, maxWidth: maxWidth, maxHeight: maxHeight);

                      if(pickedFile == null) return;

                      backGroundImage = pickedFile;

                      var userModel = context.read<UserModel>();
                      _putUpdateBackgroundImage(pickedFile, userModel.token!);
                      setState(() {});
                    })
              ],
            ),
            const Text('確保會員權益請勿上傳個人聯絡方式之圖片', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),),
            backGroundImage == null? const SizedBox() : Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              height: maxHeight,
              width: maxWidth,
              child: Image.file(File(backGroundImage!.path), fit: BoxFit.cover),
            ),
            const SizedBox(height: 40,),
          ],
        ),
      ),
    );
  }


  List<Widget> _getLicenseRows(){
    List<Widget> licenseWidgets = [const Text('相關文件', style: TextStyle(fontWeight: FontWeight.bold),)];
    for(var license in licenseList){
      licenseWidgets.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(license.name!),
                (license.image == null)?
                Text('(未上傳 或 審核未過 請重傳)'):
                (license.isPassed == false)?
                Text('(已上傳, 審核中~)'):
                Text('(審核通過)'),
              ],
            ))
            ,
            CustomIconTextButton(
                iconData: Icons.add_circle_outline,
                text: '選擇照片',
                onPressed: ()async{
                  final ImagePicker _picker = ImagePicker();
                  final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery, maxWidth: maxWidth, maxHeight: maxHeight);
                  if(pickedFile == null) return;
                  _uploadLicenceImages(license.id!, pickedFile);
                }),
          ],
        ),
      );
      licenseWidgets.add(SizedBox(height: 30));
    }
    return licenseWidgets;
  }

  Future _uploadLicenceImages(int licenseId, XFile image)async{
    print("here to upload image");
    var userModel =context.read<UserModel>();

    String path = ServerApi.PATH_USER_USER_LICENSE_IMAGES;

    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Token ${userModel.token}',
    };


    var request = http.MultipartRequest('PUT', ServerApi.standard(path: path));
    request.headers.addAll(headers);
    // print(licenseList);
    final file = await http.MultipartFile.fromPath('image', image.path);
    request.files.add(file);
    request.fields['licence_id'] = licenseId.toString();
    var response = await request.send();
    print(response.statusCode);
    response.stream.transform(utf8.decoder).listen((value) {
      List<dynamic> listJson = json.decode(value);

      if(listJson.isNotEmpty){
        List<License> data = List<License>.from(listJson.map((i) => License.fromJson(i)));
        for(var license in data){
          if( licenseList.where((element) => element.id == license.license).isNotEmpty ){
            licenseList.where((element) => element.id == license.license).first.image = license.image;
            licenseList.where((element) => element.id == license.license).first.isPassed = license.isPassed;
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("上傳成功！請等待審核。"),));
        setState(() {});
      }else{
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("無法更新資料，請檢查網路！"),));
      }
    });

  }

  // Future _uploadLicenseImages(String token)async{
  //   //一次上傳多張
  //   print("here to upload image");
  //   String path = ServerApi.PATH_USER_USER_LICENSE_IMAGES;
  //   Map<String, String> headers = {
  //     'Content-Type': 'application/json; charset=UTF-8',
  //     'Authorization': 'Token $token',
  //   };
  //   for(LicenseTemp image in licenseList){
  //     var request = http.MultipartRequest('PUT', ServerApi.standard(path: path));
  //     request.headers.addAll(headers);
  //     final file = await http.MultipartFile.fromPath('image', image.image.path);
  //     request.files.add(file);
  //     request.fields['licence_id'] = image.licenseId.toString();
  //     var response = await request.send();
  //     print(response.statusCode);
  //   }
  //   licenseList.clear();
  //   setState(() {});
  // }

  Future _getLicenseList()async{
    var userModel = context.read<UserModel>();
    String path = ServerApi.PATH_USER_USER_LICENSE_IMAGES;
    try {
      final response = await http.get(ServerApi.standard(path: path),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'Authorization': 'token ${userModel.token!}'},
      );
      if (response.statusCode == 200) {
        List<dynamic> parsedListJson = json.decode(utf8.decode(response.body.runes.toList()));
        List<License> data = List<License>.from(parsedListJson.map((i) => License.fromJson(i)));
        for(var license in data){
          if( licenseList.where((element) => element.id == license.license).isNotEmpty ){
            licenseList.where((element) => element.id == license.license).first.image = license.image;
            licenseList.where((element) => element.id == license.license).first.isPassed = license.isPassed;
          }
        }
        setState(() {});
      }
    } catch (e) {
      print(e);
    }
  }

  Future _putUpdateBackgroundImage(XFile image, String token)async{
    String path = ServerApi.PATH_UPDATE_USER_BACKGROUND_IMAGE;
    var request = http.MultipartRequest('PUT', ServerApi.standard(path: path));
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Token $token',
    };

    request.headers.addAll(headers);
    print(request.headers);
    final file = await http.MultipartFile.fromPath('background_image', image.path);
    request.files.add(file);

    var response = await request.send();

    print('image upload status code ${response.statusCode}');
    if(response.statusCode == 200){
      // String responseString = await response.stream.bytesToString();
      // Map<String, dynamic> map = json.decode(utf8.decode(responseString.runes.toList()));
      // String imageUrl = map['image'];
      //
      // var userModel = context.read<UserModel>();
      // userModel.updateUserAvatar(ServerApi.host+imageUrl);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("圖片上傳成功!"),));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("上傳失敗，請再次上傳"),));
    }
    setState(() {});
  }
  
}
