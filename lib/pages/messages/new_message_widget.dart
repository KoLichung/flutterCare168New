import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttercare168/constant/color.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../../constant/server_api.dart';
import '../../models/message.dart';
import '../../notifier_model/user_model.dart';

class NewMessageWidget extends StatefulWidget {
  final ValueChanged<Map> onSubmitted;
  final int chatroomId;
  final isSendImage;

  const NewMessageWidget({Key? key, required this.onSubmitted, required this.chatroomId, required this.isSendImage}) : super(key: key);

  @override
  State<NewMessageWidget> createState() => _NewMessageWidgetState();
}

class _NewMessageWidgetState extends State<NewMessageWidget> {
  final controller = TextEditingController();
  XFile image = XFile('');

  @override
  Widget build(BuildContext context) => Container(
    color: AppColor.purple,
    padding: const EdgeInsets.fromLTRB(12,18,12,30),
    child: Row(
      children: <Widget>[
        IconButton(
          icon: const Icon(Icons.image_outlined, color: Colors.white, size: 34,),
          onPressed: () async {
            if(widget.isSendImage){
              final ImagePicker _picker = ImagePicker();
              final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 800, maxHeight: 600);
              if(pickedFile == null) return;
              image = pickedFile;

              var userModel = context.read<UserModel>();
              _postImageMessage(image,userModel.token!);
            }else{
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("訂單成立後才能互傳圖片"),));
            }
          },
        ),
        Expanded(
          child: Material(
            borderRadius: BorderRadius.circular(50),
            color: Colors.white,
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                contentPadding:
                EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                hintText: '輸入訊息...',
                hintStyle: TextStyle(fontSize: 14,color: Colors.grey),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.send, color: Colors.white),
          onPressed: () {
              if (controller.text.trim().isEmpty) return;

              var userModel = context.read<UserModel>();
              _postMessage(controller.text,userModel.token!);

              Map messageMap = {};
              messageMap['text'] = controller.text;
              messageMap['isMsgImage'] = false;
              widget.onSubmitted(messageMap);
              controller.clear();
          },
        ),
      ],
    ),
  );

  Future _postImageMessage(XFile image,String token)async{
    String path = ServerApi.PATH_MESSAGES;
    var request = http.MultipartRequest(
        'POST',
        ServerApi.standard(path: path, queryParameters: {'chatroom' : widget.chatroomId.toString()})
    );
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Token $token',
    };

    request.headers.addAll(headers);
    print(request.headers);

    final file = await http.MultipartFile.fromPath('image', image.path);
    request.files.add(file);

    var response = await request.send();

    print('image upload status code ${response.statusCode}');

    if(response.statusCode == 200){
      String responseString = await response.stream.bytesToString();
      Map<String, dynamic> map = json.decode(utf8.decode(responseString.runes.toList()));
      Message theMessage = Message.fromJson(map);

      Map messageMap = {};
      messageMap['text'] = theMessage.image!;
      messageMap['isMsgImage'] = true;
      widget.onSubmitted(messageMap);

      // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("圖片上傳成功!"),));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("圖片上傳失敗"),));
    }

  }

  Future<void> _postMessage(String content, String token) async {
    String path = ServerApi.PATH_MESSAGES;
    // try {
      Map queryParameters = {
        'content': content,
      };

      final response = await http.post(
          ServerApi.standard(
              path: path,
              queryParameters: {'chatroom' : widget.chatroomId.toString()}
          ),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Token $token',
          },
          body: jsonEncode(queryParameters)
      );

      print(token);
      print(widget.chatroomId.toString());
      print(content);

      Map<String, dynamic> map = json.decode(utf8.decode(response.body.runes.toList()));
      if(map['content']!=null){
        // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("上傳成功"),));
      }else{
        // print(response.body);
        // ScaffoldMessenger.of(context).showSnackBar(
        //     const SnackBar(
        //       content: Text("上傳錯誤！"),
        //     )
        // );
      }

    // }catch(e){
    //   print(e);
    // }
  }

  // void _printLongString(String text) {
  //   final RegExp pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
  //   pattern.allMatches(text).forEach((RegExpMatch match) =>   print(match.group(0)));
  // }

}

