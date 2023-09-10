import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttercare168/constant/color.dart';
import 'package:fluttercare168/constant/custom_tag.dart';
import 'package:fluttercare168/constant/enum.dart';
import 'package:fluttercare168/models/body_condition.dart';
import 'package:fluttercare168/models/disease_condition.dart';
import 'package:fluttercare168/models/service.dart';
import 'package:fluttercare168/notifier_model/booking_model.dart';
import 'package:fluttercare168/notifier_model/user_model.dart';
import 'package:fluttercare168/pages/search_carer/booking_step1_edit_time.dart';
import 'package:fluttercare168/pages/search_carer/booking_step2_location.dart';
import 'package:fluttercare168/widgets/custom_elevated_button.dart';
import 'package:fluttercare168/widgets/custom_icon_text_button.dart';
import 'package:provider/provider.dart';
import 'package:fluttercare168/constant/format_converter.dart';
import 'package:flutter/services.dart';

import '../../models/city.dart';

class BookingStep1Detail extends StatefulWidget {

  CareType careType;
  City city;

  BookingStep1Detail({Key? key, required this.careType, required this.city}) : super(key: key);

  @override
  _BookingStep1DetailState createState() => _BookingStep1DetailState();
}

class _BookingStep1DetailState extends State<BookingStep1Detail> {

  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController diseaseNoteController = TextEditingController();
  TextEditingController bodyNoteController = TextEditingController();

  //UI顯示所有checkBox選項名稱
  List<String> diseaseNameStrings = DiseaseCondition.getDiseaseNames();
  List<String> bodyIssueNameStrings = BodyCondition.getBodyConditionNames();

  @override
  void initState() {
    super.initState();
    var bookingModel = context.read<BookingModel>();
    var userModel = context.read<UserModel>();
    bookingModel.careType = widget.careType;
    bookingModel.city = widget.city;

    bookingModel.timeType == null ? bookingModel.timeType = userModel.timeType : bookingModel.timeType = bookingModel.timeType;
    bookingModel.startDate == null ? bookingModel.startDate = userModel.startDate : bookingModel.startDate = bookingModel.startDate;
    bookingModel.endDate == null ? bookingModel.endDate = bookingModel.startDate!.add(Duration(days: 30)) : bookingModel.endDate = bookingModel.endDate;
    bookingModel.startTime == null ? bookingModel.startTime = userModel.startTime : bookingModel.startTime = bookingModel.startTime;
    bookingModel.endTime == null ? bookingModel.endTime = userModel.endTime : bookingModel.endTime = bookingModel.endTime;

    bookingModel.patientName == null ? nameController.text ='' : nameController.text = bookingModel.patientName! ;
    bookingModel.patientAge == null ? ageController.text ='' : ageController.text = bookingModel.patientAge! ;
    bookingModel.patientWeight == null ? weightController.text ='' : weightController.text = bookingModel.patientWeight! ;
    bookingModel.patientDiseaseNote == null ? diseaseNoteController.text ='' : diseaseNoteController.text = bookingModel.patientDiseaseNote! ;
    bookingModel.patientBodyNote == null ? bodyNoteController.text ='' : bodyNoteController.text = bookingModel.patientBodyNote! ;

    if(bookingModel.checkDiseaseChoices.isEmpty){
      for(var i = 1; i <= diseaseNameStrings.length-1; i++){
        bookingModel.checkDiseaseChoices.add(
            CheckDiseaseChoice(diseaseId: DiseaseCondition.getIdFromDiseaseName(diseaseNameStrings[i]), isChecked: false, diseaseName: diseaseNameStrings[i])
        );
      }
    }

    if(bookingModel.checkBodyChoices.isEmpty){
      for(var i = 1; i <= bodyIssueNameStrings.length-1; i++){
        bookingModel.checkBodyChoices.add(
            CheckBodyChoice(bodyConditionId: BodyCondition.getIdFromName(bodyIssueNameStrings[i]), isChecked: false, bodyCondition: bodyIssueNameStrings[i])
        );
      }
    }

    if(bookingModel.checkBasicServiceChoices.isEmpty){
      for(var service in Service.getAllServices()){
        if(service.id! >= 1 && service.id! <= 4 ){
          print(bookingModel.carerServices);
          if( bookingModel.carerServices.map((item) => item.id).toList().contains(service.id) ){
            Service theService = bookingModel.carerServices.where((item) => item.id == service.id).first;
            bookingModel.checkExtraServiceChoices.add(
                CheckServiceChoice(serviceId: service.id, isChecked: false, service: theService)
            );
          }else {
            bookingModel.checkExtraServiceChoices.add(
                CheckServiceChoice(serviceId: service.id, isChecked: false, service: service)
            );
          }
        } else {
          bookingModel.checkBasicServiceChoices.add(
              CheckServiceChoice(serviceId: service.id, isChecked: false, service: service)
          );
        }
      }
    }

  }

  @override
  Widget build(BuildContext context) {
    var bookingModel = context.read<BookingModel>();
    var userModel = context.read<UserModel>();

    print('here !!!');

    return Scaffold(
      appBar: AppBar(
        title: const Text('填寫訂單'),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
              child: const Text('取消預定',style: TextStyle(color: Colors.white),) ,
              onPressed: (){
                Navigator.of(context).popUntil((route) => route.isFirst);
                bookingModel.clearBookingModelData();
              }
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTag.bookingStep1,
              const Center(child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text('【 步驟 1 填寫被照顧者資訊 】', style: TextStyle(color: AppColor.purple, fontWeight: FontWeight.bold),),
              )),
              Row(
                children: [
                  const Text('需求類型：', style: TextStyle(fontWeight: FontWeight.bold),),
                  bookingModel.careType == CareType.homeCare
                      ? const Text( '居家照顧', style: TextStyle(fontWeight: FontWeight.bold),)
                      : const Text( '醫院看護', style: TextStyle(fontWeight: FontWeight.bold),)
                ],
              ),
              Consumer<BookingModel>(builder: (context, bookingModel, child) =>
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                     // const Text('時間類型：', style: TextStyle(fontWeight: FontWeight.bold),),
                     bookingModel.timeType == TimeType.continuous
                         ? Text('連續時間 \n${bookingModel.startDate.toString().substring(0,10)}(${bookingModel.startTime!.to24hours()}) ~ \n${bookingModel.endDate.toString().substring(0,10)}(${bookingModel.endTime!.to24hours()})')
                         : Text('指定時段 \n${bookingModel.startDate.toString().substring(0,10)} ~ ${bookingModel.endDate.toString().substring(0,10)}\n${getWeekDayStrings()}\n${bookingModel.startTime!.to24hours()}~${bookingModel.endTime!.to24hours()}'),
                    ],
                  )
              ),
              CustomIconTextButton(
                  iconData: Icons.edit,
                  text: '修改時間',
                  onPressed: (){
                    Navigator.push(context,MaterialPageRoute(builder: (context)=> const BookingStep1EditTime()));
                  }),
              const Divider(thickness: 0.5,color: Colors.grey,),
              kSectionTitle('被照顧者資料:'),
              Row(
                children: [
                  const Text('姓名：'),
                  Container(
                    width: 120,
                    height: 40,
                    margin: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                    child: TextField(
                      controller: nameController,
                      onChanged: (value){
                        setState(() {
                          bookingModel.patientName = value;
                        });
                      },
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 0.0,horizontal: 10),
                        border: OutlineInputBorder(
                            borderRadius:BorderRadius.all(Radius.circular(3),),
                            borderSide: BorderSide.none
                        ),
                        filled: true,
                        fillColor: Color(0xffE5E5E5),
                      ),
                    ),
                  ),
                ],),
              Row(
                children: [
                  const Text('性別：'),
                  SizedBox(
                    width: 30,
                    child: Radio<Gender>(
                      activeColor: Colors.black54,
                      value: Gender.male,
                      groupValue: bookingModel.patientGender,
                      onChanged: (Gender? value) {
                        setState(() {
                          bookingModel.patientGender = value!;
                        });
                      },
                    ),
                  ),
                  const Text('男'),
                  const SizedBox(width: 10,),
                  SizedBox(
                    width: 30,
                    child: Radio<Gender>(
                      activeColor: Colors.black54,
                      value: Gender.female,
                      groupValue: bookingModel.patientGender,
                      onChanged: (Gender? value) {
                        setState(() {
                          bookingModel.patientGender = value!;
                        });
                      },
                    ),
                  ),
                  const Text('女')
                ],
              ),
              Row(
                children: [
                  const Text('年齡：'),
                  Container(
                    width: 120,
                    height: 40,
                    margin: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                    child: TextField(
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                      controller: ageController,
                      onChanged: (value){
                        setState(() {
                          bookingModel.patientAge = value;
                        });
                      },
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 0.0,horizontal: 10),
                        border: OutlineInputBorder(
                            borderRadius:BorderRadius.all(Radius.circular(3),),
                            borderSide: BorderSide.none
                        ),
                        filled: true,
                        fillColor: Color(0xffE5E5E5),
                      ),
                    ),
                  ),
                  const Text('歲'),
                ],),
              Row(
                children: [
                  const Text('體重：'),
                  Container(
                    width: 120,
                    height: 40,
                    margin: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                    child: TextField(
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                      controller: weightController,
                      onChanged: (value){
                        setState(() {
                          bookingModel.patientWeight = value;
                        });
                      },
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 0.0,horizontal: 10),
                        border: OutlineInputBorder(
                            borderRadius:BorderRadius.all(Radius.circular(3),),
                            borderSide: BorderSide.none
                        ),
                        filled: true,
                        fillColor: Color(0xffE5E5E5),
                      ),
                    ),
                  ),
                  const Text('公斤'),
                ],),
              const Divider(thickness: 0.5,color: Colors.grey,),
              kSectionTitle('疾病狀況：'),
              Row(
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: Checkbox(
                      checkColor: Colors.white,
                      activeColor: AppColor.purple,
                      value: bookingModel.checkDiseaseChoices.where((element) => element.isChecked==true).isEmpty,
                      onChanged: (bool? value){
                        setState(() {
                          if(value == true){
                            for(var item in bookingModel.checkDiseaseChoices){
                              item.isChecked == false;
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("請直接勾選被照顧者的疾病！")));
                          }
                        });
                      },
                    ),
                  ),
                  const Text('無')
                ],
              ),
              showDiseaseCheckBoxes(bookingModel.checkDiseaseChoices),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text('疾病狀況補充說明：'),
              ),
              TextField(
                maxLines: 4,
                controller: diseaseNoteController,
                onChanged: (value){
                  setState(() {
                    bookingModel.patientDiseaseNote = value;
                  });
                },
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(10),
                  filled: true,
                  fillColor: Color(0xffE5E5E5),
                  border: OutlineInputBorder(
                      borderRadius:BorderRadius.all(Radius.circular(4),),
                      borderSide: BorderSide.none
                  ),
                  hintText: '例：傳染性疾病名稱、病情狀況... ',
                  hintStyle: TextStyle(color: Colors.grey),
                  // border: InputBorder.none,
                ),
              ),
              const Divider(height: 40,thickness: 0.5,color: Colors.grey,),
              kSectionTitle('身體狀況：'),
              Row(
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: Checkbox(
                      checkColor: Colors.white,
                      activeColor: AppColor.purple,
                      // where是過濾，過濾出來的是一個Iterable，isEmpty代表Iterable的length為零
                      // 過濾完檢查 list 是否為 empty
                      // 所以整條解釋起來就是。list裡isChecked為true的個數為零時，則true。
                      value: bookingModel.checkBodyChoices.where((element) => element.isChecked == true).isEmpty,
                      onChanged: (bool? value){
                        if(value == true){
                          for(var item in bookingModel.checkBodyChoices){
                            item.isChecked = false;
                          }
                        }else{
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("請直接勾選被照顧者的身體狀況！")));
                        }
                        setState(() {
                          // requireModel.isAnyBodyIssues = value!;
                        });
                      },
                    ),
                  ),
                  const Text('無')
                ],
              ),
              showBodyIssueCheckBoxes(bookingModel.checkBodyChoices),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text('身體狀況補充說明：'),
              ),
              TextField(
                maxLines: 4,
                controller: bodyNoteController,
                onChanged: (value){
                  setState(() {
                    bookingModel.patientBodyNote = value;
                  });
                },
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(10),
                  filled: true,
                  fillColor: Color(0xffE5E5E5),
                  border: OutlineInputBorder(
                      borderRadius:BorderRadius.all(Radius.circular(4),),
                      borderSide: BorderSide.none
                  ),
                  hintText: '身體狀況補充說明...',
                  hintStyle: TextStyle(color: Colors.grey),
                  // border: InputBorder.none,
                ),
              ),
              const Divider(height: 40,thickness: 0.5,color: Colors.grey,),
              kSectionTitle('需求服務項目：'),
              showBasicServiceCheckBoxes(bookingModel.checkBasicServiceChoices),
              kSectionTitle('服務加價項目：\n(價格%數為服務者自訂)'),
              showExtraServiceCheckBoxes(bookingModel.checkExtraServiceChoices),
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.fromLTRB(0,20,0,40),
                  child: CustomElevatedButton(
                      text: '下一頁繼續',
                      color: AppColor.purple,
                      onPressed: (){
                        if(bookingModel.patientName == null || bookingModel.patientAge == null || bookingModel.patientWeight == null ){
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("請確定每個欄位都已填寫!"),
                              )
                          );
                        } else {
                          Navigator.push(context, MaterialPageRoute(builder: (context)=> BookingStep2Location()));
                        }
                      }
                  )
              ) //下一頁 button
            ],
          ),
        ),
      ),
    );
  }

  kSectionTitle(String title){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold),),
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

  showDiseaseCheckBoxes(List<CheckDiseaseChoice> diseaseChoices){
    List<Wrap> diseaseList = [];
    diseaseChoices.asMap().forEach((index, diseaseChoice) {
      diseaseList.add(Wrap(
        spacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: Checkbox(
              checkColor: Colors.white,
              activeColor: AppColor.purple,
              value: diseaseChoice.isChecked,
              onChanged: (bool? value) {
                setState(() {
                  diseaseChoice.isChecked = value;
                });
              },
            ),
          ),
          Text(diseaseChoice.diseaseName!),
        ],
      ));
    });
    return Wrap(children: diseaseList,);
  }

  showBodyIssueCheckBoxes(List<CheckBodyChoice> bodyChoices){
    List<Wrap> bodyIssueList = [];
    bodyChoices.asMap().forEach((index, bodyChoice) {
      bodyIssueList.add(Wrap(
        spacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: Checkbox(
              checkColor: Colors.white,
              activeColor: AppColor.purple,
              value: bodyChoice.isChecked,
              onChanged: (bool? value) {
                setState(() {
                  bodyChoice.isChecked = value;
                });
              },
            ),
          ),
          Text(bodyChoice.bodyCondition!),
        ],
      ));
    });
    return Wrap(children: bodyIssueList,);
  }

  showBasicServiceCheckBoxes(List<CheckServiceChoice> basicServiceChoices){
    List<Column> basicServiceList = [];
    basicServiceChoices.asMap().forEach((index, basicServiceChoice) {
      basicServiceList.add(
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 40,
                    height: 26,
                    child: Checkbox(
                      checkColor: Colors.white,
                      activeColor: AppColor.purple,
                      value: basicServiceChoice.isChecked,
                      onChanged: (bool? value) {
                        setState(() {
                          basicServiceChoice.isChecked = value;
                        });
                      },
                    ),
                  ),
                  basicServiceChoice.service!.remark == null
                      ? Expanded(child: Text(basicServiceChoice.service!.name!))
                      : Expanded(
                    child: RichText(
                      text: TextSpan(
                        text: basicServiceChoice.service!.name,
                        style: const TextStyle(fontSize: 16, color: Colors.black),
                        children: <TextSpan>[
                          TextSpan(text: '\n'+_checkToChangeLine(basicServiceChoice.service!.remark!), style: const TextStyle(color: Colors.grey, fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6,)
            ],
          )
      );
    });
    return Column(children: basicServiceList);
  }

  String _checkToChangeLine(String text){
    return text.replaceAll('※', '\n※');
  }

  showExtraServiceCheckBoxes(List<CheckServiceChoice> extraServiceChoices){
    List<Column> extraServiceList = [];
    extraServiceChoices.asMap().forEach((index, extraServiceChoice) {

      if(extraServiceChoice.service!.id != 3 && extraServiceChoice.service!.id != 4){
        extraServiceList.add(
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 40,
                      height: 26,
                      child: Checkbox(
                        checkColor: Colors.white,
                        activeColor: AppColor.purple,
                        // value: extraServiceChoice.isChecked,
                        value: extraServiceChoice.isChecked,
                        onChanged: (bool? value) {
                          setState(() {
                            extraServiceChoice.isChecked = value;
                          });
                        },
                      ),
                    ),
                    Text('${extraServiceChoice.service!.name!}，每小時加收'),
                    Text('${extraServiceChoice.service!.increasePercent!}%',style: TextStyle(color: Colors.red),),
                  ],
                ),
                const SizedBox(height: 6,)
              ],
            )
        );
      }else{
        if(extraServiceChoice.service!.id == 3){
          extraServiceList.add(
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 40,
                        height: 26,
                        child: Checkbox(
                          checkColor: Colors.white,
                          activeColor: AppColor.purple,
                          // value: extraServiceChoice.isChecked,
                          value: weightController.text == ''
                              ? extraServiceChoice.isChecked = false
                              :  (weightController.text != '' && int.parse(weightController.text) >= 75 && int.parse(weightController.text)<90)
                              ? extraServiceChoice.isChecked = true
                              : extraServiceChoice.isChecked = false,
                          onChanged: (bool? value) {
                            setState(() {
                              extraServiceChoice.isChecked = value;
                            });
                          },
                        ),
                      ),
                      Text('${extraServiceChoice.service!.name!}，每小時加收'),
                      Text('${extraServiceChoice.service!.increasePercent!}%',style: TextStyle(color: Colors.red),),
                    ],
                  ),
                  const SizedBox(height: 6,)
                ],
              )
          );
        }else{
          extraServiceList.add(
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 40,
                        height: 26,
                        child: Checkbox(
                          checkColor: Colors.white,
                          activeColor: AppColor.purple,
                          // value: extraServiceChoice.isChecked,
                          value: weightController.text == ''
                              ? extraServiceChoice.isChecked = false
                              :  (weightController.text != '' && int.parse(weightController.text) >= 90)
                              ? extraServiceChoice.isChecked = true
                              : extraServiceChoice.isChecked = false,
                          onChanged: (bool? value) {
                            setState(() {
                              extraServiceChoice.isChecked = value;
                            });
                          },
                        ),
                      ),
                      Text('${extraServiceChoice.service!.name!}，每小時加收'),
                      Text('${extraServiceChoice.service!.increasePercent!}%',style: TextStyle(color: Colors.red),),
                    ],
                  ),
                  const SizedBox(height: 6,)
                ],
              )
          );
        }

      }


      // if(extraServiceChoice.service!.name == '急診室患者' || extraServiceChoice.service!.name =='傳染性疾病'){
      //   extraServiceList.add(
      //       Column(
      //         crossAxisAlignment: CrossAxisAlignment.center,
      //         children: [
      //           Row(
      //             crossAxisAlignment: CrossAxisAlignment.start,
      //             children: [
      //               SizedBox(
      //                 width: 40,
      //                 height: 26,
      //                 child: Checkbox(
      //                   checkColor: Colors.white,
      //                   activeColor: AppColor.purple,
      //                   value: extraServiceChoice.isChecked,
      //                   onChanged: (bool? value) {
      //                     setState(() {
      //                       extraServiceChoice.isChecked = value;
      //                     });
      //                   },
      //                 ),
      //               ),
      //               Text('${extraServiceChoice.service!.name!}，每小時加收'),
      //               Text('${extraServiceChoice.service!.increasePercent!}%',style: TextStyle(color: Colors.red),),
      //             ],
      //           ),
      //           const SizedBox(height: 6,)
      //         ],
      //       )
      //   );
      // } else if (extraServiceChoice.service!.name == '體重超過 90 公斤'){
      //   extraServiceList.add(
      //       Column(
      //         crossAxisAlignment: CrossAxisAlignment.center,
      //         children: [
      //           Row(
      //             crossAxisAlignment: CrossAxisAlignment.start,
      //             children: [
      //               SizedBox(
      //                 width: 40,
      //                 height: 26,
      //                 child: Checkbox(
      //                   checkColor: Colors.white,
      //                   activeColor: AppColor.purple,
      //                   // value: extraServiceChoice.isChecked,
      //                   value: weightController.text == ''
      //                       ? extraServiceChoice.isChecked = false
      //                       :  (weightController.text != '' && int.parse(weightController.text) >= 90)
      //                         ? extraServiceChoice.isChecked = true
      //                         : extraServiceChoice.isChecked = false,
      //
      //                   onChanged: (bool? value) {
      //                     setState(() {
      //                       extraServiceChoice.isChecked = value;
      //                     });
      //                   },
      //                 ),
      //               ),
      //               Text('${extraServiceChoice.service!.name!}，每小時加收'),
      //               Text('${extraServiceChoice.service!.increasePercent!}%',style: TextStyle(color: Colors.red),),
      //             ],
      //           ),
      //           const SizedBox(height: 6,)
      //         ],
      //       )
      //   );
      // }

    });
    return Column(children: extraServiceList);
  }

}


