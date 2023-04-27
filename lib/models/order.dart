
import 'carer.dart';

class Order {
  int? id;
  List<IncreaseServices>? increaseServices;
  String? state;

  int? transferFee;
  int? numOfTransfer;
  int? amountTransferFee;

  int? wageHour;
  double? workHours;
  int? baseMoney;
  int? totalMoney;

  double? newebpay_percent;
  int? newebpay_money;

  double? platformPercent;
  int? platformMoney;

  int? servant_money;

  String? startDatetime;
  String? endDatetime;
  double? startTime;
  double? endTime;
  String? createdAt;
  int? theCase;
  int? user;

  bool? is_early_termination;

  // int? servant;
  Carer? servant;

  Order({
    this.id,
    this.increaseServices,
    this.state,
    this.transferFee,
    this.numOfTransfer,
    this.amountTransferFee,
    this.wageHour,
    this.workHours,
    this.baseMoney,
    this.totalMoney,
    this.newebpay_percent,
    this.newebpay_money,
    this.platformPercent,
    this.platformMoney,
    this.servant_money,
    this.startDatetime,
    this.endDatetime,
    this.startTime,
    this.endTime,
    this.createdAt,
    this.theCase,
    this.user,
    this.is_early_termination,
    this.servant,
  });

  factory Order.fromJson(Map<String, dynamic> json) {

    var list = (json['increase_services'] ?? []) as List;
    List<IncreaseServices> increaseServicesList = list.map((i) => IncreaseServices.fromJson(i)).toList();

    print(json['servant']);

    return Order(
        id: json['id'],
        increaseServices: increaseServicesList,
        state: json['state'],
        transferFee: (json['transfer_fee']!=null)?json['transfer_fee']:0,
        numOfTransfer: (json['number_of_transfer']!=null)?json['number_of_transfer']:0,
        amountTransferFee: (json['amount_transfer_fee']!=null)?json['amount_transfer_fee']:0,
        wageHour: (json['wage_hour']!=null)?json['wage_hour']:0,
        workHours: json['work_hours'],
        baseMoney: json['base_money'],
        totalMoney: json['total_money'],
        newebpay_percent: json['newebpay_percent'],
        newebpay_money: json['newebpay_money'],
        platformPercent: json['platform_percent'],
        platformMoney: json['platform_money'],
        servant_money: json['servant_money'],
        startDatetime: json['start_datetime'],
        endDatetime: json['end_datetime'],
        startTime: json['start_time'],
        endTime: json['end_time'],
        createdAt: json['created_at'],
        theCase: json['case'],
        user: json['user'],
        is_early_termination: (json['is_early_termination']!=null)?json['is_early_termination']:false,
        servant : (json['servant']!=null)?Carer.fromJson(json['servant']):null,
        // servant: json['servant'],
    );

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    if (this.increaseServices != null) {
      data['increase_services'] = this.increaseServices!.map((v) => v.toJson()).toList();
    }
    data['state'] = this.state;
    data['work_hours'] = this.workHours;
    data['base_money'] = this.baseMoney;
    data['platform_percent'] = this.platformPercent;
    data['platform_money'] = this.platformMoney;
    data['total_money'] = this.totalMoney;
    data['start_datetime'] = this.startDatetime;
    data['end_datetime'] = this.endDatetime;
    data['start_time'] = this.startTime;
    data['end_time'] = this.endTime;
    data['created_at'] = this.createdAt;
    data['case'] = this.theCase;
    data['user'] = this.user;
    // data['servant'] = this.servant;
    return data;
  }
  }

  class IncreaseServices {
    int? id;
    double? increasePercent;
    int? increaseMoney;
    int? order;
    int? service;

    IncreaseServices({this.id, this.increasePercent, this.increaseMoney, this.order, this.service});

    IncreaseServices.fromJson(Map<String, dynamic> json) {
      id = json['id'];
      increasePercent = json['increase_percent'];
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