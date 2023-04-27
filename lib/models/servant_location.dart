class ServantLocation{
  int? id;
  int? transferFee;
  int? user;
  int? city;
  // int? county;

  ServantLocation({this.id, required this.transferFee, this.user, required this.city});

  ServantLocation.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    transferFee = json['transfer_fee'];
    user = json['user'];
    city = json['city'];
    // county = json['county'];
  }
}