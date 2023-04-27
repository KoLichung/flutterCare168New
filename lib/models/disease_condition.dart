import 'dart:convert';

class DiseaseCondition {
  int? id;
  String? name;

  DiseaseCondition({this.id, this.name});

  DiseaseCondition.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    return data;
  }

  //http://202.182.105.11/api/disease_conditions/
  static String jsonData = '[ { "id": 1, "name": "無" }, { "id": 2, "name": "手術照顧" }, { "id": 3, "name": "骨折" }, { "id": 4, "name": "腫瘤" }, { "id": 5, "name": "中風" }, { "id": 6, "name": "癌症" }, { "id": 7, "name": "高血壓" }, { "id": 8, "name": "糖尿病" }, { "id": 9, "name": "心臟病" }, { "id": 10, "name": "腎臟病" }, { "id": 11, "name": "骨質疏鬆症" }, { "id": 12, "name": "關節炎" }, { "id": 13, "name": "肺炎" }, { "id": 14, "name": "腸胃道感染" }, { "id": 15, "name": "敗血症" }, { "id": 16, "name": "失智症" }, { "id": 17, "name": "帕金森氏症" }, { "id": 18, "name": "精神疾病" }, { "id": 19, "name": "癲癇" } ]';

  static List<String> getDiseaseNames(){
    List<String> diseaseNames = [];
    List body = json.decode(jsonData);
    List<DiseaseCondition> diseases = body.map((e) => DiseaseCondition.fromJson(e)).toList();
    diseaseNames = diseases.map((e) => e.name!).toList();
    return diseaseNames;
  }

  static String getDiseaseNameFromId(int diseaseId){
    List body = json.decode(DiseaseCondition.jsonData);
    List<DiseaseCondition> diseases = body.map((value) => DiseaseCondition.fromJson(value)).toList();
    for (var disease in diseases){
      if (diseaseId == disease.id){
        return disease.name!;
      }
    }
    return 'not found';
  }

  static int getIdFromDiseaseName(String name){
    List body = json.decode(DiseaseCondition.jsonData);
    List<DiseaseCondition> diseases = body.map((value) => DiseaseCondition.fromJson(value)).toList();
    for (var disease in diseases){
      if (name == disease.name){
        return disease.id!;
      }
    }
    return 0;
  }

}