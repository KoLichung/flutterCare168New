import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttercare168/models/service.dart';
import 'package:fluttercare168/constant/enum.dart';

import '../models/check_week_day.dart';
import '../models/city.dart';
import '../models/county.dart';


class RequireModel extends ChangeNotifier {

  //需求資料
  int? careTypeGroupValue = 0; //0:居家照顧 1:醫院看護
  City city = City.getCityFromId(2); //台北市
  County district = County.getCountyFromId(8) ;//中正區;
  TimeType timeType = TimeType.continuous;
  DateTime startDate = DateTime.now().add(const Duration(days: 2));
  DateTime endDate = DateTime.now().add(const Duration(days: 32));
  TimeOfDay startTime = const TimeOfDay(hour: 08, minute: 0);
  TimeOfDay endTime = const TimeOfDay(hour: 17, minute: 0);
  // String selectedWeekDay = '星期一、星期三、星期五';
  List<CheckWeekDay> checkWeekDays = CheckWeekDay.getAllDays();

  String? roadName;
  String? hospitalName;

  //被照顧者
  String? patientName;
  Gender patientGender = Gender.male;
  String? patientAge;
  String? patientWeight;
  List<CheckDiseaseChoice> checkDiseaseChoices = [];
  String? patientDiseaseNote;
  List<CheckBodyChoice> checkBodyChoices = [];
  String? patientBodyNote;
  List<CheckServiceChoice> checkBasicServiceChoices = [];
  List<CheckServiceChoice> checkExtraServiceChoices = [];

  //聯絡人
  String? emergencyContactName;
  String? emergencyContactRelation;
  String? emergencyContactPhone;

  //確認送出


  void clearRequireModelData(){
    careTypeGroupValue = 0; //0:居家照顧 1:醫院看護
    city = City.getCityFromId(2); //台北市
    district = County.getCountyFromId(8) ;//中正區;
    timeType = TimeType.continuous;
    startDate = DateTime.now().add(const Duration(days: 2));
    endDate = DateTime.now().add(const Duration(days: 32));
    startTime = const TimeOfDay(hour: 09, minute: 0);
    endTime = const TimeOfDay(hour: 09, minute: 0);
    checkWeekDays = CheckWeekDay.getAllDays();

    patientName = null;
    patientGender = Gender.male;
    patientAge = null;
    patientWeight = null;
    checkDiseaseChoices = [];
    patientDiseaseNote = null;
    checkBodyChoices = [];
    patientBodyNote = null;
    checkBasicServiceChoices = [];
    checkExtraServiceChoices = [];

    emergencyContactName = null;
    emergencyContactRelation = null;
    emergencyContactPhone = null;
  }

}

class CheckDiseaseChoice{
  int? diseaseId;
  bool? isChecked;
  String? diseaseName;

  CheckDiseaseChoice({
    required this.diseaseId,
    required this.isChecked,
    required this.diseaseName,
  });
}

class CheckBodyChoice{
  int? bodyConditionId;
  bool? isChecked;
  String? bodyCondition;

  CheckBodyChoice({
    required this.bodyConditionId,
    required this.isChecked,
    required this.bodyCondition,
  });
}

class CheckServiceChoice{
  int? serviceId;
  bool? isChecked;
  Service? service;

  CheckServiceChoice({
    required this.serviceId,
    required this.isChecked,
    required this.service,
  });
}