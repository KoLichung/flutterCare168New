class UserWeekDayTime {
  int? id;
  String? weekday;
  double? startTime;
  double? endTime;
  int? user;

  UserWeekDayTime(
      {this.id, this.weekday, this.startTime, this.endTime, this.user});

  UserWeekDayTime.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    weekday = json['weekday'];
    startTime = json['start_time'];
    endTime = json['end_time'];
    user = json['user'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['weekday'] = this.weekday;
    data['start_time'] = this.startTime;
    data['end_time'] = this.endTime;
    data['user'] = this.user;
    return data;
  }
}