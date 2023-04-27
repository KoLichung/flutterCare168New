class CheckWeekDay {
  String day;
  int weekDay;
  bool isChecked;
  CheckWeekDay({ required this.day, required this.weekDay,required this.isChecked});

  static List<CheckWeekDay> getAllDays(){
    List<CheckWeekDay> choices = [];
    choices.add(CheckWeekDay(day: '星期一', weekDay: 1, isChecked: true));
    choices.add(CheckWeekDay(day: '星期二', weekDay: 2, isChecked: true));
    choices.add(CheckWeekDay(day: '星期三', weekDay: 3,isChecked: true));
    choices.add(CheckWeekDay(day: '星期四', weekDay: 4,isChecked: true));
    choices.add(CheckWeekDay(day: '星期五', weekDay: 5,isChecked: true));
    choices.add(CheckWeekDay(day: '星期六', weekDay: 6,isChecked: true));
    choices.add(CheckWeekDay(day: '星期日', weekDay: 0,isChecked: true));

    return choices;
  }

}