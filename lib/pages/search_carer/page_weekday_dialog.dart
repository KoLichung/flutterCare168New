import 'package:flutter/material.dart';
import 'package:fluttercare168/constant/color.dart';
import 'package:fluttercare168/notifier_model/booking_model.dart';
import 'package:fluttercare168/notifier_model/require_model.dart';
import 'package:fluttercare168/notifier_model/user_model.dart';
import 'package:provider/provider.dart';

import '../../models/check_week_day.dart';

class PageWeekdayDialog extends StatefulWidget {
  final String modelName;

  PageWeekdayDialog({required this.modelName});

  @override
  _PageWeekdayDialogState createState() => new _PageWeekdayDialogState();
}

class _PageWeekdayDialogState extends State<PageWeekdayDialog> {

  List<CheckWeekDay> dialogWeekDayChoices = [];

  @override
  void initState() {
    super.initState();
    if(widget.modelName=='user_model'){
      var userModel = context.read<UserModel>();
      dialogWeekDayChoices = userModel.checkWeekDays;
    }else if(widget.modelName=='require_model'){
      var requireModel = context.read<RequireModel>();
      dialogWeekDayChoices = requireModel.checkWeekDays;
    }else if(widget.modelName=='booking_model'){
      var bookingModel = context.read<BookingModel>();
      dialogWeekDayChoices = bookingModel.checkWeekDays;
    }
  }

  @override
  Widget build(BuildContext context) {
    // var userModel = context.read<UserModel>();
    return AlertDialog(
      titlePadding: const EdgeInsets.all(0),
      title: Container(
        width: 260,
        padding: const EdgeInsets.all(10),
        color: AppColor.purple,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('選擇週間', style: TextStyle(color: Colors.white),),
          ],
        ),
      ),
      contentPadding: const EdgeInsets.all(0),
      content: Container(
        height: 420,
        width: 320,
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 30),
        child: showWeekDayCheckBoxes(dialogWeekDayChoices),
      ),
      backgroundColor: AppColor.purple,
      actions: <Widget>[
        OutlinedButton(
          child: const Text('確定', style: TextStyle(color: Colors.white)),
          style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white)),
          onPressed: () {
            if(widget.modelName=='user_model'){
              var userModel = context.read<UserModel>();
               userModel.checkWeekDays = dialogWeekDayChoices;
            }else if(widget.modelName=='require_model'){
              var requireModel = context.read<RequireModel>();
              requireModel.checkWeekDays = dialogWeekDayChoices;
            }else if(widget.modelName=='booking_model'){
              var bookingModel = context.read<BookingModel>();
              bookingModel.checkWeekDays = dialogWeekDayChoices;
            }
            Navigator.pop(context);
          },
        )
      ],
    );
  }

  showWeekDayCheckBoxes(List<CheckWeekDay> weekDayChoices){
    List<Row> weekDayRowList = [];
    weekDayChoices.asMap().forEach((index, weekDayChoice) {
      weekDayRowList.add(
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 60,
                height: 50,
                child: Checkbox(
                  checkColor: Colors.white,
                  activeColor: AppColor.purple,
                  value: weekDayChoice.isChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      weekDayChoice.isChecked = value!;
                    });
                  },
                ),
              ),
              Text(weekDayChoice.day),
              const SizedBox(height: 6,)
            ],
          )
      );
    });
    return Column(children: weekDayRowList);
  }
}
