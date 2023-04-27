import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttercare168/constant/color.dart';
import 'package:fluttercare168/notifier_model/user_model.dart';
import 'package:fluttercare168/pages/search_carer/booking_step4_confirm.dart';
import 'package:fluttercare168/widgets/custom_elevated_button.dart';
import 'package:fluttercare168/constant/custom_tag.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../../notifier_model/booking_model.dart';

class BookingStep3Contact extends StatefulWidget {
  const BookingStep3Contact({Key? key}) : super(key: key);

  @override
  _BookingStep3ContactState createState() => _BookingStep3ContactState();
}

class _BookingStep3ContactState extends State<BookingStep3Contact> {

  TextEditingController contactNameController = TextEditingController();
  TextEditingController relationController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var bookingModel = context.read<BookingModel>();
    bookingModel.emergencyContactName == null ? contactNameController.text ='' : contactNameController.text = bookingModel.emergencyContactName! ;
    bookingModel.emergencyContactRelation == null ? relationController.text ='' : relationController.text = bookingModel.emergencyContactRelation! ;
    bookingModel.emergencyContactPhone == null ? phoneController.text ='' : phoneController.text = bookingModel.emergencyContactPhone! ;
  }
  @override
  Widget build(BuildContext context) {
    var userModel = context.read<UserModel>();
    var bookingModel = context.read<BookingModel>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('填寫訂單'),
        actions: [
          TextButton(
              child: const Text('取消預定',style: TextStyle(color: Colors.white),) ,
              onPressed: (){
                Navigator.of(context).popUntil((route) => route.isFirst);
                bookingModel.clearBookingModelData();
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
                  CustomTag.bookingStep3,
                  const Center(child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text('【 步驟 3 填寫聯絡人資訊】', style: TextStyle(color: AppColor.purple, fontWeight: FontWeight.bold),),
                  )),
                  kSectionTitle('預定者：'),
                  Text('姓名：${userModel.user!.name!}'),
                  const SizedBox(height: 10,),
                  Text('聯絡電話：${userModel.user!.phone}'),
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
                              bookingModel.emergencyContactName = value;
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
                              bookingModel.emergencyContactRelation = value;
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
                          controller: phoneController,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                          onChanged: (value){
                            setState(() {
                              bookingModel.emergencyContactPhone = value;
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
                        if(bookingModel.emergencyContactName == null || bookingModel.emergencyContactRelation == null || bookingModel.emergencyContactPhone == null){
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("請確定每個欄位都已填寫!"),)
                          );
                        } else {
                          Navigator.push(context, MaterialPageRoute(builder: (context)=> BookingStep4Confirm()));
                        }
                      }))
            ],
          ),
        ),
      )
    );
  }
  kSectionTitle(String title){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold),),
    );
  }
}


