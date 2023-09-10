import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttercare168/constant/enum.dart';
import 'package:fluttercare168/models/carer.dart';
import 'package:fluttercare168/models/service.dart';

import '../models/body_condition.dart';
import '../models/case.dart';
import '../models/check_week_day.dart';
import '../models/city.dart';
import '../models/county.dart';
import '../models/disease_condition.dart';

class BookingModel extends ChangeNotifier {

  Carer? carer;
  List<Service> carerServices = []; //booking step 1 顯示的服務內容

  CareType careType = CareType.homeCare;
  City? city;
  County? district;
  TimeType? timeType;
  DateTime? startDate;
  DateTime? endDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  List<CheckWeekDay> checkWeekDays = CheckWeekDay.getAllDays();

  //填寫訂單 step 1 填寫資料
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

  //填寫訂單 step 2 照護地點
  // String? patientAddress;
  // String? patientAddressNote;

  String? roadName;
  String? hospitalName;

  //填寫訂單 step 3 聯絡人
  String? emergencyContactName;
  String? emergencyContactRelation;
  String? emergencyContactPhone;

  int? transferFee;
  int? numOfTransfer;
  int? amountOfTransfer;

  int? wageHour;
  double? workHours;
  int? baseMoney;

  List<OrderIncreaseService> orderIncreaseServices = [];
  int? totalMoney;

  int caseId = 0; // if caseId != 0, 是 edit_order

  String? neederName;

  void clearBookingModelData(){
    carer = null;
    careType = CareType.homeCare;
    city = null;
    district = null;
    timeType = null;
    startDate = null;
    endDate = null;
    startTime = null;
    endTime = null;
    checkWeekDays =  CheckWeekDay.getAllDays();
    patientName= null;
    patientAge= null;
    patientWeight= null;
    checkDiseaseChoices = [];
    patientDiseaseNote= null;
    checkBodyChoices = [];
    patientBodyNote= null;
    checkBasicServiceChoices = [];
    checkExtraServiceChoices = [];
    // patientAddress= null;
    // patientAddressNote= null;
    emergencyContactName= null;
    emergencyContactRelation= null;
    emergencyContactPhone= null;
    roadName = null;
    hospitalName = null;
    transferFee = 0;
    numOfTransfer = 0;
    amountOfTransfer = 0;
    wageHour = 0;
    workHours = 0;
    baseMoney = 0;
    orderIncreaseServices = [];
    totalMoney = 0;
    caseId =0;
  }

  void changeBookingTimeType(TimeType newTimeType){
    timeType = newTimeType;
    notifyListeners();
  }

  void changeBookingStartDate(DateTime newStartDate){
    startDate = newStartDate;
    notifyListeners();
  }

  void changeBookingEndDate(DateTime newEndDate){
    endDate = newEndDate;
    notifyListeners();
  }

  void updateCheckWeekDays(List<CheckWeekDay> checkWeekDays){
    this.checkWeekDays = checkWeekDays;
    notifyListeners();
  }

  void changeBookingStartTime(TimeOfDay newStartTime){
    startTime = newStartTime;
    notifyListeners();
  }

  void changeBookingEndTime(TimeOfDay newEndTime){
    endTime = newEndTime;
    notifyListeners();
  }

  void setBookingModelByCase(Case theCase, Carer theCarer,
      List<DiseaseCondition> diseaseConditions, List<BodyCondition> bodyConditions, List<Service> services, List<Service> carerServices){
    caseId = theCase.id!;
    carer=theCarer;

    careType=(theCase.careType=='居家照顧')?CareType.homeCare:CareType.hospitalCare;
    city=City.getCityFromId(theCase.city!);
    district=County.getCountyFromId(theCase.county!);
    timeType=theCase.isContinuousTime!?TimeType.continuous:TimeType.weekly;
    startDate=DateTime.parse(theCase.startDatetime!);
    endDate=DateTime.parse(theCase.endDatetime!);
    startTime=TimeOfDay(minute:((theCase.startTime!- theCase.startTime!.ceil())*60).toInt(), hour: theCase.startTime!.ceil());
    endTime=TimeOfDay(minute:((theCase.endTime!- theCase.endTime!.ceil())*60).toInt(), hour: theCase.endTime!.ceil());

    print('case weekday ${theCase.weekday}');
    if(theCase.weekday!= null && theCase.weekday!='') {
      checkWeekDays = getWeekDaysByString(theCase.weekday!);
    }
    print(checkWeekDays);

    //填寫訂單 step 1 填寫資料
    patientName=theCase.name!;
    patientGender=(theCase.gender=='M')?Gender.male:Gender.female;
    patientAge=theCase.age!.toString();
    patientWeight=theCase.weight!.toString();
    // checkDiseaseChoices = [];
    patientDiseaseNote=theCase.diseaseRemark;
    // checkBodyChoices = [];
    patientBodyNote=theCase.conditionsRemark;
    // checkBasicServiceChoices = [];
    // checkExtraServiceChoices = [];

    //填寫訂單 step 2 照護地點
    // String? patientAddress;
    // String? patientAddressNote;

    roadName=theCase.roadName;
    hospitalName=theCase.hospitalName;

    //填寫訂單 step 3 聯絡人
    emergencyContactName=theCase.emergencycontactName;
    emergencyContactRelation=theCase.emergencycontactRelation;
    emergencyContactPhone=theCase.emergencycontactPhone;

    List<String> diseaseNameStrings = DiseaseCondition.getDiseaseNames();
    for(var i = 1; i <= diseaseNameStrings.length-1; i++){
      if(diseaseConditions.where((element) => element.name == diseaseNameStrings[i]).isNotEmpty){
        checkDiseaseChoices.add(
            CheckDiseaseChoice(diseaseId: DiseaseCondition.getIdFromDiseaseName(diseaseNameStrings[i]), isChecked: true, diseaseName: diseaseNameStrings[i])
        );
      }else {
        checkDiseaseChoices.add(
            CheckDiseaseChoice(diseaseId: DiseaseCondition.getIdFromDiseaseName(diseaseNameStrings[i]), isChecked: false, diseaseName: diseaseNameStrings[i])
        );
      }
    }

    List<String> bodyIssueNameStrings = BodyCondition.getBodyConditionNames();
    for(var i = 1; i <= bodyIssueNameStrings.length-1; i++){
      if(bodyConditions.where((element) => element.name==bodyIssueNameStrings[i]).isNotEmpty){
        checkBodyChoices.add(
            CheckBodyChoice(bodyConditionId: BodyCondition.getIdFromName(bodyIssueNameStrings[i]), isChecked: true, bodyCondition: bodyIssueNameStrings[i])
        );
      }else{
        checkBodyChoices.add(
            CheckBodyChoice(bodyConditionId: BodyCondition.getIdFromName(bodyIssueNameStrings[i]), isChecked: false, bodyCondition: bodyIssueNameStrings[i])
        );
      }
    }

    for(var service in Service.getAllServices()){
      if(service.id! >= 1 && service.id! <= 4 ){

        service.increasePercent = carerServices.firstWhere((element) => element.id==service.id).increasePercent;

        if(services.where((element) => element.id == service.id).isNotEmpty){
          checkExtraServiceChoices.add(
              CheckServiceChoice(serviceId: service.id, isChecked: true, service: service)
          );
        }else {
          service.increasePercent=20;
          checkExtraServiceChoices.add(
              CheckServiceChoice(serviceId: service.id, isChecked: false, service: service)
          );
        }
      } else {
        if(services.where((element) => element.id == service.id).isNotEmpty){
          checkBasicServiceChoices.add(
              CheckServiceChoice(serviceId: service.id, isChecked: true, service: service)
          );
        }else {
          checkBasicServiceChoices.add(
              CheckServiceChoice(serviceId: service.id, isChecked: false, service: service)
          );
        }
      }
    }
  }

  List<CheckWeekDay> getWeekDaysByString(String weekDayString){
    List<CheckWeekDay> checkDays = CheckWeekDay.getAllDays();
    for(var day in checkDays){
      if(weekDayString.contains(day.weekDay.toString())){
        day.isChecked = true;
      }else{
        day.isChecked = false;
      }
    }
    return checkDays;
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

class OrderIncreaseService{
  Service? service;
  int? increaseMoney;

  OrderIncreaseService({
    required this.service,
    required this.increaseMoney,
  });
}