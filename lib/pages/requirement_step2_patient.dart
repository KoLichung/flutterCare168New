import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:fluttercare168/constant/color.dart';
import 'package:fluttercare168/constant/custom_tag.dart';
import 'package:fluttercare168/models/body_condition.dart';
import 'package:fluttercare168/models/disease_condition.dart';
import 'package:fluttercare168/models/service.dart';
import 'package:fluttercare168/notifier_model/require_model.dart';
import 'package:fluttercare168/pages/requirement_step3_contact.dart';
import 'package:fluttercare168/constant/enum.dart';
import 'package:fluttercare168/widgets/custom_elevated_button.dart';
import 'package:provider/provider.dart';

class RequirementStep2Patient extends StatefulWidget {
  const RequirementStep2Patient({Key? key}) : super(key: key);

  @override
  _RequirementStep2PatientState createState() => _RequirementStep2PatientState();
}

class _RequirementStep2PatientState extends State<RequirementStep2Patient> {

  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController diseaseNoteController = TextEditingController();
  TextEditingController bodyNoteController = TextEditingController();

  //UI顯示所有checkBox選項名稱
  List<String> diseaseNameStrings = DiseaseCondition.getDiseaseNames();
  List<String> bodyIssueNameStrings = BodyCondition.getBodyConditionNames();
  List<Service> basicServices = Service.getBasicServices();
  List<Service> extraServices = Service.getIncreasePriceServices();

  @override
  void initState() {
    super.initState();
    var requireModel = context.read<RequireModel>();
    requireModel.patientName == null ? nameController.text ='' : nameController.text = requireModel.patientName! ;
    requireModel.patientAge == null ? ageController.text ='' : ageController.text = requireModel.patientAge! ;
    requireModel.patientWeight == null ? weightController.text ='' : weightController.text = requireModel.patientWeight! ;
    requireModel.patientDiseaseNote == null ? diseaseNoteController.text ='' : diseaseNoteController.text = requireModel.patientDiseaseNote! ;
    requireModel.patientBodyNote == null ? bodyNoteController.text ='' : bodyNoteController.text = requireModel.patientBodyNote! ;

    if(requireModel.checkDiseaseChoices.isEmpty){
      for(var i = 1; i <= diseaseNameStrings.length-1; i++){
        requireModel.checkDiseaseChoices.add(
            CheckDiseaseChoice(diseaseId: DiseaseCondition.getIdFromDiseaseName(diseaseNameStrings[i]),isChecked: false, diseaseName: diseaseNameStrings[i])
        );
      }
    }

    if(requireModel.checkBodyChoices.isEmpty){
      for(var i = 1; i <= bodyIssueNameStrings.length-1; i++){
        requireModel.checkBodyChoices.add(
            CheckBodyChoice(bodyConditionId: BodyCondition.getIdFromName(bodyIssueNameStrings[i]), isChecked: false, bodyCondition: bodyIssueNameStrings[i])
        );
      }
    }

    if(requireModel.checkBasicServiceChoices.isEmpty){
      for(var i = 1; i <= basicServices.length; i++){
        requireModel.checkBasicServiceChoices.add(
            CheckServiceChoice(serviceId: basicServices[i-1].id!,isChecked: false, service: basicServices[i-1])
        );
      }
    }

    if(requireModel.checkExtraServiceChoices.isEmpty){
      for(var i = 1; i <= extraServices.length; i++){
        requireModel.checkExtraServiceChoices.add(
            CheckServiceChoice(serviceId: extraServices[i-1].id!, isChecked: false, service: extraServices[i-1])
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var requireModel = context.read<RequireModel>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('填寫需求單'),
        actions: [
          TextButton(
              child: const Text('取消需求單',style: TextStyle(color: Colors.white),) ,
              onPressed: (){
                Navigator.of(context).popUntil((route) => route.isFirst);
                requireModel.clearRequireModelData();
              })
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTag.requirementStep2,
              const SizedBox(height: 20,),
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
                          requireModel.patientName = value;
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
                      groupValue: requireModel.patientGender,
                      onChanged: (Gender? value) {
                        setState(() {
                          requireModel.patientGender = value!;
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
                      groupValue: requireModel.patientGender,
                      onChanged: (Gender? value) {
                        setState(() {
                          requireModel.patientGender = value!;
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
                          requireModel.patientAge = value;
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
                          requireModel.patientWeight = value;

                          // for(var item in requireModel.checkExtraServiceChoices){
                          //   if(item.service!.name! == '體重超過 75 公斤' ){
                          //     if(requireModel.patientWeight != null && requireModel.patientWeight != ''){
                          //       if (int.parse(requireModel.patientWeight!) >= 75 && int.parse(requireModel.patientWeight!) < 90){
                          //         item.isChecked = true;
                          //       } else {
                          //         item.isChecked = false;
                          //       }
                          //     }
                          //
                          //   } else if(item.service!.name! == '體重超過 90 公斤'){
                          //     if(requireModel.patientWeight != null && requireModel.patientWeight != ''){
                          //       if (int.parse(requireModel.patientWeight!) >= 90 ){
                          //         item.isChecked = true;
                          //       } else {
                          //         item.isChecked = false;
                          //       }
                          //     }
                          //   }
                          // }

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
                      value: requireModel.checkDiseaseChoices.where((element) => element.isChecked==true).isEmpty,
                      onChanged: (bool? value){
                        setState(() {
                          if(value == true){
                            for(var item in requireModel.checkDiseaseChoices){
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
              showDiseaseCheckBoxes(requireModel.checkDiseaseChoices),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text('疾病狀況補充說明：'),
              ),
              TextField(
                maxLines: 4,
                controller: diseaseNoteController,
                onChanged: (value){
                  setState(() {
                    requireModel.patientDiseaseNote = value;
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
                      value: requireModel.checkBodyChoices.where((element) => element.isChecked == true).isEmpty,
                      onChanged: (bool? value){
                        if(value == true){
                          for(var item in requireModel.checkBodyChoices){
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
              showBodyIssueCheckBoxes(requireModel.checkBodyChoices),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text('身體狀況補充說明：'),
              ),
              TextField(
                maxLines: 4,
                controller: bodyNoteController,
                onChanged: (value){
                  setState(() {
                    requireModel.patientBodyNote = value;
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
              showBasicServiceCheckBoxes(requireModel.checkBasicServiceChoices),
              Row(children: [
                kSectionTitle('加價項目：'),
                const Text('(價格%數為服務者自訂)',style: TextStyle(color: AppColor.purple),),
              ],), //加價項目
              showExtraServiceCheckBoxes(requireModel.checkExtraServiceChoices),
              Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.fromLTRB(0,20,0,40),
                  child: CustomElevatedButton(
                      text: '下一頁繼續',
                      color: AppColor.purple,
                      onPressed: (){
                        if(requireModel.patientName == null || requireModel.patientAge == null || requireModel.patientWeight == null ){
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("請確定每個欄位都已填寫!"),
                              )
                          );
                        } else {
                          Navigator.push(context, MaterialPageRoute(builder: (context)=> RequirementStep3Contact()));
                        }
                      },
                  )
              ),
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
                              TextSpan(text: '\n${basicServiceChoice.service!.remark}', style: const TextStyle(color: Colors.grey, fontSize: 14)),
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

  showExtraServiceCheckBoxes(List<CheckServiceChoice> extraServiceChoices){
    List<Column> extraServiceList = [];
    extraServiceChoices.asMap().forEach((index, extraServiceChoice) {
      if(extraServiceChoice.service!.name=='急診室' || extraServiceChoice.service!.name =='傳染性疾病' ){
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
                        value: extraServiceChoice.isChecked,
                        onChanged: (bool? value) {
                          setState(() {
                            extraServiceChoice.isChecked = value;
                          });
                        },
                      ),
                    ),
                    Expanded(child: Text(extraServiceChoice.service!.name!))
                  ],
                ),
                const SizedBox(height: 6,)
              ],
            )
        );
      } else if (extraServiceChoice.service!.name=='體重超過 75 公斤'){
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
                        value: weightController.text ==''
                            ? extraServiceChoice.isChecked = false
                            : ((weightController.text !='' && int.parse(weightController.text) >=75 && int.parse(weightController.text) < 90)
                              ? extraServiceChoice.isChecked = true
                              : extraServiceChoice.isChecked = false) ,
                        onChanged: (bool? value) {
                          setState(() {
                            extraServiceChoice.isChecked = value;
                          });
                        },
                      ),
                    ),
                    Expanded(child: Text(extraServiceChoice.service!.name!))
                  ],
                ),
                const SizedBox(height: 6,)
              ],
            )
        );
      } else if (extraServiceChoice.service!.name=='體重超過 90 公斤'){
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
                        value: weightController.text ==''
                            ? extraServiceChoice.isChecked =false
                            : ((weightController.text !='' && int.parse(weightController.text) >=90 )
                              ? extraServiceChoice.isChecked =true
                              : extraServiceChoice.isChecked =false) ,
                        onChanged: (bool? value) {
                          setState(() {
                            extraServiceChoice.isChecked = value;
                          });
                        },
                      ),
                    ),
                    Expanded(child: Text(extraServiceChoice.service!.name!))
                  ],
                ),
                const SizedBox(height: 6,)
              ],
            )
        );
      }

    });
    return Column(children: extraServiceList);
  }

}

