import 'package:flutter/material.dart';
import 'package:fluttercare168/constant/color.dart';

class CustomTextField extends StatelessWidget {

  IconData icon;
  String hintText;
  TextEditingController controller;
  bool isObscureText;
  bool isNumberOnly;
  bool isEditable;
  String contentText;

  CustomTextField({required this.icon, required this.hintText,required this.controller,this.isObscureText = false, this.isNumberOnly = false, this.isEditable=true, this.contentText=''});

  @override
  Widget build(BuildContext context) {
    controller.text = contentText;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      child: ListTile(
          leading: Icon(
            icon,
            size: 26.0,
            color: AppColor.darkGrey,
          ),
          title:
          (isNumberOnly)?
          TextField(
            enabled: isEditable,
            controller: controller,
            obscureText: isObscureText,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: hintText,
              focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey,)
              ),
            ),
          )
              :
          TextField(
            controller: controller,
            obscureText: isObscureText,
            decoration: InputDecoration(
              hintText: hintText,
              focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey,)
              ),
            ),
          )
      ),
    );

  }

}
