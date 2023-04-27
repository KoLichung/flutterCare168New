
class User {
  int? id;
  String? phone;
  String? name;
  String? gender;
  String? email;
  String? address;
  String? image;

  bool? isApplyServant;
  bool? isServantPassed;

  // double? rating;
  bool? isHome;
  int? homeHourWage;
  int? homeHalfDayWage;
  int? homeOneDayWage;
  bool? isHospital;
  int? hospitalHourWage;
  int? hospitalHalfDayWage;
  int? hospitalOneDayWage;
  String? aboutMe;
  String? aTMInfoBankCode;
  String? aTMInfoBranchBankCode;
  String? aTMInfoAccount;

  bool? isGottenLineId;
  int? totalUnReadNum = 0;

  User(
      {this.id,
        this.phone,
        this.name,
        this.gender,
        this.email,
        this.address,
        this.image,
        this.isApplyServant,
        this.isServantPassed,
        // this.rating,
        this.isHome,
        this.homeHourWage,
        this.homeHalfDayWage,
        this.homeOneDayWage,
        this.isHospital,
        this.hospitalHourWage,
        this.hospitalHalfDayWage,
        this.hospitalOneDayWage,
        this.aboutMe,
        this.aTMInfoBankCode,
        this.aTMInfoBranchBankCode,
        this.aTMInfoAccount,
        this.isGottenLineId,
        this.totalUnReadNum,
      });

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    phone = json['phone'];
    name = json['name'];
    gender = (json['gender']=='M')?'男':'女';

    if(json['email'] == null){
      email = '';
    } else {
      email = json['email'];
    }

    if(json['address']==null){
      address = '';
    } else {
      address = json['address'];
    }
    image = json['image'];

    if(json['is_apply_servant']==null){
      isApplyServant = false;
    }else{
      isApplyServant = json['is_apply_servant'];
    }

    if(json['is_servant_passed']==null){
      isServantPassed = false;
    }else{
      isServantPassed = json['is_servant_passed'];
    }
    // rating = json['rating'];
    isHome = json['is_home'];
    homeHourWage = json['home_hour_wage'];
    homeHalfDayWage = json['home_half_day_wage'];
    homeOneDayWage = json['home_one_day_wage'];
    isHospital = json['is_hospital'];
    hospitalHourWage = json['hospital_hour_wage'];
    hospitalHalfDayWage = json['hospital_half_day_wage'];
    hospitalOneDayWage = json['hospital_one_day_wage'];
    aboutMe = json['about_me'];
    aTMInfoBankCode = json['ATMInfoBankCode'];
    aTMInfoBranchBankCode = json['ATMInfoBranchBankCode'];
    aTMInfoAccount = json['ATMInfoAccount'];

    totalUnReadNum = json['total_unread_num'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['phone'] = this.phone;
    data['name'] = this.name;
    data['gender'] = this.gender;
    data['email'] = this.email;
    data['address'] = this.address;
    data['image'] = this.image;
    data['is_apply_servant'] = this.isApplyServant;
    data['is_servant_passed'] = this.isServantPassed;
    // data['rating'] = this.rating;
    data['is_home'] = this.isHome;
    data['home_hour_wage'] = this.homeHourWage;
    data['home_half_day_wage'] = this.homeHalfDayWage;
    data['home_one_day_wage'] = this.homeOneDayWage;
    data['is_hospital'] = this.isHospital;
    data['hospital_hour_wage'] = this.hospitalHourWage;
    data['hospital_half_day_wage'] = this.hospitalHalfDayWage;
    data['hospital_one_day_wage'] = this.hospitalOneDayWage;
    data['about_me'] = this.aboutMe;
    data['ATMInfoBankCode'] = this.aTMInfoBankCode;
    data['ATMInfoBranchBankCode'] = this.aTMInfoBranchBankCode;
    data['ATMInfoAccount'] = this.aTMInfoAccount;
    return data;
  }

}