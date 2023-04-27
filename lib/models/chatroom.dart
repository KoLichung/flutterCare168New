class Chatroom {
  int? id;
  String? otherSideImageUrl;
  String? otherSideName;
  String? lastMessage;
  int? unreadNum;
  String? updateAt;

  Chatroom(
      {this.id,
        this.otherSideImageUrl,
        this.otherSideName,
        this.lastMessage,
        this.unreadNum,
        this.updateAt});

  Chatroom.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    otherSideImageUrl = json['other_side_image_url'];
    otherSideName = json['other_side_name'];
    lastMessage = json['last_message'];
    unreadNum = json['unread_num'];
    updateAt = json['update_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['other_side_image_url'] = this.otherSideImageUrl;
    data['other_side_name'] = this.otherSideName;
    data['last_message'] = this.lastMessage;
    data['unread_num'] = this.unreadNum;
    data['update_at'] = this.updateAt;
    return data;
  }
}


