
import 'package:fluttercare168/models/language.dart';
import 'package:fluttercare168/models/license.dart';
import 'package:fluttercare168/models/review.dart';
import 'package:fluttercare168/models/service.dart';

import '../constant/server_api.dart';

class Carer {
  int? id;
  String? name;
  String? gender;
  String? image;
  String? phone;
  double? servantAvgRating;
  bool? isHome;
  int? homeHourWage;
  int? homeHalfDayWage;
  int? homeOneDayWage;
  bool? isHospital;
  int? hospitalHourWage;
  int? hospitalHalfDayWage;
  int? hospitalOneDayWage;
  int? ratingNums;
  String? backgroundImageUrl;
  String? aboutMe;
  int? avgRate;
  List<Locations>? locations;
  List<Service>? services;
  List<License>? licences;
  List<Review>? reviews;
  List<Language>? languages;

  Carer(
      {this.id,
       this.name,
       this.gender,
       this.image,
       this.phone,
       this.servantAvgRating,
       this.isHome,
       this.homeHourWage,
       this.homeHalfDayWage,
       this.homeOneDayWage,
       this.isHospital,
       this.hospitalHourWage,
       this.hospitalHalfDayWage,
       this.hospitalOneDayWage,
       this.ratingNums,
       this.backgroundImageUrl,
       this.aboutMe,
       this.avgRate,
       this.locations,
       this.services,
       this.licences,
       this.reviews,
       this.languages});

  factory Carer.fromJson(Map<String, dynamic> json) {
    var locations =  (json['locations'] ?? [])as List;
    List<Locations> locationList = locations.map((i) => Locations.fromJson(i)).toList();

    var services =  (json['services'] ?? [])as List;
    List<Service> serviceList = services.map((i) => Service.fromJson(i)).toList();

    var licences =  (json['licences'] ?? [])as List;
    List<License> licenceList = licences.map((i) => License.fromJson(i)).toList();

    var reviews =  (json['reviews'] ?? [])as List;
    List<Review> reviewList = reviews.map((i) => Review.fromJson(i)).toList();

    var languages =  (json['languages'] ?? [])as List;
    List<Language> languageList = languages.map((i) => Language.fromJson(i)).toList();

    if(json['avg_rate']==null){
      json['avg_rate'] = 0;
    }
    if(json['background_image'] ==null){
      json['background_image'] = '';
    }

    if(json['image']!=null) {
      if( json['image'].toString().contains('http')){
        json['image'] = json['image'];
      }else{
        json['image'] = ServerApi.host + json['image'];
      }
    }

    return Carer(
        id: json['id'],
        name: json['name'],
        gender: json['gender'],
        image: json['image'],
        phone: json['phone'],
        servantAvgRating: json['servant_avg_rating']+.0,
        isHome: (json['is_home']!=null)?json['is_home']:false,
        homeHourWage: json['home_hour_wage'],
        homeHalfDayWage: json['home_half_day_wage'],
        homeOneDayWage: json['home_one_day_wage'],
        isHospital: (json['is_hospital']!=null)?json['is_hospital']:false,
        hospitalHourWage: json['hospital_hour_wage'],
        hospitalHalfDayWage: json['hospital_half_day_wage'],
        hospitalOneDayWage: json['hospital_one_day_wage'],
        ratingNums: json['rating_nums'],
        backgroundImageUrl: json['background_image'],
        aboutMe: json['about_me'],
        avgRate: json['avg_rate'],
        locations: locationList,
        services: serviceList,
        licences: licenceList,
        reviews: reviewList,
        languages: languageList,

    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['image'] = this.image;
    data['servant_avg_rating'] = this.servantAvgRating;
    data['is_home'] = this.isHome;
    data['home_hour_wage'] = this.homeHourWage;
    data['home_half_day_wage'] = this.homeHalfDayWage;
    data['home_one_day_wage'] = this.homeOneDayWage;
    data['is_hospital'] = this.isHospital;
    data['hospital_hour_wage'] = this.hospitalHourWage;
    data['hospital_half_day_wage'] = this.hospitalHalfDayWage;
    data['hospital_one_day_wage'] = this.hospitalOneDayWage;
    data['rating_nums'] = this.ratingNums;
    data['background_image_url'] = this.backgroundImageUrl;
    data['about_me'] = this.aboutMe;
    data['avg_rate'] = this.avgRate;

    if (this.locations != null) {
      data['locations'] = this.locations!.map((v) => v.toJson()).toList();
    }
    if (this.services != null) {
      data['services'] = this.services!.map((v) => v.toJson()).toList();
    }
    if (this.licences != null) {
      data['licences'] = this.licences!.map((v) => v.toJson()).toList();
    }
    if (this.reviews != null) {
      data['reviews'] = this.reviews!.map((v) => v.toJson()).toList();
    }
    if (this.languages != null) {
      data['languages'] = this.languages!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Locations {
  int? id;
  int? transferFee;
  int? user;
  int? city;
  // int? county;

  Locations({this.id, this.transferFee, this.user, this.city});

  Locations.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    transferFee = json['transfer_fee'];
    user = json['user'];
    city = json['city'];
    // county = json['county'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['transfer_fee'] = this.transferFee;
    data['user'] = this.user;
    data['city'] = this.city;
    // data['county'] = this.county;
    return data;
  }
}