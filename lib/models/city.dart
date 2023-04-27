import 'dart:convert';

class City {
  int? id;
  String? name;


  City({this.id, this.name});

  City.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    return data;
  }

  static String jsonData = '[ { "id": 1, "name": "基隆市", "newebpay_cityname": "基市", "nameE": "Keelung City" }, { "id": 2, "name": "台北市", "newebpay_cityname": "北市", "nameE": "Taipei City" }, { "id": 3, "name": "新北市", "newebpay_cityname": "新北市", "nameE": "New Taipei City" }, { "id": 4, "name": "桃園市", "newebpay_cityname": "桃市", "nameE": "Taoyuan County" }, { "id": 5, "name": "新竹市", "newebpay_cityname": "竹市", "nameE": "Hsinchu City" }, { "id": 6, "name": "新竹縣", "newebpay_cityname": "竹縣", "nameE": "Hsinchu County" }, { "id": 7, "name": "苗栗縣", "newebpay_cityname": "苗縣", "nameE": "Miaoli County" }, { "id": 8, "name": "台中市", "newebpay_cityname": "中市", "nameE": "Taichung City" }, { "id": 9, "name": "彰化縣", "newebpay_cityname": "彰縣", "nameE": "Changhua County" }, { "id": 10, "name": "南投縣", "newebpay_cityname": "投縣", "nameE": "Nantou County" }, { "id": 11, "name": "雲林縣", "newebpay_cityname": "雲縣", "nameE": "Yunlin County" }, { "id": 12, "name": "嘉義市", "newebpay_cityname": "嘉市", "nameE": "Chiayi City" }, { "id": 13, "name": "嘉義縣", "newebpay_cityname": "嘉縣", "nameE": "Chiayi County" }, { "id": 14, "name": "台南市", "newebpay_cityname": "南市", "nameE": "Tainan City" }, { "id": 15, "name": "高雄市", "newebpay_cityname": "高市", "nameE": "Kaohsiung City" }, { "id": 16, "name": "屏東縣", "newebpay_cityname": "屏縣", "nameE": "Pingtung County" }, { "id": 17, "name": "宜蘭縣", "newebpay_cityname": "宜縣", "nameE": "Yilan County" }, { "id": 18, "name": "花蓮縣", "newebpay_cityname": "花縣", "nameE": "Hualien County" }, { "id": 19, "name": "台東縣", "newebpay_cityname": "東縣", "nameE": "Taitung County" }, { "id": 20, "name": "澎湖縣", "newebpay_cityname": "澎縣", "nameE": "Penghu County" }, { "id": 21, "name": "金門縣", "newebpay_cityname": "金門", "nameE": "Kinmen County" }, { "id": 22, "name": "連江縣", "newebpay_cityname": "連江", "nameE": "Lienchiang County" } ]';

  static List<String> getCityNames(){
    List<String>? names = [];
    List bodyCategory = json.decode(City.jsonData);
    List<City> cities = bodyCategory.map((value) => City.fromJson(value)).toList();
    names = cities.map((e) => e.name!).toList();
    return names;
  }

  static String getCityNameFromId(int cityId){
    List bodyCategory = json.decode(City.jsonData);
    List<City> cities = bodyCategory.map((value) => City.fromJson(value)).toList();
    for (var city in cities){
      if (cityId == city.id){
        return city.name!;
      }
    }
    return 'not found';
  }

  static City getCityFromId(int cityId){
    List bodyCategory = json.decode(City.jsonData);
    List<City> cities = bodyCategory.map((value) => City.fromJson(value)).toList();
    for (var city in cities){
      if (cityId == city.id){
        return city;
      }
    }
    return cities.first;
  }

  static int getIdFromCityName(String cityName){
    List bodyCategory = json.decode(City.jsonData);
    List<City> cities = bodyCategory.map((value) => City.fromJson(value)).toList();
    for (var city in cities){
      if (cityName == city.name){
        return city.id!;
      }
    }
    return 0;
  }

  static City getCityFromName(String name){
    List bodyCategory = json.decode(City.jsonData);
    List<City> cities = bodyCategory.map((value) => City.fromJson(value)).toList();
    for(var city in cities){
      if(city.name == name){
        return city;
      }
    }
    return City();
  }

}