import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:fluttercare168/constant/server_api.dart';
import 'package:fluttercare168/pages/member/apply_servant/apply_documents_two.dart';
import 'package:fluttercare168/widgets/custom_button.dart';
import 'package:fluttercare168/widgets/custom_icon_text_button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../../../constant/color.dart';
import '../../../models/city.dart';
import '../../../models/license.dart';
import '../../../models/servant_location.dart';
import '../../../notifier_model/service_model.dart';
import '../../../notifier_model/user_model.dart';
import 'package:fluttercare168/models/service.dart';

class ApplyDocumentsOne extends StatefulWidget {
  const ApplyDocumentsOne({Key? key}) : super(key: key);

  @override
  _ApplyDocumentsOneState createState() => _ApplyDocumentsOneState();
}

class _ApplyDocumentsOneState extends State<ApplyDocumentsOne> {

  TextEditingController homeHourly = TextEditingController();
  TextEditingController homeHalfDay = TextEditingController();
  TextEditingController homeFullDay = TextEditingController();
  TextEditingController hospitalHourly = TextEditingController();
  TextEditingController hospitalHalfDay = TextEditingController();
  TextEditingController hospitalFullDay = TextEditingController();

  TextEditingController transportation= TextEditingController();

  List<Service> allServices = []; //UI顯示的所有 service

  TextEditingController emergencyRoom = TextEditingController();
  TextEditingController infectiousDisease = TextEditingController();
  TextEditingController over75KG = TextEditingController();
  TextEditingController over90KG = TextEditingController();
  TextEditingController aboutMeController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var userModel = context.read<UserModel>();
    var serviceModel = context.read<ServiceModel>();

    allServices = Service.getAllServices();

    serviceModel.isHomeChecked = userModel.user!.isHome;
    serviceModel.homeHourly = userModel.user!.homeHourWage.toString();
    serviceModel.homeHalfDay = userModel.user!.homeHalfDayWage.toString();
    serviceModel.homeFullDay = userModel.user!.homeOneDayWage.toString();

    serviceModel.isHospitalChecked = userModel.user!.isHospital;
    serviceModel.hospitalHourly = userModel.user!.hospitalHourWage.toString();
    serviceModel.hospitalHalfDay = userModel.user!.hospitalHalfDayWage.toString();
    serviceModel.hospitalFullDay = userModel.user!.hospitalOneDayWage.toString();

    serviceModel.checkedUserServices = Service.getIncreasePriceServices();
    getUserServiceList();

    // if(serviceModel.checkedUserServices.isEmpty){
    //   // isLoading = true;
    //   serviceModel.checkedUserServices = Service.getIncreasePriceServices();
    //   getUserServiceList();
    // }

    if(serviceModel.servantLocations.isEmpty){
      getUserLocations();
    }

    if(serviceModel.homeHourly == null ){
      homeHourly.text = userModel.user!.homeHourWage.toString();
    } else {
      homeHourly.text = serviceModel.homeHourly!;
    }
    if(serviceModel.homeHalfDay == null ){
      homeHalfDay.text = userModel.user!.homeHalfDayWage.toString();
    } else {
      homeHalfDay.text = serviceModel.homeHalfDay!;
    }
    if(serviceModel.homeFullDay == null ){
      homeFullDay.text = userModel.user!.homeOneDayWage.toString();
    } else {
      homeFullDay.text = serviceModel.homeFullDay!;
    }
    if(serviceModel.hospitalHourly == null ){
      hospitalHourly.text = userModel.user!.hospitalHourWage.toString();
    } else {
      hospitalHourly.text = serviceModel.hospitalHourly!;
    }
    if(serviceModel.hospitalHalfDay == null ){
      hospitalHalfDay.text = userModel.user!.hospitalHalfDayWage.toString();
    } else {
      hospitalHalfDay.text = serviceModel.hospitalHalfDay!;
    }
    if(serviceModel.hospitalFullDay == null ){
      hospitalFullDay.text = userModel.user!.hospitalOneDayWage.toString();
    } else {
      hospitalFullDay.text = serviceModel.hospitalFullDay!;
    }

    if(serviceModel.aboutMe!=null){
      aboutMeController.text = serviceModel.aboutMe!;
    }else{
      if(userModel.user!.aboutMe!=null) {
        serviceModel.aboutMe = userModel.user!.aboutMe;
        aboutMeController.text = serviceModel.aboutMe!;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var userModel = context.read<UserModel>();
    var serviceModel = context.read<ServiceModel>();

    return Scaffold(
        appBar: AppBar(
            title: const Text('申請成為服務者(1/2)')
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('服務類型', style: TextStyle(fontWeight: FontWeight.bold),),
                Row(
                  children: [
                    Checkbox(
                      checkColor:Colors.white,
                      activeColor: AppColor.purple,
                      value: serviceModel.isHomeChecked == null ? userModel.user!.isHome : serviceModel.isHomeChecked,
                      onChanged: (bool? value){
                        setState(() {
                          serviceModel.isHomeChecked = value!;
                        });
                      },
                    ),
                    const Text('居家照顧'),
                    Checkbox(
                      checkColor:Colors.white,
                      activeColor: AppColor.purple,
                      value: serviceModel.isHospitalChecked == null ? userModel.user!.isHospital : serviceModel.isHospitalChecked,
                      onChanged: (bool? value){
                        setState(() {
                          serviceModel.isHospitalChecked = value!;
                        });
                      },
                    ),
                    const Text('醫院看護')
                  ],
                ),
                const Text('居家照顧 服務費用', style: TextStyle(fontWeight: FontWeight.bold),),
                const SizedBox(height: 10,),
                serviceRate('時薪',homeHourly,(text){serviceModel.homeHourly = text;}, '未滿12小時\n以每小時時薪計價'),
                serviceRate('半天',homeHalfDay,(text){serviceModel.homeHalfDay=text;}, '12~24小時\n以半天價格之時薪計價'),
                serviceRate('全天',homeFullDay,(text){serviceModel.homeFullDay=text;}, '24小時以上\n以全天價格計價'),
                const SizedBox(height: 10,),
                const Text('醫院看護 服務費用', style: TextStyle(fontWeight: FontWeight.bold),),
                serviceRate('時薪',hospitalHourly,(text){serviceModel.hospitalHourly=text;}, '未滿12小時\n以每小時時薪計價'),
                serviceRate('半天',hospitalHalfDay,(text){serviceModel.hospitalHalfDay=text;}, '12~24小時\n以半天價格之時薪計價'),
                serviceRate('全天',hospitalFullDay,(text){serviceModel.hospitalFullDay=text;}, '24小時以上\n以全天價格計價'),
                const SizedBox(height: 10,),
                const Text('服務地區與交通費', style: TextStyle(fontWeight: FontWeight.bold),),
                const SizedBox(height: 10,),
                // Column(children: serviceLocationRowList),
                getServiceLocationRows(),
                CustomIconTextButton(
                    iconData: Icons.add,
                    text: '增加地區',
                    onPressed: (){
                      _addNewServiceLocationRow();
                    }),
                const SizedBox(height: 10,),
                const Text('服務項目', style: TextStyle(fontWeight: FontWeight.bold),),
                const SizedBox(height: 10,),
                basicServiceCheckBox(),
                const SizedBox(height: 10,),
                const Text('特殊加價狀況，自設時薪 % 數', style: TextStyle(fontWeight: FontWeight.bold),),
                const SizedBox(height: 10,),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text('急診室：'),
                    Container(
                      width: 60,
                      height: 40,
                      margin: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                      child: TextField(
                        controller: emergencyRoom,
                        keyboardType: TextInputType.number,
                        onChanged: (value){
                          setState(() {
                            serviceModel.checkedUserServices.where((element) => element.service==1).first.increasePercent = double.parse(value);
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
                    const Text('%'),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text('傳染性疾病：'),
                    Container(
                      width: 60,
                      height: 40,
                      margin: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                      child: TextField(
                        controller: infectiousDisease,
                        keyboardType: TextInputType.number,
                        onChanged: (value){
                          setState(() {
                            serviceModel.checkedUserServices.where((element) => element.service==2).first.increasePercent = double.parse(value);
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
                    const Text('%'),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text('體重超過75公斤：'),
                    Container(
                      width: 60,
                      height: 40,
                      margin: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                      child: TextField(
                        controller: over75KG,
                        keyboardType: TextInputType.number,
                        onChanged: (value){
                          setState(() {
                            serviceModel.checkedUserServices.where((element) => element.service==3).first.increasePercent = double.parse(value);
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
                    const Text('%'),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text('體重超過90公斤：'),
                    Container(
                      width: 60,
                      height: 40,
                      margin: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                      child: TextField(
                        controller: over90KG,
                        keyboardType: TextInputType.number,
                        onChanged: (value){
                          setState(() {
                            serviceModel.checkedUserServices.where((element) => element.service==4).first.increasePercent = double.parse(value);
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
                    const Text('%'),
                  ],
                ),
                // increasePriceServiceCheckBox(),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 0),
                  child: Text('例：服務費用一天\$2600加價5%，等於每日增加\$130'),
                ),
                const SizedBox(height: 20,),
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
                const SizedBox(height: 20,),
                CustomButton(text: "下一頁", color: AppColor.purple, onPressed: (){
                  if(aboutMeController.text==''){
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("請填寫關於我！"),));
                  }else if(emergencyRoom.text==''||infectiousDisease.text==''||over75KG.text==''||over90KG.text==''){
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("請填寫每一個加價項目！"),));
                  }else{
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ApplyDocumentsTwo(),
                        ));
                  }
                }),
                const SizedBox(height: 150,),
              ],
            ),
          ),
        )
    );
  }

  Widget serviceRate(String rateType, TextEditingController controller, Function onChange, String note){
    return Row(
      children: [
        Text(rateType),
        Container(
          width: 70,
          height: 40,
          margin: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
          child: TextField(
            controller: controller,
            onChanged: (String? value){
              if(value!=null&&value!='') {
                onChange(value);
              }
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
        const Text('元'),
        const SizedBox(width: 10,),
        Text(note, style: const TextStyle(color: Colors.grey,fontSize: 14),),
      ],);
  }

  getServiceLocationRows(){
    var serviceModel = context.read<ServiceModel>();
    return Container(
      height: 60.0 * serviceModel.servantLocations.length,
      child: ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: serviceModel.servantLocations.length,
          itemBuilder: (BuildContext context, int index){
            String cityName = City.getCityNameFromId(serviceModel.servantLocations[index].location!.city!);
            // String countyName = County.getCountyNameFromId(serviceModel.servantLocations[index].location!.county!);
            int transferFee = serviceModel.servantLocations[index].location!.transferFee!;
            int tag = serviceModel.servantLocations[index].tag!;
            return getServiceLocationRow(cityName, transferFee, tag);
          }
      ),
    );
  }

  Row getServiceLocationRow(String cityName, int fransferFee, int tag){
    TextEditingController transferFeeText = TextEditingController();
    transferFeeText.text = fransferFee.toString();

    return Row(
      children: [
        Container(
          height: 40,
          margin: const EdgeInsets.only(right: 6),
          padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 0),
          decoration: BoxDecoration(
            border: Border.all(width: 1,),
            borderRadius: BorderRadius.circular(4),),
          child: getCity(cityName, tag),
        ),
        // Container(
        //   height: 40,
        //   margin: const EdgeInsets.only(right: 6),
        //   padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 0),
        //   decoration: BoxDecoration(
        //     border: Border.all(width: 1,),
        //     borderRadius: BorderRadius.circular(4),),
        //   child: getDistrict(countyName, City.getIdFromCityName(cityName), tag),
        // ),
        const Text('\$'),
        Container(
          width: 60,
          height: 40,
          margin: const EdgeInsets.symmetric(horizontal: 6,vertical: 10),
          child: TextField(
            controller: transferFeeText,
            keyboardType: TextInputType.number,
            onChanged: (text){
              if(text!=''){
                var serviceModel = context.read<ServiceModel>();
                if(serviceModel.servantLocations.where((element) => element.tag == tag).isNotEmpty){
                  serviceModel.servantLocations.where((element) => element.tag == tag).first.location!.transferFee = int.parse(text);
                }
              }
            },
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
        IconButton(
          icon: const Icon(Icons.delete_forever,color: Colors.red,),
          onPressed: (){
            //onPressFunction
            deleteServiceLocationRow(tag);
          },
        ),
      ],
    );
  }

  DropdownButtonHideUnderline getCity(String cityName, int tag){
    return DropdownButtonHideUnderline(
        child: DropdownButton<String>(
            itemHeight: 50,
            value: cityName,
            onChanged:(String? newValue){
              var serviceModel = context.read<ServiceModel>();
              //set newValue to serviceModel
              print(newValue);

              TagServantLocation tagServantLocation = serviceModel.servantLocations.firstWhere((element) => element.tag == tag);
              int cityId = City.getIdFromCityName(newValue!);
              tagServantLocation.location!.city = cityId;
              // tagServantLocation.location!.county = County.getCityCounties(cityId).first.id!;
              setState(() {});
            },
            items: City.getCityNames().map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList())
    );
  }

  // DropdownButtonHideUnderline getDistrict(String districtName, int cityId, int tag){
  //   return DropdownButtonHideUnderline(
  //       child: DropdownButton<String>(
  //           itemHeight: 50,
  //           value: districtName,
  //           onChanged:(String? newValue){
  //             setState(() {
  //               var serviceModel = context.read<ServiceModel>();
  //               //set newValue to serviceModel
  //               print(newValue);
  //
  //               TagServantLocation tagServantLocation = serviceModel.servantLocations.firstWhere((element) => element.tag == tag);
  //               // tagServantLocation.location!.county = County.getCountyFromName(tagServantLocation.location!.city!, newValue!).id!;
  //               setState(() {});
  //             });
  //           },
  //           items: County.getCountyNames(cityId).map<DropdownMenuItem<String>>((String value) {
  //             return DropdownMenuItem<String>(
  //               value: value,
  //               child: Text(value),
  //             );
  //           }).toList())
  //   );
  // }

  void _addNewServiceLocationRow() {
    var serviceModel = context.read<ServiceModel>();
    int tag = 0;
    if(serviceModel.servantLocations.isNotEmpty){
      tag = serviceModel.servantLocations.last.tag!+1;
    }
    serviceModel.servantLocations.add(TagServantLocation(tag: tag, location: ServantLocation(transferFee: 0, city: 2)));
    setState(() {});
  }

  void deleteServiceLocationRow(int tag) {
    print(tag);
    var serviceModel = context.read<ServiceModel>();
    serviceModel.servantLocations.removeWhere((element) => element.tag! == tag);
    setState(() {});
  }

  basicServiceCheckBox(){
    List<Column> boxes = [];
    for( var i = 5; i<= 18; i++) {
      boxes.add(
          Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 40,
                    height: 26,
                    child: Checkbox(
                      checkColor: Colors.white,
                      activeColor: AppColor.purple,
                      value: checkIsServiceChecked(i),
                      onChanged: (bool? value) {
                        setState(() {
                          onChangedIsServiceChecked(i,checkIsServiceChecked(i));
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        text: allServices[i-1].name,
                        style: const TextStyle(fontSize: 16, color: Colors.black),
                        children: <TextSpan>[
                          (allServices[i-1].remark == null) ?
                          const TextSpan(text:'')
                              :
                          TextSpan(text: '\n'+_checkToChangeLine(allServices[i-1].remark!), style: const TextStyle(color: Colors.grey, fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4,)
            ],
          )
      );
    }
    return Column(
      children: boxes,
    );
  }

  String _checkToChangeLine(String text){
    return text.replaceAll('※', '\n※');
  }

  increasePriceServiceCheckBox(){
    List<Column> boxes = [];
    for( var i = 1; i<= 4; i++) {
      if (i == 1){
        boxes.add(Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 40,
                  height: 26,
                  child: Checkbox(
                    checkColor: Colors.white,
                    activeColor: AppColor.purple,
                    value: checkIsServiceChecked(i),
                    onChanged: (bool? value) {
                      setState(() {
                        onChangedIsServiceChecked(i,checkIsServiceChecked(i));
                      });
                    },
                  ),
                ),
                Text('${allServices[i-1].name!}：'),
                Container(
                  width: 60,
                  height: 40,
                  margin: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                  child: TextField(
                    controller: emergencyRoom,
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
                const Text('%'),
              ],
            ),
            const SizedBox(height: 4,)
          ],
        ));
      } else if (i == 2){
        boxes.add(Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 40,
                  height: 26,
                  child: Checkbox(
                    checkColor: Colors.white,
                    activeColor: AppColor.purple,
                    value: checkIsServiceChecked(i),
                    onChanged: (bool? value) {
                      setState(() {
                        onChangedIsServiceChecked(i,checkIsServiceChecked(i));
                      });
                    },
                  ),
                ),
                Text('${allServices[i-1].name!}：'),
                Container(
                  width: 60,
                  height: 40,
                  margin: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                  child: TextField(
                    controller: infectiousDisease,
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
                const Text('%'),
              ],
            ),
            const SizedBox(height: 4,)
          ],
        ));
      } else if (i == 3){
        boxes.add(Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 40,
                  height: 26,
                  child: Checkbox(
                    checkColor: Colors.white,
                    activeColor: AppColor.purple,
                    value: checkIsServiceChecked(i),
                    onChanged: (bool? value) {
                      setState(() {
                        onChangedIsServiceChecked(i,checkIsServiceChecked(i));
                      });
                    },
                  ),
                ),
                Text('${allServices[i-1].name!}：'),
                Container(
                  width: 60,
                  height: 40,
                  margin: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                  child: TextField(
                    controller: over75KG,
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
                const Text('%'),
              ],
            ),
            const SizedBox(height: 4,)
          ],
        ));
      } else if (i == 4){
        boxes.add(Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 40,
                  height: 26,
                  child: Checkbox(
                    checkColor: Colors.white,
                    activeColor: AppColor.purple,
                    value: checkIsServiceChecked(i),
                    onChanged: (bool? value) {
                      setState(() {
                        onChangedIsServiceChecked(i,checkIsServiceChecked(i));
                      });
                    },
                  ),
                ),
                Text('${allServices[i-1].name!}：'),
                Container(
                  width: 60,
                  height: 40,
                  margin: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                  child: TextField(
                    controller: over90KG,
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
                const Text('%'),
              ],
            ),
            const SizedBox(height: 4,)
          ],
        ));
      }
    }
    return Column(
      children: boxes,
    );
  }

  checkIsServiceChecked(int serviceChoice){
    var serviceModel = context.read<ServiceModel>();
    for(var choice in serviceModel.checkedUserServices){
      if(choice.service == serviceChoice){
        return true;
      }
    }
    return false;
  }

  onChangedIsServiceChecked(int serviceChoice, bool? value){
    var serviceModel = context.read<ServiceModel>();
    if (value! == true){
      serviceModel.checkedUserServices.removeWhere((element) => element.service! == serviceChoice);
      value = false;
    } else if (value == false){
      if(serviceChoice ==1){
        // serviceModel.checkedUserServices.add(Service(service: serviceChoice,increasePercent: double.parse(emergencyRoom.text)));
      } else if(serviceChoice == 2){
        // serviceModel.checkedUserServices.add(Service(service: serviceChoice,increasePercent: double.parse(infectiousDisease.text)));
      } else if(serviceChoice == 3){
        // serviceModel.checkedUserServices.add(Service(service: serviceChoice,increasePercent: double.parse(over75KG.text)));
      } else if(serviceChoice == 4){
        // serviceModel.checkedUserServices.add(Service(service: serviceChoice,increasePercent: double.parse(over90KG.text)));
      } else if (serviceChoice >=5 && serviceChoice <=18){
        serviceModel.checkedUserServices.add(Service(service: serviceChoice));
      }
      value = true;
    }
  }

  Future getUserServiceList()async{
    var userModel = context.read<UserModel>();
    String path = ServerApi.PATH_USER_SERVICES;
    // try {
    final response = await http.get(ServerApi.standard(path: path),
      headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'Authorization': 'token ${userModel.token!}'},
    );

    print(response.body);

    if (response.statusCode == 200) {
      List<dynamic> parsedListJson = json.decode(utf8.decode(response.body.runes.toList()));
      List<Service> services = List<Service>.from(parsedListJson.map((i) => Service.fromJson(i)));

      var serviceModel = context.read<ServiceModel>();

      for(var service in services){
        if(serviceModel.checkedUserServices.where((element) => element.service==service.service).isNotEmpty){
          serviceModel.checkedUserServices.where((element) => element.service==service.service).first.increasePercent = service.increasePercent;
          if(service.service==1){
            emergencyRoom.text = service.increasePercent!.toInt().toString();
          }
          if(service.service==2){
            infectiousDisease.text = service.increasePercent!.toInt().toString();
          }
          if(service.service==3){
            over75KG.text = service.increasePercent!.toInt().toString();
          }
          if(service.service==4){
            over90KG.text = service.increasePercent!.toInt().toString();
          }
        }else{
          serviceModel.checkedUserServices.add(service);
        }
      }

      setState(() {});
    }
    // } catch (e) {
    //   print(e);
    // }
  }

  Future getUserLocations()async{
    var userModel = context.read<UserModel>();
    String path = ServerApi.PATH_USER_SERVICE_LOCATIONS;
    try {
      final response = await http.get(ServerApi.standard(path: path),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', 'Authorization': 'token ${userModel.token!}'},
      );
      if (response.statusCode == 200) {
        List<dynamic> parsedListJson = json.decode(utf8.decode(response.body.runes.toList()));
        List<ServantLocation> locations = List<ServantLocation>.from(parsedListJson.map((i) => ServantLocation.fromJson(i)));

        var serviceModel = context.read<ServiceModel>();
        locations.asMap().forEach((index, location) {
          serviceModel.servantLocations.add(TagServantLocation(tag: index, location: location));
        });
        setState(() {});
      }
    } catch (e) {
      print(e);
    }
  }

}
