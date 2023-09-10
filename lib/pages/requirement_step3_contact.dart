import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttercare168/notifier_model/require_model.dart';
import 'package:fluttercare168/notifier_model/user_model.dart';
import 'package:fluttercare168/pages/requirement_step4_confirm.dart';
import 'package:fluttercare168/pages/search_carer/home_page.dart';
import 'package:fluttercare168/widgets/custom_elevated_button.dart';
import 'package:fluttercare168/constant/custom_tag.dart';
import 'package:provider/provider.dart';

import '../constant/color.dart';

class RequirementStep3Contact extends StatefulWidget {
  const RequirementStep3Contact({Key? key}) : super(key: key);

  @override
  _RequirementStep3ContactState createState() => _RequirementStep3ContactState();
}

class _RequirementStep3ContactState extends State<RequirementStep3Contact> {

  TextEditingController neederNameController = TextEditingController();

  TextEditingController contactNameController = TextEditingController();
  TextEditingController relationController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var requireModel = context.read<RequireModel>();
    var userModel = context.read<UserModel>();

    requireModel.neederName == null?
        userModel.user == null? neederNameController.text='' : neederNameController.text = userModel.user!.name!
        : neederNameController.text = requireModel.neederName!;

    requireModel.neederName ??= userModel.user!.name!;

    requireModel.emergencyContactName == null ? contactNameController.text ='' : contactNameController.text = requireModel.emergencyContactName! ;
    requireModel.emergencyContactRelation == null ? relationController.text ='' : relationController.text = requireModel.emergencyContactRelation! ;
    requireModel.emergencyContactPhone == null ? phoneController.text ='' : phoneController.text = requireModel.emergencyContactPhone! ;
  }
  @override
  Widget build(BuildContext context) {
    var userModel = context.read<UserModel>();
    var requireModel = context.read<RequireModel>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('填寫需求單'),
        actions: [
          TextButton(
              child: const Text('取消需求單',style: TextStyle(color: Colors.white),) ,
              onPressed: (){
                Navigator.of(context).popUntil((route) => route.isFirst);
                requireModel.clearRequireModelData();
              })
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTag.requirementStep3,
                  const SizedBox(height: 20,),
                  kSectionTitle('預定者：'),
                  Row(
                    children: [
                      const Text('姓名：'),
                      Container(
                        width: 120,
                        height: 40,
                        margin: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                        child: TextField(
                          controller: neederNameController,
                          onChanged: (value){
                            setState(() {
                              requireModel.neederName = value;
                            });
                          },
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
                    ],),
                  const Text('(為保障您的權益，請確認預定者的姓名是否正確！)'),
                  const SizedBox(height: 10,),
                  Text('聯絡電話：${userModel.user!.phone!}'),
                  const SizedBox(height: 20,),
                  kSectionTitle('被照顧者聯絡人(必填)：'),
                  Row(
                    children: [
                      const Text('姓名：'),
                      Container(
                        width: 120,
                        height: 40,
                        margin: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                        child: TextField(
                          controller: contactNameController,
                          onChanged: (value){
                            setState(() {
                              requireModel.emergencyContactName = value;
                            });
                          },
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
                    ],),
                  Row(
                    children: [
                      const Text('與被照顧者關係：'),
                      Container(
                        width: 120,
                        height: 40,
                        margin: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                        child: TextField(
                          controller: relationController,
                          onChanged: (value){
                            setState(() {
                              requireModel.emergencyContactRelation = value;
                            });
                          },
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
                    ],),
                  Row(
                    children: [
                      const Text('聯絡電話：'),
                      Container(
                        width: 120,
                        height: 40,
                        margin: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                        child: TextField(
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                          controller: phoneController,
                          onChanged: (value){
                            setState(() {
                              requireModel.emergencyContactPhone = value;
                            });
                          },
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
                    ],),
                ],
              ),
              Container(
                  alignment: Alignment.bottomCenter,
                  margin: const EdgeInsets.fromLTRB(0,20,0,40),
                  child: CustomElevatedButton(
                      text: '下一頁繼續',
                      color: AppColor.purple,
                      onPressed: (){
                        if(requireModel.emergencyContactName == null || requireModel.emergencyContactRelation == null || requireModel.emergencyContactPhone == null){
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("請確定每個欄位都已填寫!"),
                              )
                          );
                        } else {
                          Navigator.push(context, MaterialPageRoute(builder: (context)=> RequirementStep4Confirm()));
                        }
                      })),
            ],
          ),
        ),
      ),
    );
  }

  kSectionTitle(String title){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold),),
    );

  }

}


