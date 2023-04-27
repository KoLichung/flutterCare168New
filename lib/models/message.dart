import 'package:fluttercare168/constant/server_api.dart';

import 'case.dart';
import 'order.dart';

class Message {
  int? id;

  int? chatroom;
  int? user;
  int? theCase;
  // int? theOrder;
  bool? isThisMessageOnlyCase;
  String? content;
  String? createAt;

  String? image;
  bool? isReadByOtherSide;

  bool? messageIsMine;
  Case? caseDetail;
  Order? orderDetail;

  Message({this.id, this.messageIsMine, this.isThisMessageOnlyCase, this.image, this.content, this.createAt, this.chatroom, this.user, this.theCase, this.orderDetail, this.isReadByOtherSide, this.caseDetail});

  Message.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    messageIsMine = json['message_is_mine'];
    isThisMessageOnlyCase = json['is_this_message_only_case'];
    isReadByOtherSide = json['is_read_by_other_side'];

    if(json['image']!=null) {
      if( json['image'].toString().contains('http')){
        image = json['image'];
      }else{
        image = ServerApi.host + json['image'];
      }
    }
    content = json['content'];
    createAt = json['create_at'];
    chatroom = json['chatroom'];
    user = json['user'];
    theCase = json['case'];
    if(json['order']!=null){
      try{
        orderDetail = Order.fromJson(json['order']);
      }catch(e){
         print(e);
      }
    }
    if( json['case_detail'] != null){
      try{
        caseDetail = Case.fromJson(json['case_detail']);
      }catch(e){
        print(e);
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['message_is_mine'] = this.messageIsMine;
    data['is_this_message_only_case'] = this.isThisMessageOnlyCase;
    data['image'] = this.image;
    data['content'] = this.content;
    data['create_at'] = this.createAt;
    data['chatroom'] = this.chatroom;
    data['user'] = this.user;
    data['case'] = this.theCase;
    return data;
  }
}

