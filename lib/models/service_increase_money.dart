class ServiceIncreaseMoney {
  int? id;
  double? increasePercent;
  int? increaseMoney;
  int? order;
  int? service;

  ServiceIncreaseMoney({this.id, this.increasePercent, this.increaseMoney, this.order, this.service});

  ServiceIncreaseMoney.fromJson(Map<String, dynamic> json) {
    id = json['id'];

    if(json['increase_percent']!=null){
      print(json['increase_percent']);
      if(json['increase_percent'].toString().contains('.')){
        increasePercent = json['increase_percent'];
      }else{
        // increasePercent = double.parse(json['increase_percent']+.0);
        increasePercent = json['increase_percent']+.0;

      }
    }
    increaseMoney = json['increase_money'];
    order = json['order'];
    service = json['service'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['increase_percent'] = this.increasePercent;
    data['increase_money'] = this.increaseMoney;
    data['order'] = this.order;
    data['service'] = this.service;
    return data;
  }

}