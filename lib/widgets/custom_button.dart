import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final Function onPressed;
  final Color color;
  const CustomButton({Key? key, required this.text, required this.onPressed, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return
      Container(
          margin: const EdgeInsets.symmetric(vertical: 0),
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
          child:ElevatedButton(
              onPressed: () {
                onPressed();
              },
              style: ElevatedButton.styleFrom(
                  primary: color,
                  elevation: 0
              ),
              child: SizedBox(
                height: 46,
                child: Align(
                  child: Text(text),
                  alignment: Alignment.center,
                ),
              )
          )
      );
  }
}