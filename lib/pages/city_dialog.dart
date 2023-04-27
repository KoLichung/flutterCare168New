import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttercare168/constant/color.dart';
import 'package:fluttercare168/models/city.dart';
import 'package:intl/intl.dart';


class CityDialog extends StatefulWidget {
  bool? isNullSelection;

  CityDialog({this.isNullSelection});

  @override
  _CityDialogState createState() => new _CityDialogState();
}

class _CityDialogState extends State<CityDialog> {

  List<String> cityList = [];

  @override
  Widget build(BuildContext context) {
    if(widget.isNullSelection!=null && widget.isNullSelection == true){
      cityList.add('無');
      cityList.addAll(City.getCityNames());
    }else{
      cityList.addAll(City.getCityNames());
    }
    return AlertDialog(
      titlePadding: const EdgeInsets.all(0),
      title: Container(
        width: 300,
        padding: const EdgeInsets.all(10),
        color: AppColor.purple,
        child: const Text(
          '選擇縣市',
          style: TextStyle(color: Colors.white),
        ),
      ),
      contentPadding: const EdgeInsets.all(0),
      content: Container(
        height: 460,
        width: 380,
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 30),
        child: ListView.builder(
          itemCount: cityList.length,
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemBuilder: (BuildContext context,int i){
              return Column(
                children: [
                  TextButton(
                    child: Text(cityList[i],style: const TextStyle(color: Colors.black54,fontSize: 16),),
                    onPressed: (){
                      String selectedCity = cityList[i];
                      print(selectedCity);
                      Navigator.pop(context,selectedCity);
                    },
                  ),
                  const Divider()
                ],
              );
            })
      ),
      backgroundColor: AppColor.purple,
    );
  }

}
