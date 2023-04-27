import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttercare168/notifier_model/booking_model.dart';
import 'package:fluttercare168/notifier_model/require_model.dart';
import 'package:fluttercare168/notifier_model/user_model.dart';
import 'package:fluttercare168/widgets/custom_elevated_button.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constant/color.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:intl/intl.dart';
import 'package:fluttercare168/pages/requirement_step2_patient.dart';
import 'search_carer/page_weekday_dialog.dart';
import 'package:fluttercare168/constant/custom_tag.dart';
import 'package:fluttercare168/models/city.dart';
import 'package:fluttercare168/models/county.dart';
import 'package:fluttercare168/constant/format_converter.dart';
import 'package:fluttercare168/constant/enum.dart';
import 'package:shared_preferences/shared_preferences.dart';


class RequirementStep1Basic extends StatefulWidget {
  const RequirementStep1Basic({Key? key}) : super(key: key);

  @override
  _RequirementStep1BasicState createState() => _RequirementStep1BasicState();
}

class _RequirementStep1BasicState extends State<RequirementStep1Basic> {

  List<String> cityList = City.getCityNames();
  List<String> districtList = [];

  TextEditingController textController = TextEditingController();

  final DateRangePickerController _startDateController = DateRangePickerController();
  final DateRangePickerController _endDateController = DateRangePickerController();
  final DateRangePickerController _dateRangePickerController = DateRangePickerController();

  @override
  initState(){
    super.initState();
    var requireModel = context.read<RequireModel>();
    districtList = County.getCountyNames(requireModel.city.id!);
    Future.delayed(const Duration(milliseconds: 50), () {
      _showTeachingDialog();
    });
  }

  _showTeachingDialog()async{
    var userModel = context.read<UserModel>();
    final prefs = await SharedPreferences.getInstance();
    if(prefs.getBool('isNotShowTeachingDialog') == null ||  prefs.getBool('isNotShowTeachingDialog') == false){
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return StatefulBuilder(builder:(context, setState){
              return AlertDialog(
                // titlePadding: const EdgeInsets.symmetric(vertical:10),
                // title: GestureDetector(
                //   onTap: (){
                //     Navigator.pop(context);
                //   },
                //   child: Container(
                //     width: 20,
                //     height: 20,
                //     child: const Icon(Icons.clear, size: 18, color: Colors.white,),
                //     decoration: const BoxDecoration(
                //     shape: BoxShape.circle,
                //     color:  Colors.grey),
                //     ),
                // ),
                contentPadding: EdgeInsets.zero,
                content:Stack(
                  children: [
                    GestureDetector(
                      onTap: ()async{
                        Uri url = Uri.parse('https://care168.com.tw/assistance_detail?blogpost=12');
                        // Uri url = Uri.parse(ServerApi.getCarerUrl(userModel.user!.id!).toString());
                        if (!await launchUrl(url)) {
                          throw 'Could not launch $url';
                        }
                      },
                      child: Container(
                        width: 290,
                        height: 290,
                        decoration: const BoxDecoration(
                            image: DecorationImage(
                              image:AssetImage('images/info.png'),
                            )
                        ),
                      ),
                    ),
                    Positioned(
                      top: 5,
                      right: 5,
                      child: GestureDetector(
                        onTap: (){
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 20,
                          height: 20,
                          child: const Icon(Icons.clear, size: 18, color: Colors.white,),
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color:  Colors.grey),
                        ),
                      ),
                    ),
                  ],
                ),
                actionsAlignment: MainAxisAlignment.center,
                actionsPadding: EdgeInsets.zero,
                actions: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Checkbox(
                        checkColor:Colors.white,
                        activeColor: AppColor.purple,
                        value: userModel.isNotShowTeachingDialogAgain,
                        onChanged: (bool? value)async{
                          setState(() {
                            userModel.isNotShowTeachingDialogAgain = value!;
                          });
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool('isNotShowTeachingDialog', userModel.isNotShowTeachingDialogAgain);
                        },
                      ),
                      const Text('下次不再顯示'),
                    ],
                  ),
                ],
              );
            });
          });
    }
  }

  @override

  Widget build(BuildContext context) {
    var requireModel = context.read<RequireModel>();
    return WillPopScope(onWillPop: () async{
          print('requirement back pressed');
          var requireModel = context.read<RequireModel>();
          requireModel.clearRequireModelData();
          return true;
        },
        child: Scaffold(
          appBar: AppBar(title: const Text('填寫需求單'),),
          body: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CustomTag.requirementStep1,
                      const SizedBox(height: 30,),
                      CupertinoSegmentedControl<int>(
                        padding: const EdgeInsets.all(2),
                        groupValue: requireModel.careTypeGroupValue,
                        selectedColor: AppColor.purple,
                        unselectedColor:  CupertinoColors.white,
                        borderColor: AppColor.purple,
                        pressedColor: const Color(0xffEDDAFF),
                        children: {
                          0: requireModel.careTypeGroupValue == 0
                              ? Container(
                            padding:const EdgeInsets.all(8),
                            child: const Text('居家照顧',style: TextStyle(fontSize: 22, color: Colors.white),),
                          )
                              : Container(
                            padding:const EdgeInsets.all(8),
                            child: const Text('居家照顧',style: TextStyle(fontSize: 22, color: AppColor.purple),),
                          ),
                          1: requireModel.careTypeGroupValue == 1
                              ? Container(
                            padding:const EdgeInsets.all(8),
                            child: const Text('醫院看護',style: TextStyle(fontSize: 22, color: Colors.white),),
                          )
                              : Container(
                            padding:const EdgeInsets.all(8),
                            child: const Text('醫院看護',style: TextStyle(fontSize: 22, color: AppColor.purple),),
                          ),
                        },
                        onValueChanged: (careTypeGroupValue){
                          setState(() {
                            requireModel.careTypeGroupValue = careTypeGroupValue;
                          });
                        },
                      ),
                      const SizedBox(height: 15,),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColor.purple,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(4),),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: IntrinsicHeight(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('縣市：'),
                                    getCity(),
                                    const VerticalDivider(
                                      thickness: 2,
                                      indent: 12,
                                      endIndent: 12,
                                      color: AppColor.purple,
                                    ),
                                    const Text('區域：'),
                                    getDistrict(),
                                  ],
                                ),
                              ),
                            ), //縣市區域
                            const Divider(color: AppColor.purple, thickness: 2, height: 0,),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0),
                              child: (requireModel.careTypeGroupValue == 0)?
                              Row(
                                children: [
                                  const Text('路名：'),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 250,
                                          margin: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                                          child: TextField(
                                            controller: textController,
                                            decoration: InputDecoration(
                                                contentPadding: const EdgeInsets.symmetric(vertical: 0,horizontal: 5),
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(5.0),
                                                ),
                                                filled: true,
                                                hintStyle: TextStyle(color: Colors.grey[800]),
                                                hintText: "請填寫路名",
                                                fillColor: Colors.white70),
                                          ),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.fromLTRB(5, 0, 5, 5),
                                          child: const Text('※為確保您的隱私，此欄位只需填寫”路名”', style: TextStyle(fontSize: 13)),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              )
                                  :
                              Row(
                                children: [
                                  const Text('醫院名：'),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 250,
                                          margin: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                                          child: TextField(
                                            controller: textController,
                                            decoration: InputDecoration(
                                                contentPadding: const EdgeInsets.symmetric(vertical: 0,horizontal: 5),
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(5.0),
                                                ),
                                                filled: true,
                                                hintStyle: TextStyle(color: Colors.grey[800]),
                                                hintText: "請填寫醫院名",
                                                fillColor: Colors.white70),
                                          ),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.fromLTRB(5, 0, 5, 5),
                                          child: const Text('※為確保您的隱私，請勿在此填寫病房床號！', style: TextStyle(fontSize: 13)),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(color: AppColor.purple, thickness: 2, height: 0,),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Row(
                                children: [
                                  // const Text('時間類型：'),
                                  Radio<TimeType>(
                                    value: TimeType.continuous,
                                    groupValue: requireModel.timeType,
                                    onChanged: (TimeType? value) {
                                      setState(() {
                                        requireModel.timeType = value!;
                                      });
                                    },
                                  ),
                                  const Text('連續時間'),
                                  Radio<TimeType>(
                                    value: TimeType.weekly,
                                    groupValue: requireModel.timeType,
                                    onChanged: (TimeType? value) {
                                      setState(() {
                                        requireModel.timeType = value!;
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
                            ),
                            const Divider(color: AppColor.purple, thickness: 2, height: 0,),
                            requireModel.timeType == TimeType.continuous ? continuousTime() : weeklyTime()
                          ],
                        ),
                      ), //表格內容
                      const SizedBox(height: 20,),
                    ],),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 50),
                    child: CustomElevatedButton(
                      color: AppColor.purple,
                      text: '下一頁繼續',
                      onPressed: (){
                        DateTime _theStartDate = DateUtils.dateOnly(requireModel.startDate);
                        DateTime _theEndDate = DateUtils.dateOnly(requireModel.endDate);

                        if(textController.text!='' ){
                          final alphanumeric = RegExp(r'^.*[0-9].*');
                          if(alphanumeric.hasMatch(textController.text!)){
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("請勿直接填寫地址、病房床號、阿拉伯數字，可利用聊聊告知接案服務者。")));
                          }else{
                            if(requireModel.careTypeGroupValue == 0){
                              // 居家照顧
                              requireModel.roadName = textController.text;
                            }else{
                              // 醫院看護
                              requireModel.hospitalName = textController.text;
                            }

                            // if(requireModel.startDate.day == requireModel.endDate.day && timeToDouble(requireModel.startTime) > timeToDouble(requireModel.endTime) ){
                            if(_theStartDate.isAtSameMomentAs(_theEndDate) && timeToDouble(requireModel.startTime) >= timeToDouble(requireModel.endTime) ){
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("開始時間要小於結束時間")));
                            }else{
                              Navigator.push(context, MaterialPageRoute(builder: (content)=> const RequirementStep2Patient()));
                            }
                          }
                        }else{
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("請填寫路名或醫院名。")));
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          )
      )
    );
  }

  double timeToDouble(TimeOfDay myTime) => myTime.hour + myTime.minute/60.0;

  //連續時間顯示
  continuousTime(){
    var requireModel = context.read<RequireModel>();
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
                    child: Text(DateFormat('MM / dd').format(requireModel.startDate)),
                  )
              ),
              const SizedBox(width: 10,),
              const Text('時間：'),
              GestureDetector(
                child: Text(requireModel.startTime.to24hours()),
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
                    child: Text(DateFormat('MM / dd').format(requireModel.endDate)),
                  )
              ),
              const SizedBox(width: 10,),
              const Text('時間：'),
              GestureDetector(
                child: Text(requireModel.endTime.to24hours()),
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
    var requireModel = context.read<RequireModel>();
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
            onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
              // setState(() {
              //   if (args.value is DateTime) {
              //     requireModel.startDate = args.value;
              //   }
              // });
            },
            showActionButtons: true,
            cancelText: '取消',
            confirmText: '確定',
            onSubmit: (Object? value) {
              DateTime startDate = value as DateTime;
              if(startDate.isAfter(requireModel.endDate) && startDate.day != requireModel.endDate.day ){
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("開始日期要早於結束日期！")));
              }else{
                setState(() {
                  requireModel.startDate = startDate;
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
    var requireModel = context.read<RequireModel>();
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
            minDate: DateTime.now(),
            maxDate: DateTime.now().add(const Duration(days: 60)),
            onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
              // setState(() {
              //   if (args.value is DateTime) {
              //     DateTime endDate = args.value as DateTime;
              //     if(endDate.isBefore(requireModel.startDate) ){
              //       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("結束日期要早於開始日期！")));
              //     }else{
              //       requireModel.endDate = args.value;
              //     }
              //   }
              // });
            },
            showActionButtons: true,
            cancelText: '取消',
            confirmText: '確定',
            onSubmit: (Object? value) {
              DateTime endDate = value as DateTime;
              if(endDate.isBefore(requireModel.startDate) && endDate.day != requireModel.startDate.day ){
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("結束日期要晚於開始日期！")));
              }else{
                setState(() {
                  requireModel.endDate = endDate;
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

  weeklyTime(){
    var requireModel = context.read<RequireModel>();
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
                          return getDateRangPicker();
                        });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Text('${DateFormat('MM / dd').format(requireModel.startDate)}  -  ${DateFormat('MM / dd').format(requireModel.endDate)}'),
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
                      return PageWeekdayDialog(modelName: 'require_model',);
                    });
                setState(() {});
              },),
            ),//週間星期
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
            child: Text('開始時間：'+ requireModel.startTime.to24hours()),
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
            child: Text('結束時間：'+ requireModel.endTime.to24hours()),
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
    var requireModel = context.read<RequireModel>();
    for(var day in requireModel.checkWeekDays){
      if(day.isChecked){
        dayStrings.add(day.day);
      }
    }
    return dayStrings.join(',');
  }

  getDateRangPicker(){
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
            monthViewSettings: const DateRangePickerMonthViewSettings(firstDayOfWeek: 7,),
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
    var requireModel = context.read<RequireModel>();
    setState(() {
      requireModel.startDate = args.value.startDate;
      requireModel.endDate = args.value.endDate ?? args.value.startDate;
    });
  }

  DropdownButtonHideUnderline getCity(){
    var requireModel = context.read<RequireModel>();
    return DropdownButtonHideUnderline(
        child: DropdownButton<String>(
            itemHeight: 50,
            value: requireModel.city.name,
            onChanged:(String? newValue){
              setState(() {
                requireModel.city = City.getCityFromName(newValue!);
                districtList = County.getCountyNames(requireModel.city.id!);
                requireModel.district= County.getCountyFromName(requireModel.city.id!, districtList.first);
              });
            },
            items: cityList.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList())
    );
  }

  DropdownButtonHideUnderline getDistrict(){
    var requireModel = context.read<RequireModel>();
    return DropdownButtonHideUnderline(
        child: DropdownButton<String>(
            itemHeight: 50,
            value: requireModel.district.name!,
            onChanged:(String? newValue){
              setState(() {
                // print(County.getCountyFromName(requireModel.city.id!, newValue!).name);
                // print(County.getCountyFromName(requireModel.city.id!, newValue).id);
                requireModel.district = County.getCountyFromName(requireModel.city.id!, newValue!);
              });
            },
            items: districtList.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList())
    );
  }

  Future<void> _pickStartTime(BuildContext context) async {
    var requireModel = context.read<RequireModel>();
    final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: requireModel.startTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,);
      },);
    if (picked != null && picked != requireModel.startTime) {

      if(picked.minute > 0 && picked.minute < 15){
        requireModel.startTime = TimeOfDay(hour: picked.hour, minute: 0);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("時間自動以30分鐘為單位調整！"),));
      } else if ((picked.minute >= 15 && picked.minute <30) || (picked.minute > 30 && picked.minute <45)){
        requireModel.startTime = TimeOfDay(hour: picked.hour, minute: 30);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("時間自動以30分鐘為單位調整！"),));
      } else if (picked.minute >= 45 && picked.minute <= 59) {
        requireModel.startTime = TimeOfDay(hour: picked.hour + 1, minute: 0);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("時間自動以30分鐘為單位調整！"),));
      }else{
        requireModel.startTime = TimeOfDay(hour: picked.hour, minute: picked.minute);
      }

      setState(() {});
    }
  }

  Future<void> _pickEndTime(BuildContext context) async {
    var requireModel = context.read<RequireModel>();

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: requireModel.endTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null && picked != requireModel.endTime) {

      if(picked.minute > 0 && picked.minute < 15){
        requireModel.endTime = TimeOfDay(hour: picked.hour, minute: 0);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("時間自動以30分鐘為單位調整！"),));
      } else if ((picked.minute >= 15 && picked.minute <30) || (picked.minute > 30 && picked.minute <45)){
        requireModel.endTime = TimeOfDay(hour: picked.hour, minute: 30);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("時間自動以30分鐘為單位調整！"),));
      } else if (picked.minute >= 45 && picked.minute <= 59) {
        requireModel.endTime = TimeOfDay(hour: picked.hour + 1, minute: 0);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("時間自動以30分鐘為單位調整！"),));
      }else{
        requireModel.endTime = TimeOfDay(hour: picked.hour, minute: picked.minute);
      }

      setState(() {});
    }
  }

}
