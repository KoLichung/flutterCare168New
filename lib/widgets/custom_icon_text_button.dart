import 'package:flutter/material.dart';
import 'package:fluttercare168/constant/color.dart';


class CustomIconTextButton extends StatelessWidget {
  final IconData iconData;
  final String text;
  final Function onPressed;
  const CustomIconTextButton({Key? key, required this.iconData, required this.text, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ElevatedButton(
        child: Wrap(
          children: [
            Icon(iconData),
            const SizedBox(width: 4,),
            Text(text),
          ],
        ),
        style: ElevatedButton.styleFrom(
            elevation: 0,
            primary: AppColor.purple
        ),
        onPressed: (){
          onPressed();
        },
      ),
    );
  }
}



