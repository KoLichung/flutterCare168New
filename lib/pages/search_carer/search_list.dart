import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttercare168/models/carer.dart';
import 'package:fluttercare168/models/user.dart';
import 'package:fluttercare168/pages/search_carer/search_carer_detail.dart';
import 'package:fluttercare168/constant/review_stars.dart';
import 'package:fluttercare168/constant/custom_tag.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:fluttercare168/notifier_model/user_model.dart';
import 'package:fluttercare168/constant/server_api.dart';
import 'package:fluttercare168/models/city.dart';
import 'package:fluttercare168/models/county.dart';
import 'package:intl/intl.dart';
import 'package:fluttercare168/constant/format_converter.dart';
import 'package:fluttercare168/constant/enum.dart';

import '../../constant/color.dart';

class SearchList extends StatefulWidget {

  const SearchList({Key? key}) : super(key: key);

  @override
  _SearchListState createState() => _SearchListState();
}

class _SearchListState extends State<SearchList> {

  List<Carer> searchedCarers = [];
  String? careTypeString;
  List<int> weekDayInts = [];
  int? startTime;
  int? endTime;

  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var userModel = context.read<UserModel>();
    careTypeString = userModel.careType == CareType.homeCare ? '居家照顧' : '醫院看護';
    for(var day in userModel.checkWeekDays){
      if (day.day == '星期一' && day.isChecked == true){
        weekDayInts.add(1);
      }
      if (day.day == '星期二' && day.isChecked == true){
        weekDayInts.add(2);
      }
      if (day.day == '星期三' && day.isChecked == true){
        weekDayInts.add(3);
      }
      if (day.day == '星期四' && day.isChecked == true){
        weekDayInts.add(4);
      }
      if (day.day == '星期五' && day.isChecked == true){
        weekDayInts.add(5);
      }
      if (day.day == '星期六' && day.isChecked == true){
        weekDayInts.add(6);
      }
      if (day.day == '星期日' && day.isChecked == true){
        weekDayInts.add(7);
      }
    }
    startTime = int.parse(userModel.startTime.to24hours().substring(0,2));
    endTime = int.parse(userModel.endTime.to24hours().substring(0,2));

    isLoading = true;
    _getServantList();
  }

  @override
  Widget build(BuildContext context) {
    var userModel = context.read<UserModel>();
    return Scaffold(
      appBar: AppBar(
        title: Text('${userModel.city.name!} ${DateFormat.Md().format(userModel.startDate)} ~ ${DateFormat.Md().format(userModel.endDate)} $careTypeString',),),
      body: (isLoading)?
      const Center(child: CircularProgressIndicator())
          :
      (searchedCarers.isNotEmpty)?
      ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: searchedCarers.length,
          itemBuilder: (BuildContext context, int i) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 310,
                      // color: Colors.lightBlue,
                      child: Column(
                        // mainAxisAlignment: MainAxisAlignment.center,
                        // crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 12,),
                          getCarerProfile(i),
                          const SizedBox(height: 6,),
                          checkCareType(i),
                          // const Text('服務地區：'),
                          // Text(checkCarerLocation(searchedCarers[i].locations!)),

                        ],
                      ),
                    ),
                  ),
                  const Divider(color: Color(0xffC0C0C0),),
                ],
              ),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SearchCarerDetail(theCarer: searchedCarers[i], id: searchedCarers[i].id!, isFromRecommend: false),
                      ));
                }
            );
          }
      )
          :
      const Center(
        child: Text('此搜索條件無資料！'),
      )
      ,
      floatingActionButton: FloatingActionButton(
        elevation: 0,
        backgroundColor: AppColor.purple,
        child: const Icon(Icons.menu_outlined),
        onPressed: (){
          getPopUpMenu();
        },
      ),
    );
  }

  String getMrOrMSString(String userName, String gender){
      if(gender == 'M'){
        return userName.substring(0,1) + '先生';
      }else{
        return userName.substring(0,1) + '小姐';
      }
  }

  checkUserImage(String? imgPath) {
    if (imgPath == null || imgPath == '') {
      return Container(
        height: 62,
        width: 62,
        decoration: const BoxDecoration(shape: BoxShape.circle),
        child: const Icon(Icons.account_circle_rounded, size: 62, color: Colors.grey,),
      );
    } else {
      return Container(
        height: 62,
        width: 62,
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

  getCarerProfile(int i){
    return Column(
      // mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        checkUserImage(searchedCarers[i].image),
        Row(
          children: [
            const SizedBox(height: 6,),
            Text(getMrOrMSString(searchedCarers[i].name!, searchedCarers[i].gender!),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
            const SizedBox(width: 5,),
            searchedCarers[i].servantAvgRating! == 0.0 ? const Text('') : Text(searchedCarers[i].servantAvgRating!.toString()),
            const SizedBox(width: 5,),
            ReviewStars.getReviewStars(searchedCarers[i].servantAvgRating!),
            Text(' (${searchedCarers[i].ratingNums!})'),
          ],
        ),
      ]
    );

  }

  checkCareType(int i) {
    if (searchedCarers[i].isHome == true && searchedCarers[i].isHospital == true) {
      return Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 6,),
            SizedBox(
              width: 80,
              child: CustomTag.homeCare,
            ),
            const SizedBox(height: 2,),
            Text('時薪\$${_getWageWords(searchedCarers[i].homeHourWage!)}｜半天\$${_getWageWords(searchedCarers[i].homeHalfDayWage!)}｜全天\$${_getWageWords(searchedCarers[i].homeOneDayWage!)}'),
            const SizedBox(height: 6,),
            SizedBox(
              width: 80,
              child: CustomTag.hospitalCare,
            ),
            const SizedBox(height: 2,),
            Text('時薪\$${_getWageWords(searchedCarers[i].hospitalHourWage!)}｜半天\$${_getWageWords(searchedCarers[i].hospitalHalfDayWage!)}｜全天\$${_getWageWords(searchedCarers[i].hospitalOneDayWage!)}'),
            const Text('服務地區：'),
            Text(checkCarerLocation(searchedCarers[i].locations!)),
          ],
        ),
      );
    } else if (searchedCarers[i].isHome == true && searchedCarers[i].isHospital == false) {
      return Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6,),
            SizedBox(
              width: 80,
              child: CustomTag.homeCare,
            ),
            const SizedBox(height: 2,),
            Text('時薪\$${_getWageWords(searchedCarers[i].homeHourWage!)}｜半天 \$${_getWageWords(searchedCarers[i].homeHalfDayWage!)}｜全天\$${_getWageWords(searchedCarers[i].homeOneDayWage!)}'),
            const Text('服務地區：'),
            Text(checkCarerLocation(searchedCarers[i].locations!)),
          ],
        ),
      );
    } else if (searchedCarers[i].isHospital == true && searchedCarers[i].isHome == false) {
      return Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6,),
            SizedBox(
              width: 80,
              child: CustomTag.hospitalCare,
            ),
            const SizedBox(height: 2,),
            Text('時薪\$${_getWageWords(searchedCarers[i].hospitalHourWage!)}｜半天\$${_getWageWords(searchedCarers[i].hospitalHalfDayWage!)}｜全天\$${_getWageWords(searchedCarers[i].hospitalOneDayWage!)}'),
            const Text('服務地區：'),
            Text(checkCarerLocation(searchedCarers[i].locations!)),
          ],
        ),
      );
    }
  }

  String _getWageWords(int wage){
    if(wage != 0){
      return wage.toString();
    }else{
      return '無服務';
    }
  }

  checkCarerLocation(List<Locations> locations) {
    List<String> locationStrings = [];
    for (var location in locations) {
      // print(location.city);
      // print(location.transferFee);
      locationStrings.add('${City.getCityNameFromId(location.city!)}  交通費\$${location.transferFee!.toString()}\n');
    }
    return locationStrings.join('');
  }

  getPopUpMenu(){
    return showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(100, 600, 20, 100),
      items: const [
        PopupMenuItem(
            value: 1,
            child: Text("高分排序")),
        PopupMenuItem(
            value: 2,
            child: Text("評價數排序")),
        PopupMenuItem(
            value: 3,
            child: Text("低價到高價")),
        PopupMenuItem(
            value: 4,
            child: Text("高價到低價")),
      ],
      elevation: 4.0,
    ).then((value){
      // NOTE: even you didnt select item this method will be called with null of value so you should call your call back with checking if value is not null
      if(value!=null){
        if(value==1){
          searchedCarers.sort((a, b) => - (a.servantAvgRating!).compareTo(b.servantAvgRating!));
        }else if(value==2){
          searchedCarers.sort((a, b) => - (a.ratingNums!).compareTo(b.ratingNums!));
        }else if(value==3){
          var userModel = context.read<UserModel>();
          if (userModel.careType == CareType.homeCare){
            searchedCarers.sort((a, b) => (b.homeHourWage!).compareTo(a.homeHourWage!));
          }else{
            searchedCarers.sort((a, b) => (b.hospitalHourWage!).compareTo(a.hospitalHourWage!));
          }
        }else if(value==4){
          var userModel = context.read<UserModel>();
          if (userModel.careType == CareType.homeCare){
            searchedCarers.sort((a, b) => (a.homeHourWage!).compareTo(b.homeHourWage!));
          } else {
            searchedCarers.sort((a, b) => (a.hospitalHourWage!).compareTo(b.hospitalHourWage!));
          }
        }
        setState(() {});
      }
    });
  }

  Future _getServantList() async {
    var userModel = context.read<UserModel>();
    String path = ServerApi.PATH_SEARCH_SERVANTS;
    try {
      final response = await http.get(
          ServerApi.standard(path: path, queryParameters: {
            'care_type': userModel.careType == CareType.homeCare ? 'home' : 'hospital',
            'city': userModel.city.id!.toString(),
            // 'county': userModel.district.id!.toString(),
            'is_continuous_time': userModel.timeType == TimeType.continuous ? 'true' : 'false',
            'weekdays': weekDayInts.toString(),
            'start_end_time':'$startTime:$endTime',
            'start_datetime': userModel.startDate.toString().substring(0, 10),
            'end_datetime': userModel.endDate.toString().substring(0, 10),
            'is_random': 'true',
          }
          ));
        if (response.statusCode == 200) {
          // print(response.body);
          List<dynamic> parsedListJson = json.decode(utf8.decode(response.body.runes.toList()));
          List<Carer> data = List<Carer>.from(parsedListJson.map((i) => Carer.fromJson(i)));
          searchedCarers = data;
          setState(() {
            isLoading = false;
          });
        }
      } catch (e) {
        print(e);
      }
    }
  }
