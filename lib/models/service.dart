import 'dart:convert';

class Service {
  int? id;
  double? increasePercent;
  String? name;
  String? remark;
  bool? isIncreasePrice;
  int? service;

  Service({this.id, this.increasePercent, this.name, this.remark, this.isIncreasePrice, this.service});

  Service.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    if(json['increase_percent']!=null){
      if(json['increase_percent'].toString().contains('.')){
        increasePercent = json['increase_percent'];
      }else{
        increasePercent = json['increase_percent']+.0;
      }
    }
    name = json['name'];
    if(json['remark'] == null){
      remark = '';
    } else {
      remark = json['remark'];
    }
    isIncreasePrice = json['is_increase_price'];
    service = json['service'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['increase_percent'] = this.increasePercent;
    data['name'] = this.name;
    data['remark'] = this.remark;
    data['is_increase_price'] = this.isIncreasePrice;
    data['service'] = this.service;
    return data;
  }

  //http://202.182.105.11/api/services/
  static String jsonData = '[ { "id": 1, "increase_percent": 0, "name": "急診室", "remark": null, "is_increase_price": true }, { "id": 2, "increase_percent": 0, "name": "傳染性疾病", "remark": null, "is_increase_price": true }, { "id": 3, "increase_percent": 0, "name": "體重超過 75 公斤", "remark": null, "is_increase_price": true }, { "id": 4, "increase_percent": 0, "name": "體重超過 90 公斤", "remark": null, "is_increase_price": true }, { "id": 5, "increase_percent": 0, "name": "安全維護", "remark": "預防跌倒、陪同散步、推輪椅、心靈陪伴", "is_increase_price": false }, { "id": 6, "increase_percent": 0, "name": "協助進食", "remark": "用餐，按醫囑用藥", "is_increase_price": false }, { "id": 7, "increase_percent": 0, "name": "協助如廁", "remark": "大小便處理、更換尿布、會陰沖洗", "is_increase_price": false }, { "id": 8, "increase_percent": 0, "name": "身體清潔", "remark": "沐浴、擦澡、更衣", "is_increase_price": false }, { "id": 9, "increase_percent": 0, "name": "陪同就醫", "remark": "陪伴看診、洗腎，代領藥品", "is_increase_price": false }, { "id": 10, "increase_percent": 0, "name": "陪同復健", "remark": "※有復健需求可先聊聊溝通復健內容與服務費用是否不同，以維護雙方權益^^", "is_increase_price": false }, { "id": 11, "increase_percent": 0, "name": "代購物品", "remark": "代購餐點、生活必需品，以有發票或收據為主 ※代購期間服務者無法負責安全維護，家屬需自行評估被照顧者狀況", "is_increase_price": false }, { "id": 12, "increase_percent": 0, "name": "簡易備餐", "remark": "依現有食材簡易煮粥、麵食或加熱即食品；僅提供被照顧者與一位家屬餐食", "is_increase_price": false }, { "id": 13, "increase_percent": 0, "name": "家務協助", "remark": "簡易掃地拖地，清洗、收折衣物，清洗、更換床單 ※服務範圍僅限被照顧者主要生活環境，照服員非專業清潔人員無提供刷洗環境、移動家具、大掃除等服務；清洗衣物、床單，需提供洗衣機或付費使用投幣式洗衣機，超出以上服務範圍服務者有權利拒絕服務", "is_increase_price": false }, { "id": 14, "increase_percent": 0, "name": "鼻胃管灌食", "remark": null, "is_increase_price": false }, { "id": 15, "increase_percent": 0, "name": "管路安全照護", "remark": null, "is_increase_price": false }, { "id": 16, "increase_percent": 0, "name": "協助移位", "remark": null, "is_increase_price": false }, { "id": 17, "increase_percent": 0, "name": "翻身拍背", "remark": "僅提供長期臥床或手術無法自行翻身的病人", "is_increase_price": false }, { "id": 18, "increase_percent": 0, "name": "被動關節運動", "remark": "僅提供長期臥床、癱瘓、昏迷或關節炎的病人； 病人有骨質疏鬆、骨折病史請告知", "is_increase_price": false } ]';

  static List<Service> getAllServices(){
    List body = json.decode(jsonData);
    List<Service> services = body.map((e) => Service.fromJson(e)).toList();
    return services;
  }

  static List<Service> getBasicServices(){
    List<Service> basicServices=[];

    List body = json.decode(Service.jsonData);
    List<Service> services = body.map((value) => Service.fromJson(value)).toList();

    for(var service in services){
      if (service.isIncreasePrice == false){
        basicServices.add(service);
      }
    }
    return basicServices;
  }

  static List<Service> getIncreasePriceServices(){
    List<Service> increasePriceService = [];

    List body = json.decode(Service.jsonData);
    List<Service> services = body.map((e) => Service.fromJson(e)).toList();

    for(var service in services){
      if (service.isIncreasePrice == true){
        service.service = service.id;
        increasePriceService.add(service);
      }
    }

    return increasePriceService;

  }

  static String getServiceNameFromId(int serviceId){
    List body = json.decode(Service.jsonData);
    List<Service> services = body.map((value) => Service.fromJson(value)).toList();
    for (var service in services){
      if (serviceId == service.id){
        return service.name!;
      }
    }
    return 'not found';
  }

  static int getIdFromName(String name){
    List body = json.decode(Service.jsonData);
    List<Service> services = body.map((value) => Service.fromJson(value)).toList();
    for (var service in services){
      if (name == service.name){
        return service.id!;
      }
    }
    return 0;
  }

  static Service getServiceFromName(String name){
    List body = json.decode(Service.jsonData);
    List<Service> services = body.map((value) => Service.fromJson(value)).toList();
    for(var service in services){
      if(service.name == name){
        return service;
      }
    }
    return Service();
  }

}