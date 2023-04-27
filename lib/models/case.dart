import 'package:flutter/foundation.dart';
import 'package:fluttercare168/models/language.dart';
import 'carer.dart';

class Case {
  int? id;
  int? reviewsNum;
  int? ratingNums;
  double? servantRating;
  double? avgOffenderRating;

  int? numOffenderRating;
  double? caseOffenderRating;

  int? hourWage;
  int? workHours;
  int? baseMoney;
  double? platformPercent;
  int? platformMoney;
  int? totalMoney;
  String? servantName;
  String? careType;
  String? name;
  String? gender;

  String? state;

  int? age;
  int? weight;
  String? diseaseRemark;
  String? conditionsRemark;
  bool? isContinuousTime;
  bool? isTaken;
  bool? isOpenForSearch;

  String? roadName;
  String? hospitalName;

  String? weekday;
  double? startTime;
  double? endTime;
  String? startDatetime;
  String? endDatetime;
  String? createdAt;

  String? emergencycontactName;
  String? emergencycontactRelation;
  String? emergencycontactPhone;

  int? user;
  Carer? servant;
  int? city;
  int? county;
  List<Language>? languages;
  UserDetail? userDetail;

  String? neederName;
  String? neederPhone;

  Case(
      {this.id,
        this.reviewsNum,
        this.ratingNums,
        this.servantRating,
        this.avgOffenderRating,
        this.numOffenderRating,
        this.caseOffenderRating,
        this.hourWage,
        this.workHours,
        this.baseMoney,
        this.platformPercent,
        this.platformMoney,
        this.totalMoney,
        this.servantName,
        this.careType,
        this.name,
        this.gender,
        this.state,
        this.age,
        this.weight,
        this.diseaseRemark,
        this.conditionsRemark,
        this.isContinuousTime,
        this.isTaken,
        this.isOpenForSearch,
        this.roadName,
        this.hospitalName,
        this.weekday,
        this.startTime,
        this.endTime,
        this.startDatetime,
        this.endDatetime,
        this.createdAt,
        this.emergencycontactName,
        this.emergencycontactRelation,
        this.emergencycontactPhone,
        this.user,
        this.servant,
        this.city,
        this.county,
        this.languages,
        this.userDetail,
        this.neederName,
        this.neederPhone,
      });

  factory Case.fromJson(Map<String, dynamic> json){
    var list = (json['languages'] ?? []) as List;
    List<Language> languages = list.map((i) => Language.fromJson(i)).toList();

    if(json['road_name']==null){
      json['road_name'] = '';
    }

    if(json['hospital_name']==null){
      json['hospital_name']='';
    }

    if(json['emergencycontact_name']==null){
      json['emergencycontact_name']='';
    }

    if(json['emergencycontact_relation']==null){
      json['emergencycontact_relation']='';
    }

    if(json['emergencycontact_phone']==null){
      json['emergencycontact_phone']='';
    }

    if(json['avg_offender_rating']==0){
      json['avg_offender_rating']=0.0;
    }

    return Case(
      id: json['id'],
      reviewsNum: json['reviews_num'],
      ratingNums: json['rating_nums'],
      servantRating: (json['servant_rating']!=null)?json['servant_rating']:0.0,
      avgOffenderRating: json['avg_offender_rating'] ?? 0.0,
      numOffenderRating: json['num_offender_rating'] ?? 0,
      caseOffenderRating: json['case_offender_rating'],
      hourWage: json['hour_wage'],
      workHours: json['work_hours'],
      baseMoney: json['base_money'],
      platformPercent:json['platform_percent'],
      platformMoney: json['platform_money'],
      totalMoney: json['total_money'],
      servantName: json['servant_name'],
      careType: json['care_type'] == 'home' ? '居家照顧' :'醫院看護',
      name :  json['name'],
      gender :  json['gender'],
      state: json['state'],
      age :  json['age'],
      weight :  json['weight'],
      diseaseRemark :  json['disease_remark']!=null?json['disease_remark']:'',
      conditionsRemark :  json['conditions_remark']!=null?json['conditions_remark']:'',
      isContinuousTime :  json['is_continuous_time'],
      isTaken :  json['is_taken'],
      isOpenForSearch :  json['is_open_for_search'],
      roadName: json['road_name'],
      hospitalName: json['hospital_name'],
      weekday :  json['weekday'] ?? '',
      startTime :  json['start_time'],
      endTime :  json['end_time'],
      startDatetime :  (json['start_datetime']).substring(0,10),
      endDatetime :  (json['end_datetime']).substring(0,10),
      createdAt :  json['created_at'],
      emergencycontactName: json['emergencycontact_name'],
      emergencycontactPhone: json['emergencycontact_phone'],
      emergencycontactRelation: json['emergencycontact_relation'],
      user :  json['user'],
      servant : (json['servant']!=null)?Carer.fromJson(json['servant']):null,
      city :  json['city'],
      county :  json['county'],
      languages:languages,
      userDetail: (json['user_detail']!=null)?UserDetail.fromJson(json['user_detail']):null,
      neederName: json['needer_name'],
      neederPhone: json['needer_phone'],
    );

  }

  // Case.fromJson(Map<String, dynamic> json) {
    // id = json['id'];
    // reviewsNum = json['reviews_num'];
    // ratingNums = json['rating_nums'];
    // if(json['servant_rating'] == null){
    //   servantRating = 0;
    // } else {
    //   servantRating = json['servant_rating'];
    // }
    // if(json['avg_offender_rating']==null){
    //   avgOffenderRating = 0;
    // } else {
    //   avgOffenderRating = json['avg_offender_rating'];
    // }
    // if(json['num_offender_rating']==null){
    //   numOffenderRating = 0;
    // } else {
    //   numOffenderRating = json['num_offender_rating'];
    // }
    // caseOffenderRating = json['case_offender_rating'];
    // status = json['status'];
    // hourWage = json['hour_wage'];
    // workHours = json['work_hours'];
    // baseMoney = json['base_money'];
    // platformPercent = json['platform_percent'];
    // platformMoney = json['platform_money'];
    // totalMoney = json['total_money'];
    // servantName = json['servant_name'];
    // careType = json['care_type'] == 'home' ? '居家照顧' :'醫院看護';
    // name = json['name'];
    // gender = json['gender'] == "F" ? '女' : '男';
    // age = json['age'];
    // weight = json['weight'];
    // diseaseRemark = json['disease_remark'];
    // conditionsRemark = json['conditions_remark'];
    // isContinuousTime = json['is_continuous_time'];
    // isTaken = json['is_taken'];
    // isOpenForSearch = json['is_open_for_search'];
    // weekday = json['weekday'];
    // startTime = json['start_time'];
    // endTime = json['end_time'];
    // startDatetime = (json['start_datetime']).substring(0,10);
    // endDatetime = (json['end_datetime']).substring(0,10);
    // createdAt = json['created_at'];
    // user = json['user'];
    // servant = Carer.fromJson(json['servant']);
    // city = json['city'];
    // county = json['county'];

  // }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['reviews_num'] = this.reviewsNum;
    data['rating_nums'] = this.ratingNums;
    data['servant_rating'] = this.servantRating;
    data['avg_offender_rating'] = this.avgOffenderRating;
    data['num_offender_rating'] = this.numOffenderRating;
    data['case_offender_rating'] = this.caseOffenderRating;
    data['hour_wage'] = this.hourWage;
    data['work_hours'] = this.workHours;
    data['base_money'] = this.baseMoney;
    data['platform_percent'] = this.platformPercent;
    data['platform_money'] = this.platformMoney;
    data['total_money'] = this.totalMoney;
    data['servant_name'] = this.servantName;
    data['care_type'] = this.careType;
    data['name'] = this.name;
    data['gender'] = this.gender;
    data['age'] = this.age;
    data['weight'] = this.weight;
    data['disease_remark'] = this.diseaseRemark;
    data['conditions_remark'] = this.conditionsRemark;
    data['is_continuous_time'] = this.isContinuousTime;
    data['is_taken'] = this.isTaken;
    data['is_open_for_search'] = this.isOpenForSearch;
    data['weekday'] = this.weekday;
    data['start_time'] = this.startTime;
    data['end_time'] = this.endTime;
    data['start_datetime'] = this.startDatetime;
    data['end_datetime'] = this.endDatetime;
    data['created_at'] = this.createdAt;
    data['user'] = this.user;
    data['servant'] = this.servant;
    data['city'] = this.city;
    data['county'] = this.county;


    if (this.languages != null) {
      data['languages'] = this.languages!.map((v) => v.toJson()).toList();
    }
    data['needer_name'] = this.neederName;
    data['needer_phone'] = this.neederPhone;

    return data;
  }

  static String getTime(double time){
    var hour = time.floor();
    double minute = time - hour;
    String theMinute =  (minute * 60).toStringAsFixed(0);

    String timeState = '';
    if(0<hour && hour<5){
      timeState = '晚上 ';
    }else if(hour>=5 && hour<11){
      timeState = '早上 ';
    }else if(hour>=11 && hour<13){
      timeState = '中午 ';
    }else if(hour>=13 && hour<17){
      timeState = '下午 ';
    }else{
      timeState = '晚上 ';
    }

    if(theMinute == '0'){
      String theTime = timeState + '$hour:00';
      return theTime;
    } else {
      if(int.parse(theMinute)<10){
        return timeState+'$hour:0$theMinute';
      }else{
        return timeState+'$hour:$theMinute';
      }
    }
  }

}

class UserDetail {
  int? id;
  String? phone;
  String? name;
  String? gender;
  String? image;

  UserDetail({this.id, this.phone, this.name, this.gender, this.image});

  UserDetail.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    phone = json['phone'];
    name = json['name'];
    gender = json['gender'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['phone'] = this.phone;
    data['name'] = this.name;
    data['gender'] = this.gender;
    data['image'] = this.image;
    return data;
  }
}