import 'dart:convert';

class Language {
  int? id;
  String? name;
  String? languageName;
  String? remark;
  int? user;
  int? language;

  Language({this.id, this.name, this.languageName, this.remark, this.user, this.language});

  Language.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    languageName = json['language_name'];
    remark = json['remark'];
    user = json['user'];
    language = json['language'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['language_name'] = this.languageName;
    data['remark'] = this.remark;
    data['user'] = this.user;
    data['language'] = this.language;
    return data;
  }

  static String jsonData = '[ { "id": 1, "name": "國語" }, { "id": 2, "name": "台語" }, { "id": 3, "name": "客家話" }, { "id": 4, "name": "粵語" }, { "id": 5, "name": "原住民語" }, { "id": 6, "name": "日文" }, { "id": 7, "name": "英文" }, { "id": 8, "name": "其他" } ]';

  static List<Language> getLanguages(){
    List body = json.decode(jsonData);
    List<Language> languages = body.map((e) => Language.fromJson(e)).toList();
    return languages;
  }

  static List<String> getLanguageNames(){
    List<String> languageNames = [];
    List body = json.decode(jsonData);
    List<Language> languages = body.map((e) => Language.fromJson(e)).toList();
    languageNames = languages.map((e) => e.name!).toList();
    return languageNames;
  }

  static String getLanguageFromId(int langId){
    List body = json.decode(Language.jsonData);
    List<Language> languages = body.map((value) => Language.fromJson(value)).toList();
    for (var lang in languages){
      if (langId == lang.id){
        return lang.name!;
      }
    }
    return 'not found';
  }

}