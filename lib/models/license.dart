import 'dart:convert';

class License {
  int? id;
  String? name;
  String? licenseName;
  bool? isPassed;
  String? remark;
  String? image;
  int? user;
  int? license;

  License({this.id, this.name, this.licenseName, this.isPassed, this.remark, this.image, this.user, this.license});

  License.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    licenseName = json['license_name'];
    isPassed = json['isPassed'];
    if(json['remark']==null){
      remark = '';
    } else {
      remark = json['remark'];
    }
    image = json['image'];
    user = json['user'];
    license = json['license'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['license_name'] = this.licenseName;
    data['isPassed'] = this.isPassed;
    data['remark'] = this.remark;
    data['image'] = this.image;
    data['user'] = this.user;
    data['license'] = this.license;
    return data;
  }

  static String jsonData = '[ { "id": 1, "name": "身分證正面", "remark": null }, { "id": 2, "name": "身分證反面", "remark": null }, { "id": 3, "name": "健保卡正面", "remark": null }, { "id": 4, "name": "COVID-19 疫苗接種記錄卡", "remark": "若未提供，服務者頁面會顯示「未提供」供預訂者參考" }, { "id": 5, "name": "良民證-警察刑事紀錄證明書", "remark": "若未提供，服務者頁面會顯示「未提供」供預訂者參考" }, { "id": 6, "name": "一年內體檢表（需有B肝表面抗原 & 胸部 X 光）", "remark": "若未提供，服務者頁面會顯示「未提供」供預訂者參考" }, { "id": 7, "name": "照服員結業證書", "remark": null }, { "id": 8, "name": "照服員單一級證照", "remark": null }, { "id": 9, "name": "高中(職)以上護理、照顧相關科系(組)畢業證書", "remark": null }, { "id": 10, "name": "護理師證書", "remark": null }, { "id": 11, "name": "長照證明卡", "remark": null }, { "id": 12, "name": "失智症 20 小時課程", "remark": null }, { "id": 13, "name": "身心障礙 20 小時課程", "remark": null }, { "id": 14, "name": "物理治療師證照", "remark": null }, { "id": 15, "name": "職能治療師證照", "remark": null } ]';

  static List<License> getLicenseNames (){
    List body = json.decode(jsonData);
    List<License> licenseNames = body.map((e) => License.fromJson(e)).toList();
    return licenseNames;
  }

  static List<License> getAboutMeLicenses(){
    List<License> aboutLicenses = [];
    List body = json.decode(License.jsonData);
    List<License> licenses = body.map((value) => License.fromJson(value)).toList();
    for(var license in licenses){
      if (license.id != 1 && license.id != 2 && license.id != 3){
        aboutLicenses.add(license);
      }
    }
    return aboutLicenses;
  }

  static List<License> getApplyLicenses(){
    List<License> applyLicenses=[];
    List body = json.decode(License.jsonData);
    List<License> licenses = body.map((value) => License.fromJson(value)).toList();
    for(var license in licenses){
      if (license.id == 1 || license.id == 2 || license.id == 3 || license.id == 7 || license.id == 8 || license.id == 9){
        applyLicenses.add(license);
      }
    }
    return applyLicenses;
  }

  static List<License> getIdentityLicense(){
    List<License> identityLicenses=[];
    List body = json.decode(License.jsonData);
    List<License> licenses = body.map((value) => License.fromJson(value)).toList();
    for(var license in licenses){
      if (license.id == 4){
        identityLicenses.add(license);
      }
      if (license.id == 5){
        identityLicenses.add(license);
      }
      if (license.id == 6){
        identityLicenses.add(license);
      }
    }
    return identityLicenses;
  }

  static List<License> getSkillLicense(){
    List<License> identityLicenses=[];
    List body = json.decode(License.jsonData);
    List<License> licenses = body.map((value) => License.fromJson(value)).toList();
    for(var license in licenses){
      if (license.id! >= 7 && license.id! <= 15){
        identityLicenses.add(license);
      }
    }
    return identityLicenses;
  }

  static String getLicenseNameFromID(int licenceId){
    List body = json.decode(jsonData);
    List<License> licenses = body.map((value) => License.fromJson(value)).toList();
    for (var license in licenses){
      if (licenceId == license.id){
        return license.name!;
      }
    }
    return 'not found';
  }

}