import 'package:flutter/material.dart';
import '../constant/color.dart';

class CustomElevatedButton extends StatelessWidget {
  final String text;
  final Function onPressed;
  final Color color;
  const CustomElevatedButton({Key? key, required this.text, required this.onPressed, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30,vertical: 8),
        child: Text(text,style: const TextStyle(fontSize: 18),),
      ),
      style: ElevatedButton.styleFrom(
          // primary: AppColor.purple,
          primary: color,
          elevation: 0
      ),
      onPressed: (){
        onPressed();
      },
    );
  }
}



