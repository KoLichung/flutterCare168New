import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttercare168/models/language.dart';
import 'package:fluttercare168/models/service.dart';
import 'package:fluttercare168/models/user.dart';
import 'package:fluttercare168/models/county.dart';
import 'package:fluttercare168/models/user_week_day_time.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/servant_location.dart';

//時間類型：continuous連續時間 or weekly指定時段
enum TimeType { continuous, weekly }
enum CareType { homeCare, hospitalCare }
enum Gender {male, female}

class ServiceModel extends ChangeNotifier {

  Gender? gender;
  List<CheckUserWeekDayTime> checkUserWeekDayTimes = [];
  List<Language> checkedUserLanguages = [];

  bool? isContinuousTime;
  bool? isHomeChecked;
  bool? isHospitalChecked;
  String? homeHourly;
  String? homeHalfDay;
  String? homeFullDay;
  String? hospitalHourly;
  String? hospitalHalfDay;
  String? hospitalFullDay;
  String? aboutMe;

  List<Service> checkedUserServices = [];
  // String emergencyRoom = '0';
  // String infectiousDisease= '0';
  // String over70KG= '0';
  // String over90KG= '0';

  List<TagServantLocation> servantLocations = [];


  void changeServiceGender(Gender newGender){
    gender = newGender;
  }

  void changeIsHomeChecked(bool newIsHomeChecked){
    isHomeChecked = newIsHomeChecked;
  }

  void changeIsHospitalChecked(bool newIsHospitalChecked){
    isHospitalChecked = newIsHospitalChecked;
  }

  void clearServiceData(){
    checkUserWeekDayTimes.clear();
    checkedUserLanguages.clear();
    checkedUserServices.clear();
    servantLocations.clear();
  }

}

class CheckUserWeekDayTime{
  bool? isChecked;
  UserWeekDayTime? userWeekDayTime;

  CheckUserWeekDayTime({
    required this.isChecked,
    required this.userWeekDayTime,
  });
}

class TagServantLocation{
  int? tag;
  ServantLocation? location;

  TagServantLocation({
    required this.tag,
    required this.location,
  });
}

// class CheckUserServices{
//   bool? isChecked;
//   Service? userServices;
//
//   CheckUserServices({
//     required this.isChecked,
//     required this.userServices,
//   });
// }