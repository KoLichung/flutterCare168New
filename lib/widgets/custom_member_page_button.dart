import 'package:flutter/material.dart';

class CustomMemberPageButton extends StatelessWidget {
  final String title;
  final Function onPressed;


  CustomMemberPageButton({ required this.title, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: ListTile(
                title: Text(title, style: TextStyle(fontSize: 16),),
                trailing: Container(
                  width: 30,
                  // child: IconButton(
                  //   onPressed: () {
                  //
                  //   },
                  //   icon: const Icon(Icons.arrow_forward_ios),
                  // ),
                  child: const Icon(Icons.arrow_forward_ios),
                ),
              )),
          onTap: (){
            this.onPressed();
          },
        ),
      ],
    );
  }
}


