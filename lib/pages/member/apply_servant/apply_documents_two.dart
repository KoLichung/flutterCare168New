import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:fluttercare168/constant/server_api.dart';
import 'package:fluttercare168/widgets/custom_icon_text_button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../../../constant/color.dart';
import '../../../models/license.dart';
import '../../../models/user.dart';
import '../../../notifier_model/service_model.dart';
import '../../../notifier_model/user_model.dart';
import '../../../widgets/custom_button.dart';

class ApplyDocumentsTwo extends StatefulWidget {
  const ApplyDocumentsTwo({Key? key}) : super(key: key);

  @override
  _ApplyDocumentsTwoState createState() => _ApplyDocumentsTwoState();
}

class _ApplyDocumentsTwoState extends State<ApplyDocumentsTwo> {

  double maxWidth = 800;
  double maxHeight= 600;

  bool isLoading = false;
  List<License> applyLicenses = [];

  TextEditingController bankCodeController = TextEditingController();
  TextEditingController bankBranchCodeController = TextEditingController();
  TextEditingController bankAccountNumberController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    applyLicenses = License.getApplyLicenses();
    var userModel = context.read<UserModel>();
    if(userModel.user!.aTMInfoBankCode == null){
      bankCodeController.text = '';
    } else {
      bankCodeController.text = userModel.user!.aTMInfoBankCode!;
    }
    if(userModel.user!.aTMInfoBranchBankCode == null){
      bankBranchCodeController.text = '';
    } else {
      bankBranchCodeController.text = userModel.user!.aTMInfoBranchBankCode!;
    }
    if(userModel.user!.aTMInfoAccount == null){
      bankAccountNumberController.text = '';
    } else {
      bankAccountNumberController.text = userModel.user!.aTMInfoAccount!;
    }
    if(userModel.user!.email == null){
      emailController.text = '';
    } else {
      emailController.text = userModel.user!.email!;
    }
    _getLicenseList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('申請成為服務者(2/2)'),
        // actions: [
        //   TextButton(
        //       child: const Text('確認上傳',style: TextStyle(color: Colors.white),),
        //       onPressed: (){
        //         if(bankCodeController.text!=''&&bankBranchCodeController.text!=''&&bankAccountNumberController.text!=''&&emailController.text!=''){
        //           if(applyLicenses.where((element) => element.id == 1).first.image==null
        //             || applyLicenses.where((element) => element.id == 2).first.image==null
        //             || applyLicenses.where((element) => element.id == 3).first.image==null
        //           ){
        //             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("請上傳身分證/健保卡"),));
        //           }else if(applyLicenses.where((element) => element.id == 7).first.image==null
        //             && applyLicenses.where((element) => element.id == 8).first.image==null
        //             && applyLicenses.where((element) => element.id == 9).first.image==null
        //           ){
        //             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("證照至少要上傳一張"),));
        //           }else {
        //             _putUpdateBankAccountAndEmail(bankCodeController.text, bankBranchCodeController.text, bankAccountNumberController.text, emailController.text);
        //           }
        //         }else{
        //           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("請填寫 轉帳訊息 與 email。"),));
        //         }
        //       },
        //     )
        // ]
      ),
      body: isLoading
          ? Center(child:Column(
          children: const [
            SizedBox(height: 40),
            CircularProgressIndicator(),
            SizedBox(height: 10),
            Text("資料上傳中，請稍候..."),
          ],
        ))
          : SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _getLicenseRows() + [
                  const Text('金融機構代碼'),
                  const SizedBox(height: 6,),
                  TextField(
                    // controller: bankCodeController,
                    controller: bankCodeController,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly,],
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      filled: true,
                      fillColor: Color(0xffE5E5E5),
                    ),
                  ),
                  const SizedBox(height: 20,),
                  const Text('金融機構分行代碼'),
                  const SizedBox(height: 6,),
                  TextField(
                    controller: bankBranchCodeController,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly,],
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      filled: true,
                      fillColor: Color(0xffE5E5E5),
                    ),
                  ),
                  const SizedBox(height: 20,),
                  const Text('金融機構帳戶帳號'),
                  const SizedBox(height: 6,),
                  TextField(
                    controller: bankAccountNumberController,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly,],
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      filled: true,
                      fillColor: Color(0xffE5E5E5),
                    ),
                  ),
                  const SizedBox(height: 20,),
                  const Text('發票寄送Email'),
                  const SizedBox(height: 6,),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      filled: true,
                      fillColor: Color(0xffE5E5E5),
                    ),
                  ),
                  const SizedBox(height: 20,),
                  CustomButton(text: "確認上傳", color: AppColor.purple, onPressed: (){
                    if(bankCodeController.text!=''&&bankBranchCodeController.text!=''&&bankAccountNumberController.text!=''&&emailController.text!=''){
                      if(applyLicenses.where((element) => element.id == 1).first.image==null
                          || applyLicenses.where((element) => element.id == 2).first.image==null
                          || applyLicenses.where((element) => element.id == 3).first.image==null
                      ){
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("請上傳身分證/健保卡"),));
                      }else if(applyLicenses.where((element) => element.id == 7).first.image==null
                          && applyLicenses.where((element) => element.id == 8).first.image==null
                          && applyLicenses.where((element) => element.id == 9).first.image==null
                      ){
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("證照至少要上傳一張"),));
                      }else {
                        _putUpdateProfile(bankCodeController.text, bankBranchCodeController.text, bankAccountNumberController.text, emailController.text);

                        //update user locations
                        _putUdateUserLocations();

                        //update user services
                        _putUpdateUserServices();
                      }
                    }else{
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("請填寫 轉帳訊息 與 email。"),));
                    }
                  } ),
                  const SizedBox(height: 40,),
                ],
              ),
            ),
          )
    );
  }

  List<Widget> _getLicenseRows(){
    List<Widget> licenseWidgets = [];
    for(var license in applyLicenses){
      if(license.id==7){
        licenseWidgets.add(Text('p.s 以下三項證書須上傳至少其中一項即可！'));
        licenseWidgets.add(SizedBox(height: 20));
      }
      licenseWidgets.add(
        Row(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(license.name!+'\n'+getUploadState(license))),
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

  String getUploadState(License license){
    if (license.image == null){
      return '(未上傳 或 審核未過 請重傳)';
    }else if(license.isPassed == false){
      return '(已上傳, 審核中~)';
    }else{
      return '(審核通過)';
    }
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
          if( applyLicenses.where((element) => element.id == license.license).isNotEmpty ){
            applyLicenses.where((element) => element.id == license.license).first.image = license.image;
            applyLicenses.where((element) => element.id == license.license).first.isPassed = license.isPassed;
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("上傳成功！請等待審核。"),));
        setState(() {});
      }else{
        isLoading = false;
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("無法更新資料，請檢查網路！"),));
      }
    });

  }

  Future _getLicenseList() async{
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
            if( applyLicenses.where((element) => element.id == license.license).isNotEmpty ){
              applyLicenses.where((element) => element.id == license.license).first.image = license.image;
              applyLicenses.where((element) => element.id == license.license).first.isPassed = license.isPassed;
            }
        }
        // print(uploadedLicenseList[1].license);
        setState(() {});
      }
    } catch (e) {
      print(e);
    }
  }

  Future _putUpdateBankAccountAndEmail(String bankCode, String branchCode, String accountNum, String email)async{
    var userModel = context.read<UserModel>();
    String path = ServerApi.PATH_USER_DATA;
    try{
      final bodyParams ={
        'phone': userModel.user!.phone,
        'name': userModel.user!.name,
        'is_apply_servant': true,
        'ATMInfoBankCode':bankCode,
        'ATMInfoBranchBankCode':branchCode,
        'ATMInfoAccount': accountNum,
        'email': email,
      };

      final response = await http.put(ServerApi.standard(path:path),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'token ${userModel.token}'
        },
        body: jsonEncode(bodyParams),
      );
      print(response.body);
      if(response.statusCode == 200){
        var userModel = context.read<UserModel>();
        userModel.updateBankAccount(bankCodeController.text, bankBranchCodeController.text, bankAccountNumberController.text);
        userModel.user!.isApplyServant = true;

        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("成功更新！請等待審核~"),
            )
        );
        Navigator.pop(context);
      }

    } catch (e){
      print(e);
    }
  }

  Future _putUdateUserLocations()async{
    var userModel = context.read<UserModel>();
    String path = ServerApi.PATH_USER_SERVICE_LOCATIONS;

    var serviceModel = context.read<ServiceModel>();
    String locations = serviceModel.servantLocations.map((item) => item.location!.city ).toList().toString().replaceAll('[', '').replaceAll(']', '').replaceAll(' ', '');

    String transferFees = serviceModel.servantLocations.map((item) => item.location!.transferFee ).toList().toString().replaceAll('[', '').replaceAll(']', '').replaceAll(' ', '');

    print(locations);
    print(transferFees);

    try {
      Map<String,String> bodyParams = {
        'locations': locations,
        'transfer_fee':transferFees,
      };

      final response = await http.put(ServerApi.standard(path: path),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'token ${userModel.token!}'
        },
        body: jsonEncode(bodyParams),
      );
      print(response.body);

      if (response.statusCode == 200) {
        // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("成功更新！") ));
      }
    } catch (e) {
      print(e);
    }
  }

  Future _putUpdateUserServices()async{
    var userModel = context.read<UserModel>();
    String path = ServerApi.PATH_USER_SERVICES;

    var serviceModel = context.read<ServiceModel>();
    String services = serviceModel.checkedUserServices.map((item) => (item.increasePercent!=null&&item.increasePercent!=0)?"${item.service!}:${item.increasePercent!.toInt()}":item.service).toList().toString().replaceAll('[', '').replaceAll(']', '').replaceAll(' ', '');

    print(services);

    try {
      Map<String,String> bodyParams = {
        'services': services,
      };

      final response = await http.put(ServerApi.standard(path: path),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'token ${userModel.token!}'
        },
        body: jsonEncode(bodyParams),
      );
      print(response.body);

      if (response.statusCode == 200) {
        // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("成功更新！") ));
      }
    } catch (e) {
      print(e);
    }
  }

  Future _putUpdateProfile(String bankCode, String branchCode, String accountNum, String email)async{
    var userModel = context.read<UserModel>();
    var serviceModel = context.read<ServiceModel>();

    String path = ServerApi.PATH_USER_DATA;
    try{
      final bodyParams ={
        'name':userModel.user!.name,
        'phone': userModel.user!.phone,
        'is_home':serviceModel.isHomeChecked,
        'home_hour_wage':serviceModel.homeHourly,
        'home_half_day_wage':serviceModel.homeHalfDay,
        'home_one_day_wage':serviceModel.homeFullDay,
        'is_hospital':serviceModel.isHospitalChecked,
        'hospital_hour_wage':serviceModel.hospitalHourly,
        'hospital_half_day_wage':serviceModel.hospitalHalfDay,
        'hospital_one_day_wage':serviceModel.hospitalFullDay,
        'about_me':serviceModel.aboutMe,
        'is_apply_servant': true,
        'ATMInfoBankCode':bankCode,
        'ATMInfoBranchBankCode':branchCode,
        'ATMInfoAccount': accountNum,
        'email': email,
      };

      final response = await http.put(ServerApi.standard(path:path),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'token ${userModel.token}'
        },
        body: jsonEncode(bodyParams),
      );

      print(response.statusCode);
      print(response.body);

      if(response.statusCode == 200){
        Map<String, dynamic> map = json.decode(utf8.decode(response.body.runes.toList()));
        User theUser = User.fromJson(map);
        var userModel = context.read<UserModel>();
        userModel.setUser(theUser);
        userModel.updateBankAccount(bankCodeController.text, bankBranchCodeController.text, bankAccountNumberController.text);
        userModel.user!.isApplyServant = true;

        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("成功更新！請等待審核~"),
            )
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e){
      print(e);
    }

  }
}

// class LicenseTemp{
//   XFile image;
//   String licenseId;
//   LicenseTemp(this.image, this.licenseId);
// }
