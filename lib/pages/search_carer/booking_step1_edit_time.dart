import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttercare168/constant/color.dart';
import 'package:fluttercare168/notifier_model/booking_model.dart';
import 'package:fluttercare168/notifier_model/user_model.dart';
import 'package:fluttercare168/pages/search_carer/page_weekday_dialog.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:intl/intl.dart';
import 'package:fluttercare168/constant/enum.dart';
import 'package:fluttercare168/constant/format_converter.dart';
import 'package:url_launcher/url_launcher.dart';

class BookingStep1EditTime extends StatefulWidget {
  const BookingStep1EditTime({Key? key}) : super(key: key);

  @override
  _BookingStep1EditTimeState createState() => _BookingStep1EditTimeState();
}

class _BookingStep1EditTimeState extends State<BookingStep1EditTime> {

  final DateRangePickerController _startDateController = DateRangePickerController();
  final DateRangePickerController _endDateController = DateRangePickerController();
  final DateRangePickerController _dateRangePickerController = DateRangePickerController();

  @override
  void initState() {
    super.initState();
    var bookingModel = context.read<BookingModel>();
    var userModel = context.read<UserModel>();
    bookingModel.timeType == null ? bookingModel.timeType = userModel.timeType : bookingModel.timeType = bookingModel.timeType;
    bookingModel.startDate == null ? bookingModel.startDate = userModel.startDate : bookingModel.startDate = bookingModel.startDate;
    bookingModel.endDate == null ? bookingModel.endDate = userModel.endDate : bookingModel.endDate = bookingModel.endDate;
    bookingModel.startTime == null ? bookingModel.startTime = userModel.startTime : bookingModel.startTime = bookingModel.startTime;
    bookingModel.endTime == null ? bookingModel.endTime = userModel.endTime : bookingModel.endTime = bookingModel.endTime;
  }

  @override
  Widget build(BuildContext context) {
    var userModel = context.read<UserModel>();
    var bookingModel = context.read<BookingModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('填寫訂單'),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
              child: const Text('儲存',style: TextStyle(color: Colors.white),) ,
              onPressed: (){
                if(bookingModel.timeType != null){
                  bookingModel.changeBookingTimeType(bookingModel.timeType!);
                }
                if(bookingModel.startDate != null){
                  bookingModel.changeBookingStartDate(bookingModel.startDate!);
                }
                if(bookingModel.endDate != null){
                  bookingModel.changeBookingEndDate(bookingModel.endDate!);
                }
                if(bookingModel.startTime != null){
                  bookingModel.changeBookingStartTime(bookingModel.startTime!);
                }
                if(bookingModel.endTime != null){
                  bookingModel.changeBookingEndTime(bookingModel.endTime!);
                }
                if(bookingModel.startDate!.day == bookingModel.endDate!.day && timeToDouble(bookingModel.startTime!) > timeToDouble(bookingModel.endTime!)){
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("開始時間要小於結束時間")));
                }else{
                  Navigator.pop(context);
                }
              })
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.topLeft,
                child: Text('修改時間', style: TextStyle(fontWeight: FontWeight.bold),)),
            const SizedBox(height: 20,),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColor.purple, width: 2,),
                borderRadius: BorderRadius.circular(4),),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Row(
                      children: [
                        // const Text('時間類型：'),
                        Radio<TimeType>(
                          value: TimeType.continuous,
                          groupValue: bookingModel.timeType,
                          onChanged: (TimeType? value) {
                            setState(() {
                              bookingModel.timeType = value;
                            });
                          },
                        ),
                        const Text('連續時間'),
                        Radio<TimeType>(
                          value: TimeType.weekly,
                          groupValue: bookingModel.timeType,
                          onChanged: (TimeType? value) {
                            setState(() {
                              bookingModel.timeType = value;
                            });
                          },
                        ),
                        const Text('指定時段'),
                        TextButton(
                            child: const Text('(說明)',style: TextStyle(decoration: TextDecoration.underline, color: AppColor.purple, fontSize: 16),),
                            onPressed: () async {
                              Uri url = Uri.parse('https://care168.com.tw//news_detail?blogpost=7');
                              if (!await launchUrl(url)) {
                                throw 'Could not launch $url';
                              }
                            }),
                      ],
                    ),
                  ), //時間類型
                  const Divider(
                    color: AppColor.purple,
                    thickness: 2,
                    height: 0,
                  ),
                  bookingModel.timeType == null
                      ? (userModel.timeType == TimeType.continuous ? continuousTime() : weeklyTime())
                      : (bookingModel.timeType == TimeType.continuous ? continuousTime() : weeklyTime())
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double timeToDouble(TimeOfDay myTime) => myTime.hour + myTime.minute/60.0;

  //連續時間顯示
  continuousTime(){
    var bookingModel = context.read<BookingModel>();
    return Column(
      children: [
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              const Text('開始日期：'),
              GestureDetector(
                  onTap: (){
                    showDialog<Widget>(
                        context: context,
                        builder: (BuildContext context) {
                          return startDatePicker();
                        });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Text(DateFormat('MM / dd').format(bookingModel.startDate!)),
                  )
              ),
              const SizedBox(width: 20,),
              const Text('時間：'),
              GestureDetector(
                child: Text(bookingModel.startTime!.to24hours()),
                onTap: (){
                  _pickStartTime(context);
                },
              ),
            ],),
        ), //開始日期
        const Divider(
          color: AppColor.purple,
          thickness: 2,
          height: 0,
        ),
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              const Text('結束日期：'),
              GestureDetector(
                  onTap: (){
                    showDialog<Widget>(
                        context: context,
                        builder: (BuildContext context) {
                          return endDatePicker();
                        });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Text(DateFormat('MM / dd').format(bookingModel.endDate!)),
                  )
              ),
              const SizedBox(width: 20,),
              const Text('時間：'),
              GestureDetector(
                child: Text(bookingModel.endTime!.to24hours()),
                onTap: (){
                  _pickEndTime(context);
                },
              ),
            ],),
        ), //結束日期
      ],
    );
  }

  startDatePicker(){
    var bookingModel = context.read<BookingModel>();
    return Center(
      child: SizedBox(
        height: 460,
        width: 380,
        child: SfDateRangePickerTheme(
          data: SfDateRangePickerThemeData(
            brightness: Brightness.light,
            backgroundColor: Colors.white,
          ),
          child: SfDateRangePicker(
            controller: _startDateController,
            view: DateRangePickerView.month,
            monthViewSettings: const DateRangePickerMonthViewSettings(
              firstDayOfWeek: 7,
            ),
            allowViewNavigation: false,
            headerHeight: 60,
            headerStyle: const DateRangePickerHeaderStyle(
                backgroundColor: AppColor.purple,
                textAlign: TextAlign.center,
                textStyle: TextStyle(
                  fontSize: 22,
                  letterSpacing: 1,
                  color: Colors.white,
                )),
            selectionMode: DateRangePickerSelectionMode.single,
            minDate: DateTime.now(),
            maxDate: DateTime.now().add(const Duration(days: 60)),
            // onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
            //   setState(() {
            //     if (args.value is DateTime) {
            //       bookingModel.startDate = args.value;
            //     }
            //   });
            // },
            showActionButtons: true,
            cancelText: '取消',
            confirmText: '確定',
            onSubmit: (Object? value, ) {
              // print('chosen duration: $value');
              print(bookingModel.startDate);
              print(bookingModel.endDate);

              DateTime startDate = value as DateTime;
              print(startDate.day);
              print(bookingModel.endDate!.day);

              if(startDate.isAfter(bookingModel.endDate!) && startDate.day != bookingModel.endDate!.day ){
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("開始日期要早於結束日期！")));
              }else{
                setState(() {
                  bookingModel.startDate = startDate;
                });
              }
              Navigator.pop(context);
            },
            onCancel: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  endDatePicker(){
    var bookingModel = context.read<BookingModel>();
    return Center(
      child: SizedBox(
        height: 460,
        width: 380,
        child: SfDateRangePickerTheme(
          data: SfDateRangePickerThemeData(
            brightness: Brightness.light,
            backgroundColor: Colors.white,
          ),
          child: SfDateRangePicker(
            controller: _endDateController,
            view: DateRangePickerView.month,
            monthViewSettings: const DateRangePickerMonthViewSettings(
              firstDayOfWeek: 7,
            ),
            allowViewNavigation: false,
            headerHeight: 60,
            headerStyle: const DateRangePickerHeaderStyle(
                backgroundColor: AppColor.purple,
                textAlign: TextAlign.center,
                textStyle: TextStyle(
                  fontSize: 22,
                  letterSpacing: 1,
                  color: Colors.white,
                )),
            selectionMode: DateRangePickerSelectionMode.single,
            minDate: bookingModel.startDate!.add(const Duration(days: 0)),
            maxDate: DateTime.now().add(const Duration(days: 60)),
            // onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
            //   setState(() {
            //     if (args.value is DateTime) {
            //       bookingModel.endDate = args.value;
            //     }
            //   });
            // },
            showActionButtons: true,
            cancelText: '取消',
            confirmText: '確定',
            onSubmit: (Object? value, ) {
              DateTime endDate = value as DateTime;
              if(endDate.isBefore(bookingModel.startDate!) && endDate.day != bookingModel.startDate!.day ){
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("結束日期要晚於開始日期！")));
              }else{
                setState(() {
                  bookingModel.endDate = endDate;
                });
              }
              Navigator.pop(context);
            },
            onCancel: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  //指定時段
  weeklyTime(){
    var bookingModel = context.read<BookingModel>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              const Text('日期：'),
              GestureDetector(
                  onTap: (){
                    showDialog<Widget>(
                        context: context,
                        builder: (BuildContext context) {
                          return getDateRangePicker();
                        });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Text('${DateFormat('MM / dd').format(bookingModel.startDate!)}  -  ${DateFormat('MM / dd').format(bookingModel.endDate!)}'),
                  )
              ),
            ],
          ),
        ), //日期區間
        const Divider(
          color: AppColor.purple,
          thickness: 2,
          height: 0,
        ),
        Container(
          alignment: Alignment.centerLeft,
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child:GestureDetector(
                  child:
                  Row(
                    children: [
                      const Text('星期：'),
                      (getWeekDayStrings() == null || getWeekDayStrings() == '')
                          ? const Text('選擇週間')
                          : Flexible(child: Text(getWeekDayStrings(),overflow: TextOverflow.visible,)),
                    ],
                  ),
                  onTap: () async {
                    await showDialog<String>(
                        context: context,
                        builder: (BuildContext context) {
                          return PageWeekdayDialog(modelName: 'booking_model',);
                        });
                    setState(() {});
                  }),
          ), //週間星期
        const Divider(
          color: AppColor.purple,
          thickness: 2,
          height: 0,
        ),
        Container(
          alignment: Alignment.centerLeft,
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: GestureDetector(
            child: Text('開始時間：'+ bookingModel.startTime!.to24hours()),
            onTap: (){
              _pickStartTime(context);
            },
          ),
        ), //開始時間
        const Divider(
          color: AppColor.purple,
          thickness: 2,
          height: 0,
        ),
        Container(
          alignment: Alignment.centerLeft,
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: GestureDetector(
            child: Text('結束時間：'+bookingModel.endTime!.to24hours()),
            onTap: (){
              _pickEndTime(context);
            },
          ),
        ),//結束時間
      ],
    );
  }

  getWeekDayStrings(){
    List<String> dayStrings = [];
    var bookingModel = context.read<BookingModel>();
    for(var day in bookingModel.checkWeekDays){
      if(day.isChecked){
        dayStrings.add(day.day);
      }
    }
    return dayStrings.join(',');
  }

  getDateRangePicker(){
    return Center(
      child: SizedBox(
        height: 460,
        width: 360,
        child: SfDateRangePickerTheme(
          data: SfDateRangePickerThemeData(
            brightness: Brightness.light,
            backgroundColor: Colors.white,
          ),
          child: SfDateRangePicker(
            controller: _dateRangePickerController,
            view: DateRangePickerView.month,
            monthViewSettings: const DateRangePickerMonthViewSettings(
              firstDayOfWeek: 7,
            ),
            headerHeight: 60,
            headerStyle: const DateRangePickerHeaderStyle(
                backgroundColor: AppColor.purple,
                textAlign: TextAlign.center,
                textStyle: TextStyle(
                  fontSize: 22,
                  letterSpacing: 3,
                  color: Colors.white,
                )),
            selectionMode: DateRangePickerSelectionMode.range,
            minDate: DateTime.now(),
            onSelectionChanged: selectionChanged,
            showActionButtons: true,
            cancelText: '取消',
            confirmText: '確定',
            onSubmit: (Object? value, ) {
              Navigator.pop(context);
            },
            onCancel: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  void selectionChanged(DateRangePickerSelectionChangedArgs args) {
    var bookingModel = context.read<BookingModel>();
    setState(() {
      bookingModel.startDate = args.value.startDate;
      bookingModel.endDate = args.value.endDate ?? args.value.startDate;

    });
  }

  Future<void> _pickStartTime(BuildContext context) async {
    var bookingModel = context.read<BookingModel>();
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: bookingModel.startTime!,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,);
      },);
    if (picked != null && picked != bookingModel.startTime) {

      if(picked.minute > 0 && picked.minute < 15){
        bookingModel.startTime = TimeOfDay(hour: picked.hour, minute: 0);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("時間自動以30分鐘為單位調整！"),));
      } else if ((picked.minute >= 15 && picked.minute <30) || (picked.minute > 30 && picked.minute <45)){
        bookingModel.startTime = TimeOfDay(hour: picked.hour, minute: 30);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("時間自動以30分鐘為單位調整！"),));
      } else if (picked.minute >= 45 && picked.minute <= 59) {
        bookingModel.startTime = TimeOfDay(hour: picked.hour + 1, minute: 0);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("時間自動以30分鐘為單位調整！"),));
      }else{
        bookingModel.startTime = TimeOfDay(hour: picked.hour, minute: picked.minute);
      }

      setState(() {});
    }
  }

  Future<void> _pickEndTime(BuildContext context) async {
    var bookingModel = context.read<BookingModel>();
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: bookingModel.endTime!,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null && picked != bookingModel.endTime) {

      if(picked.minute > 0 && picked.minute < 15){
        bookingModel.endTime = TimeOfDay(hour: picked.hour, minute: 0);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("時間自動以30分鐘為單位調整！"),));
      } else if ((picked.minute >= 15 && picked.minute <30) || (picked.minute > 30 && picked.minute <45)){
        bookingModel.endTime = TimeOfDay(hour: picked.hour, minute: 30);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("時間自動以30分鐘為單位調整！"),));
      } else if (picked.minute >= 45 && picked.minute <= 59) {
        bookingModel.endTime = TimeOfDay(hour: picked.hour + 1, minute: 0);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("時間自動以30分鐘為單位調整！"),));
      }else{
        bookingModel.endTime = TimeOfDay(hour: picked.hour, minute: picked.minute);
      }
      setState(() {});
    }
  }


}
