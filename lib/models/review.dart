class Review {
  int? id;
  String? careType;
  String? isContinuousTime;
  String? startDatetime;
  String? endDatetime;
  int? userAvgRate;
  int? userRatedNum;
  int? userRatingNums;
  String? servantName;
  String? servantImage;
  double? caseOffenderRating;
  String? caseOffenderComment;
  String? caseOffenderRatingCreatedAt;
  double? servantRating;
  String? servantComment;
  String? servantRatingCreatedAt;
  int? order;
  int? theCase;
  int? servant;
  String? neederName;
  String? neederImage;

  Review({this.id, this.careType, this.isContinuousTime, this.startDatetime, this.endDatetime, this.userAvgRate, this.userRatedNum, this.userRatingNums, this.servantName, this.servantImage, this.caseOffenderRating, this.caseOffenderComment, this.caseOffenderRatingCreatedAt, this.servantRating, this.servantComment, this.servantRatingCreatedAt, this.order, this.theCase, this.servant, this.neederName, this.neederImage});

  Review.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    careType = json['care_type'] == 'home' ? '居家照顧' :'醫院看護';

    if(json['is_continuous_time'].runtimeType == bool){
      json['is_continuous_time'] == false ? isContinuousTime = 'false' : isContinuousTime = 'true';
    } else {
      isContinuousTime = json['is_continuous_time'];
    }

    if(json['start_datetime']!=null && json['start_datetime']!=""){
      startDatetime = (json['start_datetime']).substring(0,10);
    }else{
      startDatetime = "";
    }

    if(json['end_datetime']!=null && json['end_datetime']!=""){
      endDatetime = (json['end_datetime']).substring(0,10);
    }else{
      endDatetime = "";
    }

    userAvgRate = json['user_avg_rate'];
    userRatedNum = json['user_rated_num'];
    userRatingNums = json['user_rating_nums'];
    servantName = json['servant_name'];

    if(json['servant_image']==null){
      servantImage = '';
    } else {
      servantImage = json['servant_image'];

    }
    caseOffenderRating = json['case_offender_rating'];
    caseOffenderComment = json['case_offender_comment'];
    caseOffenderRatingCreatedAt = json['case_offender_rating_created_at'];
    servantRating = json['servant_rating'];
    if(json['servant_comment'] == null){
      servantComment = '';
    } else {
      servantComment = json['servant_comment'];
    }
    if(json['servant_rating_created_at'] == null){
      servantRatingCreatedAt = '';
    } else {
      servantRatingCreatedAt = json['servant_rating_created_at'];
    }
    order = json['order'];
    theCase = json['case'];
    servant = json['servant'];
    neederName = json['needer_name'];
    if(json['needer_image'] == null){
      neederImage = '';
    } else {
      neederImage = json['needer_image'];
    }
  }

  Map<String, dynamic> toJson() {
  final Map<String, dynamic> data = new Map<String, dynamic>();
  data['id'] = this.id;
  data['care_type'] = this.careType;
  data['is_continuous_time'] = this.isContinuousTime;
  data['start_datetime'] = this.startDatetime;
  data['end_datetime'] = this.endDatetime;
  data['user_avg_rate'] = this.userAvgRate;
  data['user_rated_num'] = this.userRatedNum;
  data['user_rating_nums'] = this.userRatingNums;
  data['servant_name'] = this.servantName;
  data['servant_image'] = this.servantImage;
  data['case_offender_rating'] = this.caseOffenderRating;
  data['case_offender_comment'] = this.caseOffenderComment;
  data['case_offender_rating_created_at'] = this.caseOffenderRatingCreatedAt;
  data['servant_rating'] = this.servantRating;
  data['servant_comment'] = this.servantComment;
  data['servant_rating_created_at'] = this.servantRatingCreatedAt;
  data['order'] = this.order;
  data['case'] = this.theCase;
  data['servant'] = this.servant;
  data['needer_name'] = this.neederName;
  data['needer_image'] = this.neederImage;
  return data;
}
}