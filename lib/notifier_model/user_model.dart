import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttercare168/models/user.dart';
import 'package:fluttercare168/constant/enum.dart';

import '../models/check_week_day.dart';
import '../models/city.dart';
import '../models/county.dart';

class UserModel extends ChangeNotifier {

  User? _user;
  User? get user => _user;
  String? token;
  bool isLineLogin = false;

  String? fcmToken;
  String? platformType;
  String? deviceId;

  //首頁搜索資料
  CareType careType = CareType.homeCare;
  City city = City.getCityFromId(2); //台北市
  // County district = County.getCountyFromId(8) ;//中正區;
  TimeType timeType = TimeType.continuous;
  DateTime startDate = DateTime.now().add(const Duration(days: 2));
  DateTime endDate = DateTime.now().add(const Duration(days: 3));
  TimeOfDay startTime = const TimeOfDay(hour: 09, minute: 0);
  TimeOfDay endTime = const TimeOfDay(hour: 09, minute: 0);
  List<CheckWeekDay> checkWeekDays = CheckWeekDay.getAllDays();

  int? currentAppVersionCode;

  bool isNotShowTeachingDialogAgain = false;

  void setUser(User theUser){
    _user = theUser;
    notifyListeners();
  }

  void removeUser(BuildContext context){
    _user = null;
    isLineLogin = false;
    token = null;
    notifyListeners();
  }

  void setUserUnReadNum(int num){
    _user!.totalUnReadNum = num;
    notifyListeners();
  }

  bool isLogin(){
    if(_user != null){
      return true;
    }else{
      return false;
    }
  }

  void updateLineStatus(){
    if(_user!=null){
      _user?.isGottenLineId = true;
      notifyListeners();
    }
  }

  void updateBankAccount(String newBankCode, String newBranchCode, String newAccountNum){
    _user?.aTMInfoBankCode = newBankCode;
    _user?.aTMInfoBranchBankCode = newBranchCode;
    _user?.aTMInfoAccount = newAccountNum;
  }

  void updateProfile(String? newName, String? newGender, String? newPhoneNumber, String? newEmail){
    _user?.name = newName;
    _user?.gender = newGender;
    _user?.phone = newPhoneNumber;
    _user?.email = newEmail;
    notifyListeners();
  }

  void updateUserAvatar(String newImage){
    _user?.image = newImage;
    notifyListeners();
  }

  //更新搜索資料
  void updateCheckWeekDays(List<CheckWeekDay> checkWeekDays){
    this.checkWeekDays = checkWeekDays;
    notifyListeners();
  }

  void changeBookingStartDate(DateTime newStartDate){
    startDate = newStartDate;
  }

  void changeBookingEndDate(DateTime newEndDate){
    endDate = newEndDate;
  }

  void changeBookingStartTime(TimeOfDay newStartTime){
    startTime = newStartTime;
  }

  void changeBookingEndTime(TimeOfDay newEndTime){
    endTime = newEndTime;
  }

  void changeBookingTimeType(TimeType newTimeType){
    timeType = newTimeType;
    notifyListeners();
  }

}
