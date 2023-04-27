import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttercare168/constant/color.dart';
import 'package:fluttercare168/constant/custom_tag.dart';
import 'package:fluttercare168/constant/server_api.dart';
import 'package:fluttercare168/models/city.dart';
import 'package:fluttercare168/models/county.dart';
import 'package:fluttercare168/models/license.dart';
import 'package:fluttercare168/models/service.dart';
import 'package:fluttercare168/notifier_model/booking_model.dart';
import 'package:fluttercare168/notifier_model/user_model.dart';
import 'package:fluttercare168/pages/recommend_carer_booking_page.dart';
import 'package:fluttercare168/pages/search_carer/booking_step1_detail.dart';
import 'package:fluttercare168/constant/review_stars.dart';
import 'package:fluttercare168/models/carer.dart';
import 'package:fluttercare168/pages/search_carer/search_carer_detail_reviews.dart';
import 'package:fluttercare168/widgets/custom_elevated_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../constant/enum.dart';
import '../member/register/login_register.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchCarerDetail extends StatefulWidget {
  final Carer theCarer;
  final int id;
  final bool isFromRecommend;
  const SearchCarerDetail({Key? key, required this.theCarer, required this.id, required this.isFromRecommend}) : super(key: key);

  @override
  _SearchCarerDetailState createState() => _SearchCarerDetailState();
}

class _SearchCarerDetailState extends State<SearchCarerDetail> {

  bool isBgImageVisible = false;
  String? careTypeString;
  Carer? carerDetail;
  List<Service> carerServices=[];
  bool isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var userModel = context.read<UserModel>();
    careTypeString = (userModel.careType == CareType.homeCare) ? '居家照顧':'醫院看護';
    _getServantDetail();
  }

  @override
  Widget build(BuildContext context) {
    var bookingModel = context.read<BookingModel>();
    var userModel = context.read<UserModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('照護搜尋')),
      body: (isLoading)?const Center(child:CircularProgressIndicator()):SingleChildScrollView(
        child: Column(
          children: [
            checkCarerBgImage(), //服務者背景圖
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20,),
                  Row(
                    children: [
                      checkCarerImage(widget.theCarer.image),
                      const SizedBox(width: 6,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_getMrOrMSString(widget.theCarer.name!, widget.theCarer.gender!),style: const TextStyle(fontSize: 20),),
                              const SizedBox(width: 5,),
                              widget.theCarer.servantAvgRating! == 0.0 ? const Text('') : Text(widget.theCarer.servantAvgRating!.toString()),
                              const SizedBox(width: 5,),
                              ReviewStars.getReviewStars(widget.theCarer.servantAvgRating!),
                              Text(' (${widget.theCarer.ratingNums!})'),
                            ],),
                          const SizedBox(height: 10,),
                          checkCarerCareType(),
                        ],)
                    ],
                  ), //頭像&姓名
                  const SizedBox(height: 20,),
                  Row(
                    children: [
                      const Text('語言能力',style: TextStyle(color: AppColor.purple, fontWeight: FontWeight.bold),),
                      const SizedBox(width: 10,),
                      Expanded(child: Text(checkCarerLanguage())),
                    ],
                  ), //語言能力
                  const SizedBox(height: 10,),
                  Row(
                    children: [
                      const Text('我的費用',style: TextStyle(color: AppColor.purple, fontWeight: FontWeight.bold),),
                      const SizedBox(width: 10,),
                      checkCarerSalary(),
                    ],
                  ), //我的費用
                  const SizedBox(height: 10,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('服務地區',style: TextStyle(color: AppColor.purple, fontWeight: FontWeight.bold),),
                      const SizedBox(width: 10,),
                      Text(checkCarerLocation(widget.theCarer.locations!)),
                    ],
                  ), //服務地區
                  const SizedBox(height: 10,),
                  const Divider(height: 0,thickness: 0.5, color: Colors.grey, indent: 20,endIndent: 20,),
                  const SizedBox(height: 20,),
                  const Text('提供服務項目',style: TextStyle(color: AppColor.purple, fontWeight: FontWeight.bold,fontSize: 16),),
                  const SizedBox(height: 10,),
                  checkCarerServices(),
                  const SizedBox(height: 10,),
                  const Text('相關資格文件',style: TextStyle(color: AppColor.purple, fontWeight: FontWeight.bold,fontSize: 16),),
                  const SizedBox(height: 10,),
                  checkIdentityLicenses(),
                  // checkSkillLicenses(),
                  const SizedBox(height: 10,),
                  const Text('關於我',style: TextStyle(color: AppColor.purple, fontWeight: FontWeight.bold,fontSize: 16),),
                  const SizedBox(height: 10,),
                  (widget.theCarer.aboutMe == null ||widget.theCarer.aboutMe == '') ? const Text('服務者未填寫'): Text(widget.theCarer.aboutMe!),
                  const Divider(height: 40,thickness: 0.5, color: Colors.grey, indent: 20,endIndent: 20,),
                  checkCarerReviews(),
                  const SizedBox(height: 20,),
                  Center(
                    child: CustomElevatedButton(
                        text: '申請預定並聊聊',
                        color: AppColor.purple,
                        onPressed: (){
                          setState(() {
                            bookingModel.carer = widget.theCarer;
                            bookingModel.carerServices = carerServices;
                          });
                          if(userModel.isLogin()){
                            if(widget.theCarer.id != userModel.user!.id){
                              print(widget.theCarer.id);
                              print(userModel.user!.id);
                              if(widget.isFromRecommend){
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => RecommendCarerBookingPage(carer: widget.theCarer),
                                    ));
                              }else{
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BookingStep1Detail(careType: userModel.careType, city: userModel.city),
                                    ));
                              }
                            }else{
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("不能發案給自己！"),));
                            }
                          } else {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginRegister(),
                                ));
                          }
                        }),
                  ),
                  const SizedBox(height: 40,),
                ],
              ),
            ),
          ],
        ),
      ),
    );

  }

  checkCarerBgImage(){
    if(widget.theCarer.backgroundImageUrl == null || widget.theCarer.backgroundImageUrl ==''){
      return Container();
    } else{
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        height: 200,
        decoration: BoxDecoration(
          image: DecorationImage(
              image: NetworkImage(widget.theCarer.backgroundImageUrl!),
              fit: BoxFit.cover
          ),
        ),
      );

    }
  }

  checkCarerImage(String? imgPath) {
    if (imgPath == null || imgPath == '') {
      return Container(
        height: 90,
        width: 90,
        decoration: const BoxDecoration(shape: BoxShape.circle),
        child: const Icon(Icons.account_circle_rounded, size: 64, color: Colors.grey,),
      );
    } else {
      return Container(
        height: 90,
        width: 90,
        decoration: BoxDecoration(
          color: Colors.grey,
          shape: BoxShape.circle,
          image: DecorationImage(
              image: NetworkImage(imgPath),
              fit: BoxFit.cover
          ),
        ),
      );
    }
  }

  String _getMrOrMSString(String userName, String gender){
    if(gender == 'M'){
      return userName.substring(0,1) + '先生';
    }else{
      return userName.substring(0,1) + '小姐';
    }
  }

  checkCarerCareType(){
    if(widget.theCarer.isHome == true && widget.theCarer.isHospital == true){
      return Row(
        children: [
          CustomTag.homeCare,
          const SizedBox(width: 10,),
          CustomTag.hospitalCare
        ],);
    } else if(widget.theCarer.isHome == true && widget.theCarer.isHospital == false){
      return CustomTag.homeCare;
    } else if(widget.theCarer.isHome == false && widget.theCarer.isHospital == true){
      return CustomTag.hospitalCare;
    }
  }

  checkCarerLanguage(){
    List<String> languageStrings = [];
    for(var language in carerDetail!.languages!){
      if(language.remark==null){
        languageStrings.add(language.languageName!);
      }else{
        languageStrings.add("${language.languageName}(${language.remark})");
      }
    }
    return languageStrings.isEmpty ? '服務者未填寫' : languageStrings.join(', ');
  }

  checkCarerSalary(){
    if(widget.theCarer.isHome == true && widget.theCarer.isHospital == true){
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('居家照顧'),
          Text('時薪\$${_getWageWords(widget.theCarer.homeHourWage!)}｜半天\$${_getWageWords(widget.theCarer.homeHalfDayWage!)}｜全天\$${_getWageWords(widget.theCarer.homeOneDayWage!)}'),
          const Text('醫院看護'),
          Text('時薪\$${_getWageWords(widget.theCarer.hospitalHourWage!)}｜半天\$${_getWageWords(widget.theCarer.hospitalHalfDayWage!)}｜全天\$${_getWageWords(widget.theCarer.hospitalOneDayWage!)}'),
        ],
      );
    } else if(widget.theCarer.isHome == true && widget.theCarer.isHospital == false){
      return Text('時薪\$${_getWageWords(widget.theCarer.homeHourWage!)}｜半天\$${_getWageWords(widget.theCarer.homeHalfDayWage!)}｜全天\$${_getWageWords(widget.theCarer.homeOneDayWage!)}');
    } else if (widget.theCarer.isHome == false && widget.theCarer.isHospital == true){
      return Text('時薪\$${_getWageWords(widget.theCarer.hospitalHourWage!)}｜半天\$${_getWageWords(widget.theCarer.hospitalHalfDayWage!)}｜全天\$${_getWageWords(widget.theCarer.hospitalOneDayWage!)}');
    }
  }

  String _getWageWords(int wage){
    if(wage != 0){
      return wage.toString();
    }else{
      return '無服務';
    }
  }

  checkCarerLocation(List<Locations> locations) {
    List<String> locationStrings = [];
    for (var location in locations) {
      locationStrings.add('${City.getCityNameFromId(location.city!)} 交通費\$${location.transferFee!.toString()}\n');
    }
    return locationStrings.isEmpty? '服務者未填寫': locationStrings.join('');
  }

  Widget checkCarerServices(){
    List<Padding> services = [];
    for(var service in carerDetail!.services!){
      if( service.id!=1 && service.id!=2 && service.id!=3 && service.id!=4){
        services.add(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTag.iconYes,
                      const SizedBox(width: 10,),
                      (service.remark == null || service.remark == '')
                          ? Text(service.name!)
                          : Expanded(child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(text: '${service.name}\n'),
                                  TextSpan(text: service.remark, style: const TextStyle(color: Colors.grey),),
                                ],
                              ),
                            )
                          )
                    ],
                  ),
                ],
              ),
            ));
      }
    }
    return services.isEmpty ? const Text('服務者未填寫'):Column(children:services);
  }

  checkIdentityLicenses(){
    List<Padding> licenses = [];
    for(var license in carerDetail!.licences!){
      if(license.license != 1 &&  license.license != 2 && license.license != 3){
        if(license.isPassed! || license.license == 4 || license.license == 5 || license.license == 6 ){
          licenses.add(
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      license.isPassed == true ? CustomTag.iconYes : CustomTag.iconNo,
                      const SizedBox(width: 10,),
                      Expanded(child: Text(license.licenseName!))
                    ],
                  ))
          );
        }
      }

    }
    return Column(children: licenses);
  }

  checkSkillLicenses(){
    List<Padding> licenses = [];
    for(var license in carerDetail!.licences!){
      if(license.id! >= 7 && license.id! <= 15 ){
        licenses.add(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  CustomTag.iconYes,
                  const SizedBox(width: 10,),
                  Text(license.name!),
                ],
              ),
            ));
      }
    }
    return Column(children: licenses,);
  }

  kProvidedDocument(bool isProvided,String docName){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          isProvided ? CustomTag.iconYes : CustomTag.iconNo,
          const SizedBox(width: 10,),
          Text(docName),
        ],
      ),
    );
  }

  checkCarerReviews(){
    if(carerDetail!.reviews!.isEmpty){
      return const Text('尚無評價',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),);
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${carerDetail!.reviews!.length.toString()} 則評價',style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
          ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: carerDetail!.reviews!.length < 2 ? 1 : 2,
              itemBuilder:(BuildContext context,int i){
                return  Container(
                  margin: const EdgeInsets.only(top: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  color: const Color(0xffF2F2F2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          checkUserImage(carerDetail!.reviews![i].neederImage),
                          const SizedBox(width: 10,),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    (carerDetail!.reviews![i].neederName!=null)?
                                    Text(carerDetail!.reviews![i].neederName!)
                                    :
                                    Text("unknown"),
                                    ReviewStars.getReviewStars(carerDetail!.reviews![i].servantRating!)
                                  ],
                                ),
                                // Text('${carerDetail!.reviews![i].isContinuousTime! =='true' ? '連續時間' : '指定時段'}  |  ${carerDetail!.reviews![i].careType!}',style: const TextStyle(fontSize: 12),)
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15,),
                      Text('"${carerDetail!.reviews![i].servantComment!}"'),
                      const SizedBox(height: 15,),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text('建立於 ${carerDetail!.reviews![i].servantRatingCreatedAt!.substring(0,10)}',style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12),)
                      ),
                    ],
                  ),
                );
              }
          ),
          Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    child: const Text('看所有評價',style: TextStyle(color: Colors.black,decoration: TextDecoration.underline),),
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (content)=> SearchCarerDetailReviews(reviews: carerDetail!.reviews!)));
                    },
                  ),
                ),
        ],
      );
    }
  }

  checkUserImage(String? imgPath) {
    if (imgPath == null || imgPath == '') {
      return Container(
        height: 70,
        width: 70,
        decoration: const BoxDecoration(shape: BoxShape.circle),
        child: const Icon(Icons.account_circle_rounded, size: 64, color: Colors.grey,),
      );
    } else {
      return Container(
        height: 70,
        width: 70,
        decoration: BoxDecoration(
          color: Colors.grey,
          shape: BoxShape.circle,
          image: DecorationImage(
              image: NetworkImage(ServerApi.host +imgPath),
              fit: BoxFit.cover
          ),
        ),
      );
    }
  }

  Future _getServantDetail() async {
    String path = ServerApi.PATH_SEARCH_SERVANTS + widget.id.toString();
    try {
      final response = await http.get(
          ServerApi.standard(path: path));
      if (response.statusCode == 200) {
        // print(response.body);
        Map<String, dynamic> map = json.decode(utf8.decode(response.body.runes.toList()));
        carerDetail = Carer.fromJson(map);
        carerServices = List<Service>.from(map['services'].map((i) => Service.fromJson(i)));
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print(e);
    }
  }
}
