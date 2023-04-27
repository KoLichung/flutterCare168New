import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttercare168/constant/color.dart';
import 'package:fluttercare168/models/city.dart';
import 'package:intl/intl.dart';


class CareTypeDialog extends StatefulWidget {
  bool? isNullSelection;

  CareTypeDialog({this.isNullSelection});

  @override
  _CareTypeDialogState createState() => new _CareTypeDialogState();
}


class _CareTypeDialogState extends State<CareTypeDialog> {

  @override
  Widget build(BuildContext context) {

    return AlertDialog(
      titlePadding: const EdgeInsets.all(0),
      title: Container(
        width: 300,
        padding: const EdgeInsets.all(10),
        color: AppColor.purple,
        child: const Text(
          '服務類型',
          style: TextStyle(color: Colors.white),
        ),
      ),
      contentPadding: const EdgeInsets.all(0),
      content: Container(
        height: 280,
        width: 380,
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 30),
        child: Column(
          children: [
            (widget.isNullSelection!=null && widget.isNullSelection == true)?
            Column(
              children: [
                TextButton(
                  child: const Text('無',style: const TextStyle(color: Colors.black54,fontSize: 16),),
                  onPressed: (){
                    String selectedType = '無';
                    print(selectedType);
                    Navigator.pop(context,selectedType);
                  },
                ),
                const Divider(),
              ],
            )
            :
            Container(),
            TextButton(
              child: const Text('居家照顧',style: const TextStyle(color: Colors.black54,fontSize: 16),),
              onPressed: (){
                String selectedType = '居家照顧';
                print(selectedType);
                Navigator.pop(context,selectedType);
              },
            ),
            const Divider(),
            TextButton(
              child: const Text('醫院看護',style: const TextStyle(color: Colors.black54,fontSize: 16),),
              onPressed: (){
                String selectedType = '醫院看護';
                print(selectedType);
                Navigator.pop(context,selectedType);
              },
            ),
            const Divider()
          ],
        )
      ),
      backgroundColor: AppColor.purple,
    );
  }


}
