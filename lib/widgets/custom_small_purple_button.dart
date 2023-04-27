import 'package:flutter/material.dart';
import 'package:fluttercare168/constant/color.dart';


class CustomSmallPurpleButton extends StatelessWidget {
  final String text;
  final Function onPressed;
  const CustomSmallPurpleButton({Key? key, required this.text, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: Text(text),
      style: ElevatedButton.styleFrom(
          elevation: 0,
          primary: AppColor.purple
      ),
      onPressed: (){
        onPressed();
      },
    );
  }
}



