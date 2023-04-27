import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttercare168/constant/color.dart';
import 'package:fluttercare168/constant/enum.dart';
import 'package:fluttercare168/notifier_model/booking_model.dart';
import 'package:fluttercare168/notifier_model/user_model.dart';
import 'package:fluttercare168/widgets/custom_elevated_button.dart';
import 'package:fluttercare168/pages/search_carer/booking_step3_contact.dart';
import 'package:fluttercare168/constant/custom_tag.dart';
import 'package:fluttercare168/models/city.dart';
import 'package:fluttercare168/models/county.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../../constant/server_api.dart';
import '../../models/servant_location.dart';



class BookingStep2Location extends StatefulWidget {
  const BookingStep2Location({Key? key}) : super(key: key);

  @override
  _BookingStep2LocationState createState() => _BookingStep2LocationState();
}


class _BookingStep2LocationState extends State<BookingStep2Location> {

  List<String> cityList = City.getCityNames();
  List<String> districtList = [];

  // TextEditingController addressController = TextEditingController();
  // TextEditingController addressNoteController = TextEditingController();

  TextEditingController textController = TextEditingController();

  @override
  initState(){
    super.initState();
    var bookingModel = context.read<BookingModel>();


    districtList = County.getCountyNames(bookingModel.city!.id!);
    print(districtList);
    bookingModel.district = County.getCountyFromName(bookingModel.city!.id!, districtList.first);

    if(bookingModel.careType == CareType.homeCare && bookingModel.roadName!=null){
      textController.text = bookingModel.roadName!;
    }else if (bookingModel.careType == CareType.hospitalCare && bookingModel.hospitalName!=null){
      textController.text = bookingModel.hospitalName!;
    }
    _getUserLocationFee(bookingModel.carer!.id!);
  }

  @override
  Widget build(BuildContext context) {
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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTag.bookingStep2,
                const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text('【 步驟 2 填寫照護地點 】', style: TextStyle(color: AppColor.purple, fontWeight: FontWeight.bold),),)
                ),
                kSectionTitle('地址(必填)：'),
                Row(
                  children: [
                    Text(bookingModel.city!.name!),
                    SizedBox(width: 8),
                    // Text(bookingModel.district!.name!),
                    // Container(
                    //     height: 40,
                    //     margin: const EdgeInsets.only(right: 10),
                    //     padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 0),
                    //     decoration: BoxDecoration(
                    //       border: Border.all(width: 1,),
                    //       borderRadius: BorderRadius.circular(4),),
                    //     child: Text(bookingModel.city.name)
                    //     // child: getCity()
                    // ),
                    Container(
                        height: 40,
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(4),),
                        child: getDistrict()
                    ),
                  ],
                ),
                (bookingModel.careType == CareType.homeCare)?
                Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10.0,horizontal:0),
                      child: TextField(
                        controller: textController,
                        onChanged: (value){
                          // setState(() {
                            // bookingModel.patientAddress = value;
                          // });
                        },
                        decoration: const InputDecoration(
                          hintStyle: TextStyle(color: Colors.grey),
                          hintText: '路名：',
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
                    Container(
                      margin: EdgeInsets.fromLTRB(5, 0, 5, 5),
                      child: Text('※為確保您的隱私，此欄位只需填”路名”！請用聊聊告知接案服務者服務地址。', style: TextStyle(fontSize: 13)),
                    ),
                  ],
                )
                :
                Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10.0,horizontal:0),
                      child: TextField(
                        controller: textController,
                        onChanged: (value){
                          // setState(() {
                          //   bookingModel.patientAddress = value;
                          // });
                        },
                        decoration: const InputDecoration(
                          hintStyle: TextStyle(color: Colors.grey),
                          hintText: '醫院名或注意事項',
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
                    Container(
                      margin: EdgeInsets.fromLTRB(5, 0, 5, 5),
                      child: Text('※為確保您的隱私，請勿在此處填寫病房號！請用聊聊告知接案服務者病床號。', style: TextStyle(fontSize: 13)),
                    ),
                  ],
                ),
                // kSectionTitle('交通路線或注意事項(必填)：'),
                // TextField(
                //   maxLines: 4,
                //   controller: addressNoteController,
                //   onChanged: (value){
                //     setState(() {
                //       bookingModel.patientAddressNote = value;
                //     });
                //   },
                //   decoration: const InputDecoration(
                //     contentPadding: EdgeInsets.all(10),
                //     filled: true,
                //     fillColor: Color(0xffE5E5E5),
                //     border: OutlineInputBorder(
                //         borderRadius:BorderRadius.all(Radius.circular(4),),
                //         borderSide: BorderSide.none
                //     ),
                //     hintStyle: TextStyle(color: Colors.grey),
                //     // border: InputBorder.none,
                //   ),
                // ),
              ],
            ),
            Container(
              alignment: Alignment.bottomCenter,
              margin: const EdgeInsets.fromLTRB(0,20,0,40),
                child: CustomElevatedButton(
                    text: '下一頁繼續',
                    color: AppColor.purple,
                    onPressed: (){
                      if(textController.text!='' ){
                        final alphanumeric = RegExp(r'^.*[0-9].*');
                        if(alphanumeric.hasMatch(textController.text!)){
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("請勿直接填寫門牌號、病床號")));
                        }else{
                          if(bookingModel.careType == CareType.homeCare){
                            // 居家照顧
                            bookingModel.roadName = textController.text;
                          }else{
                            // 醫院看護
                            bookingModel.hospitalName = textController.text;
                          }
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => BookingStep3Contact(),)
                          );
                        }
                      }else{
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("請填寫路名或醫院名。")));
                      }

                      // if(bookingModel.patientAddress == null || bookingModel.patientAddressNote == null){
                      //   ScaffoldMessenger.of(context).showSnackBar(
                      //       const SnackBar(content: Text("請確定每個欄位都已填寫!"),)
                      //   );
                      // } else {
                      //   Navigator.push(
                      //       context,
                      //       MaterialPageRoute(builder: (context) => BookingStep3Contact(),)
                      //   );
                      // }
                    }
                ))
          ],
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

  // DropdownButtonHideUnderline getCity(){
  //   var bookingModel = context.read<BookingModel>();
  //   return DropdownButtonHideUnderline(
  //       child: DropdownButton<String>(
  //           itemHeight: 50,
  //           value: bookingModel.city!.name,
  //           onChanged:(String? newValue){
  //             setState(() {
  //               bookingModel.city = City.getCityFromName(newValue!);
  //               districtList = County.getCountyNames(bookingModel.city!.id!);
  //               bookingModel.district= County.getCountyFromName(bookingModel.city!.id!, districtList.first);
  //               _getUserLocationFee(bookingModel.carer!.id!);
  //             });
  //           },
  //           items: cityList.map<DropdownMenuItem<String>>((String value) {
  //             return DropdownMenuItem<String>(
  //               value: value,
  //               child: Text(value),
  //             );
  //           }).toList())
  //   );
  // }
  //
  DropdownButtonHideUnderline getDistrict(){
    var bookingModel = context.read<BookingModel>();
    return DropdownButtonHideUnderline(
        child: DropdownButton<String>(
            itemHeight: 50,
            value: bookingModel.district!.name,
            onChanged:(String? newValue){
              setState(() {
                bookingModel.district = County.getCountyFromName(bookingModel.city!.id!, newValue!);
                _getUserLocationFee(bookingModel.carer!.id!);
              });
            },
            items: districtList.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList())
    );
  }

  Future _getUserLocationFee(int carerId)async{
    var userModel = context.read<UserModel>();
    String path = ServerApi.PATH_USER_SERVICE_LOCATIONS;
    try {
      final queryParams = {
        'user_id':carerId.toString(),
      };

      final response = await http.get(ServerApi.standard(path: path, queryParameters: queryParams),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'token ${userModel.token!}'},
      );
      if (response.statusCode == 200) {
        List<dynamic> parsedListJson = json.decode(utf8.decode(response.body.runes.toList()));
        List<ServantLocation> locations = List<ServantLocation>.from(parsedListJson.map((i) => ServantLocation.fromJson(i)));

        var bookingModel = context.read<BookingModel>();
        for(var location in locations){
          if(location.city == bookingModel.city!.id){
            bookingModel.transferFee = location.transferFee;
            print("transfer fee ${bookingModel.transferFee}");
          }
        }

        setState(() {});
      }
    } catch (e) {
      print(e);
    }
  }


}


