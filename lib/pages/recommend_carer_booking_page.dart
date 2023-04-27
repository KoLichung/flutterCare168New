import 'package:flutter/material.dart';
import 'package:fluttercare168/constant/enum.dart';
import 'package:fluttercare168/pages/search_carer/booking_step1_detail.dart';

import '../constant/color.dart';
import '../constant/server_api.dart';
import '../models/carer.dart';
import '../models/city.dart';
import '../models/servant_location.dart';
import '../models/user.dart';
import '../widgets/custom_elevated_button.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RecommendCarerBookingPage extends StatefulWidget {
  Carer carer;

  RecommendCarerBookingPage({Key? key, required this.carer}) : super(key: key);

  @override
  _RecommendCarerBookingPageState createState() => _RecommendCarerBookingPageState();
}

class _RecommendCarerBookingPageState extends State<RecommendCarerBookingPage> {

  CareType _theCareType = CareType.homeCare;
  List<String> cityNames = City.getCityNames();
  String? selectedCityName;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectedCityName = cityNames.first;

    if(widget.carer.isHome==true){
      _theCareType = CareType.homeCare;
    }else{
      _theCareType = CareType.hospitalCare;
    }

    _getUserLocations(widget.carer.id!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar:  AppBar(
          elevation: 2,
          shadowColor: Colors.black26,
          title: const Text('案件資料'),),
        body: Container(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('類別選擇', style: TextStyle(fontSize: 16)),
              Row(
                children: [
                  Radio<CareType>(
                    value: CareType.homeCare,
                    groupValue: _theCareType,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onChanged: (CareType? value) {
                      if(widget.carer.isHome==true){
                        setState(() {
                          _theCareType = value!;
                        });
                      }else{
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("此照護員不提供居家照護！"),));
                      }
                    },
                  ),
                  (widget.carer.isHome==true)?
                  const Text('居家照護'):const Text('居家照護', style: TextStyle(color: AppColor.darkGrey)),
                  Radio<CareType>(
                    value: CareType.hospitalCare,
                    groupValue: _theCareType,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onChanged: (CareType? value) {
                      if(widget.carer.isHospital==true){
                        setState(() {
                          _theCareType = value!;
                        });
                      }else{
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("此照護員不提供醫院看護！"),));
                      }
                    },
                  ),
                  (widget.carer.isHospital==true)?
                  const Text('醫院看護'):const Text('醫院看護', style: TextStyle(color: AppColor.darkGrey)),
                ],
              ),
              SizedBox(height: 15),
              Text('縣市選擇', style: TextStyle(fontSize: 16)),
              SizedBox(height: 5),
              Container(
                  height: 40,
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(4),),
                  child: getCity()
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CustomElevatedButton(
                      text: '下一頁繼續',
                      color: AppColor.purple,
                      onPressed: (){
                        print(selectedCityName);
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => BookingStep1Detail(careType: _theCareType, city: City.getCityFromName(selectedCityName!)),)
                        );
                      }
                  ),
                ],
              ),
            ],
          ),
        ),
      );
  }

  DropdownButtonHideUnderline getCity(){
    return DropdownButtonHideUnderline(
        child: DropdownButton<String>(
            itemHeight: 50,
            value: selectedCityName,
            onChanged:(String? newValue){
              setState(() {
                selectedCityName = newValue!;
              });
            },
            items: cityNames.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList())
    );
  }

  Future _getUserLocations(int userId) async{
    String path = ServerApi.PATH_CARER_LOCATIONS;
    try {
      final queryParams = {
        'user_id':userId.toString(),
      };

      final response = await http.get(ServerApi.standard(path: path, queryParameters: queryParams));

      if (response.statusCode == 200) {
        List<dynamic> parsedListJson = json.decode(utf8.decode(response.body.runes.toList()));
        List<ServantLocation> locations = List<ServantLocation>.from(parsedListJson.map((i) => ServantLocation.fromJson(i)));

        cityNames.clear();
        locations.asMap().forEach((index, location) {
          cityNames.add(City.getCityNameFromId(location.city!));
        });
        selectedCityName = cityNames.first;

        setState(() {});
      }
    } catch (e) {
      print(e);
    }
  }

}