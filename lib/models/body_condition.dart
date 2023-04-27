import 'dart:convert';

class BodyCondition {
  int? id;
  String? name;

  BodyCondition({this.id, this.name});

  BodyCondition.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    return data;
  }

  //http://202.182.105.11/api/body_conditions/
  static String jsonData = '[ { "id": 1, "name": "無" }, { "id": 2, "name": "使用輔具" }, { "id": 3, "name": "傷口" }, { "id": 4, "name": "引流管" }, { "id": 5, "name": "氣切管" }, { "id": 6, "name": "長期臥床" }, { "id": 7, "name": "攣縮" }, { "id": 8, "name": "褥瘡" }, { "id": 9, "name": "意識不清" }, { "id": 10, "name": "鼻胃管" }, { "id": 11, "name": "尿管" }, { "id": 12, "name": "胃造口" }, { "id": 13, "name": "腸造口 - 人工肛門" } ]';

  static List<String> getBodyConditionNames(){
    List<String> bodyConditions = [];
    List body = json.decode(jsonData);
    List<BodyCondition> conditions = body.map((e) => BodyCondition.fromJson(e)).toList();
    bodyConditions = conditions.map((e) => e.name!).toList();
    return bodyConditions;
  }

  static String getBodyConditionNameFromId(int conditionId){
    List body = json.decode(BodyCondition.jsonData);
    List<BodyCondition> conditions = body.map((value) => BodyCondition.fromJson(value)).toList();
    for (var condition in conditions){
      if (conditionId == condition.id){
        return condition.name!;
      }
    }
    return 'not found';
  }

  static int getIdFromName(String name){
    List body = json.decode(BodyCondition.jsonData);
    List<BodyCondition> conditions = body.map((value) => BodyCondition.fromJson(value)).toList();
    for (var condition in conditions){
      if (name == condition.name){
        return condition.id!;
      }
    }
    return 0;
  }

}