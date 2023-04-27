import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttercare168/constant/color.dart';
import 'package:fluttercare168/constant/server_api.dart';
import 'package:fluttercare168/notifier_model/user_model.dart';
import 'package:fluttercare168/pages/member/register/login_register.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fluttercare168/constant/custom_tag.dart';
import 'package:fluttercare168/models/carer.dart';
import 'package:fluttercare168/models/city.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/county.dart';
import '../models/user.dart';
import 'messages/messages.dart';
import 'package:fluttercare168/constant/review_stars.dart';
import 'city_dialog.dart';
import 'care_type_dialog.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'search_carer/search_carer_detail.dart';

//照服員推薦
class RecommendCarersPage extends StatefulWidget {
  const RecommendCarersPage({Key? key}) : super(key: key);

  @override
  _RecommendCarersPageState createState() => _RecommendCarersPageState();
}

class _RecommendCarersPageState extends State<RecommendCarersPage> {

  List<String> cityList = City.getCityNames();

  List<Carer> recommendCarerList = [];

  String? chosenCityString;
  String? chosenCareTypeString;
  int? paramCity;
  String? paramCareType;

  bool isLoading = false;

  // bool isNotShowTeachingDialogAgain = false;



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    paramCareType = 'home';
    chosenCareTypeString = '居家照顧';

    isLoading = true;
    _getRecommendCarersList(paramCity,paramCareType);

    _getUserTokenAndRefreshUser();

    Future.delayed(const Duration(milliseconds: 50), () {
      _showTeachingDialog();
    });

  }

  _showTeachingDialog()async{
    var userModel = context.read<UserModel>();
    final prefs = await SharedPreferences.getInstance();
    if(prefs.getBool('isNotShowTeachingDialog') == null || prefs.getBool('isNotShowTeachingDialog') == false){
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return StatefulBuilder(builder:(context, setState){
              return AlertDialog(
                // titlePadding: const EdgeInsets.symmetric(vertical:0),
                // title: Container(
                //   height: 10,
                //   color: AppColor.purple,
                // ),
                contentPadding: EdgeInsets.zero,
                content:Stack(
                  children: [
                    GestureDetector(
                      onTap: ()async{
                        Uri url = Uri.parse('https://care168.com.tw/assistance_detail?blogpost=12');
                        // Uri url = Uri.parse(ServerApi.getCarerUrl(userModel.user!.id!).toString());
                        if (!await launchUrl(url)) {
                          throw 'Could not launch $url';
                        }
                      },
                      child: Container(
                        width: 290,
                        height: 290,
                        decoration: const BoxDecoration(
                            image: DecorationImage(
                              image:AssetImage('images/info.png'),
                            )
                        ),
                      ),
                    ),
                    Positioned(
                      top: 5,
                      right: 5,
                      child: GestureDetector(
                        onTap: (){
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 20,
                          height: 20,
                          child: const Icon(Icons.clear, size: 18, color: Colors.white,),
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color:  Colors.grey),
                        ),
                      ),
                    ),
                  ],
                ),
                actionsAlignment: MainAxisAlignment.center,
                actionsPadding: EdgeInsets.zero,
                actions: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Checkbox(
                        checkColor:Colors.white,
                        activeColor: AppColor.purple,
                        value: userModel.isNotShowTeachingDialogAgain,
                        onChanged: (bool? value)async{
                          setState(() {
                            userModel.isNotShowTeachingDialogAgain = value!;
                          });
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool('isNotShowTeachingDialog', userModel.isNotShowTeachingDialogAgain);
                        },
                      ),
                      const Text('下次不再顯示'),
                    ],
                  ),
                ],
              );
            });
          });
    }
  }

  _getUserTokenAndRefreshUser() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('user_token');
    print(token);
    var userModel = context.read<UserModel>();
    if(token!=null && userModel.user==null){
      _getUserData(token);
    }
  }

  _deleteUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_token');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 2,
          shadowColor: Colors.black26,
          title: const Text('服務者推薦'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(58),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    child: SizedBox(
                      height: 50,
                      child: Row(
                        children:  [
                          (chosenCityString==null)?
                          const Text('縣市', style: TextStyle(fontSize: 17))
                          :
                          Text(chosenCityString!, style: const TextStyle(fontSize: 17)),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                    onTap: () async {
                      final String? city = await showDialog<String>(
                          context: context,
                          builder: (BuildContext context) {
                            return CityDialog(isNullSelection: true);
                          });
                      if(city!=null){
                        if(city == '無'){
                          setState(() {
                            chosenCityString = null;
                            paramCity = null;

                            isLoading = true;
                            _getRecommendCarersList(paramCity, paramCareType);
                          });
                        }else{
                          setState(() {
                            if(chosenCityString==null){
                              chosenCityString = city;
                            }else if (chosenCityString != city){
                              chosenCityString = city;
                            }
                            int theCityId = City.getIdFromCityName(chosenCityString!);
                            paramCity = theCityId;

                            isLoading = true;
                            _getRecommendCarersList(paramCity, paramCareType);
                          });
                        }
                      }
                    },
                  ),
                  GestureDetector(
                    child: Row(
                      children: [
                        (chosenCareTypeString==null)?
                        const Text('看護類型', style: TextStyle(fontSize: 17))
                        :
                        Text(chosenCareTypeString!, style: const TextStyle(fontSize: 17)),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                    onTap: () async {
                      final String? careType = await showDialog<String>(
                          context: context,
                          builder: (BuildContext context) {
                            return CareTypeDialog(isNullSelection: false);
                          });
                      if(careType!=null){
                        if(careType == '無'){
                          setState(() {
                            chosenCareTypeString = null;
                            paramCareType = null;

                            isLoading = true;
                            _getRecommendCarersList(paramCity, paramCareType);
                          });
                        }else{
                          setState(() {
                            if(chosenCareTypeString==null){
                              chosenCareTypeString = careType;
                            }else if (chosenCareTypeString != careType){
                              chosenCareTypeString = careType;
                            }
                            if(chosenCareTypeString == '居家照顧'){
                              paramCareType = 'home';
                            }else if (chosenCareTypeString == '醫院看護'){
                              paramCareType = 'hospital';
                            }

                            isLoading = true;
                            _getRecommendCarersList(paramCity, paramCareType);
                          });
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 8, 0),
                  child: IconButton(
                    icon: const FaIcon(FontAwesomeIcons.comments),
                    onPressed: () {
                      var userModel = context.read<UserModel>();
                      if(userModel.isLogin()){
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Messages(),
                            ));
                      } else {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginRegister(),
                            ));
                      }
                    },),
                ),
                Consumer<UserModel>(builder: (context, userModel, child){
                  if(userModel.user!=null && userModel.user!.totalUnReadNum != 0){
                    return Container(
                      decoration: const BoxDecoration(
                          color: Colors.red, shape: BoxShape.circle),
                      margin: const EdgeInsets.fromLTRB(0, 10, 10, 0),
                      padding: const EdgeInsets.all(5),
                      child: Text(userModel.user!.totalUnReadNum.toString(),style: const TextStyle(color: Colors.white)),
                    );
                  }else{
                    return Container();
                  }
                }),
              ],
            ),
          ]),
      body: (isLoading) ?
      const Center(child: CircularProgressIndicator())
          :
      (recommendCarerList.isNotEmpty) ?
      Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          const SizedBox(height: 10,),
          Text('找到 ${recommendCarerList.length} 位服務者', style: const TextStyle(color: AppColor.purple)),
          const SizedBox(height: 10,),
          const Divider(height: 0,),
          Expanded(
            child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: recommendCarerList.length,
                      itemBuilder: (BuildContext context, int i) {
                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 310,
                                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    checkUserImage(recommendCarerList[i].image),
                                    Row(
                                      children: [
                                        const SizedBox(width: 5,),
                                        Text(_getMrOrMSString(recommendCarerList[i].name!, recommendCarerList[i].gender!), style: const TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                                        const SizedBox(width: 5,),
                                        recommendCarerList[i].servantAvgRating! == 0.0 ? const Text('') : Text(recommendCarerList[i].servantAvgRating!.toString()),
                                        const SizedBox(width: 5,),
                                        ReviewStars.getReviewStars(recommendCarerList[i].servantAvgRating!),
                                        Text(' (${recommendCarerList[i].ratingNums!})'),
                                      ],
                                    ),
                                    checkCareType(i),
                                    const SizedBox(height: 6,),
                                    const Text('服務地區：'),
                                    (recommendCarerList[i].locations!.isNotEmpty)
                                        ? checkCareLocations(recommendCarerList[i].locations!)
                                        : Container()
                                  ],
                                ),
                              ),
                              const Divider(
                                color: Color(0xffC0C0C0),
                              ),
                            ],
                          ),
                          onTap: (){
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>SearchCarerDetail(theCarer: recommendCarerList[i],id: recommendCarerList[i].id!, isFromRecommend: true),
                                ));
                          },
                        );
                      }
                  ),
          ),
        ],
      )
          :
      const Center(
              child: Text('此搜索條件無服務者！'),
            ),
      floatingActionButton: FloatingActionButton(
        elevation: 0,
        backgroundColor: AppColor.purple,
        child: const Icon(Icons.menu_outlined),
        onPressed: (){
          getPopUpMenu();
        },
      ),
    );
  }

  String _getMrOrMSString(String userName, String gender){
    if(gender == 'M'){
      return userName.substring(0,1) + '先生';
    }else{
      return userName.substring(0,1) + '小姐';
    }
  }

  checkCareType(int i){
    if(recommendCarerList[i].isHome==true && recommendCarerList[i].isHospital==true){
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 6,),
          SizedBox(
            width: 80,
            child: CustomTag.homeCare,
          ),
          const SizedBox(height: 2,),
          Text('時薪 \$${_getWageWords(recommendCarerList[i].homeHourWage!)} / 半天 \$${_getWageWords(recommendCarerList[i].homeHalfDayWage!)} / 全天 \$${_getWageWords(recommendCarerList[i].homeOneDayWage!)}'),
          const SizedBox(height: 6,),
          SizedBox(
            width: 80,
            child: CustomTag.hospitalCare,
          ),
          const SizedBox(height: 2,),
          Text('時薪 \$${_getWageWords(recommendCarerList[i].hospitalHourWage!)} / 半天 \$${_getWageWords(recommendCarerList[i].hospitalHalfDayWage!)} / 全天 \$${_getWageWords(recommendCarerList[i].hospitalOneDayWage!)}'),
        ],
      );
    } else if (recommendCarerList[i].isHome==true && recommendCarerList[i].isHospital==false){
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 6,),
          SizedBox(
            width: 80,
            child: CustomTag.homeCare,
          ),
          const SizedBox(height: 2,),
          Text('時薪 \$${_getWageWords(recommendCarerList[i].homeHourWage!)} / 半天 \$${_getWageWords(recommendCarerList[i].homeHalfDayWage!)} / 全天 \$${_getWageWords(recommendCarerList[i].homeOneDayWage!)}'),
        ],
      );
    } else if (recommendCarerList[i].isHome==false && recommendCarerList[i].isHospital==true){
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 6,),
          SizedBox(
            width: 80,
            child: CustomTag.hospitalCare,
          ),
          const SizedBox(height: 2,),
          Text('時薪 \$${_getWageWords(recommendCarerList[i].hospitalHourWage!)} / 半天 \$${_getWageWords(recommendCarerList[i].hospitalHalfDayWage!)} / 全天 \$${_getWageWords(recommendCarerList[i].hospitalOneDayWage!)}'),
        ],
      );
    } else if (recommendCarerList[i].isHome==false && recommendCarerList[i].isHospital==false){
      return Container();
    }

  }

  String _getWageWords(int wage){
    if(wage != 0){
      return wage.toString();
    }else{
      return '無服務';
    }
  }

  checkUserImage(String? imgPath){
    if(imgPath == null || imgPath == ''){
      return Container(
        height: 50,
        width: 50,
        decoration: const BoxDecoration(shape: BoxShape.circle),
        child: const Icon(Icons.account_circle_rounded,size: 50,color: Colors.grey,),
      );
    } else {
      return Container(
        height: 62,
        width: 62,
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

  checkCareLocations(List<Locations> recommendCarerLocations) {
    List<String> locationStrings = [];
    if(recommendCarerLocations.isNotEmpty){
      for(var location in recommendCarerLocations){
        String city = City.getCityNameFromId(location.city!);
        // String county = County.getCountyNameFromId(location.county!);
        String theLocation = city;
        if(locationStrings.length < 4){
          locationStrings.add(theLocation);
        }else{
          if(locationStrings.last!='...'){
            locationStrings.add('...');
          }
        }
      }
      return Text(locationStrings.join(', '));
    }
  }

  getPopUpMenu(){
    return showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(100, 600, 20, 100),
      items: const [
        PopupMenuItem(
            value: 1,
            child: Text("高分排序")),
        PopupMenuItem(
            value: 2,
            child: Text("評價數排序")),
        PopupMenuItem(
            value: 3,
            child: Text("低價到高價")),
        PopupMenuItem(
            value: 4,
            child: Text("高價到低價")),
      ],
      elevation: 4.0,
    ).then((value){
      // NOTE: even you didnt select item this method will be called with null of value so you should call your call back with checking if value is not null
      if(value!=null){
        if(value==1){
          recommendCarerList.sort((a, b) => - (a.servantAvgRating!).compareTo(b.servantAvgRating!));
        }else if(value==2){
          recommendCarerList.sort((a, b) => - (a.ratingNums!).compareTo(b.ratingNums!));
        }else if(value==3){
          //低價到高價排序
          //每個carer有可能是 home 有可能是 hospital
          //所以可能要在這邊先判斷目前是選home 或 hospital ?
          if(paramCareType == null  || paramCareType=='home'){
            recommendCarerList.sort((a, b) => (a.homeOneDayWage!).compareTo(b.homeOneDayWage!));
          } else if (paramCareType=='hospital'){
            recommendCarerList.sort((a, b) => (a.hospitalOneDayWage!).compareTo(b.hospitalOneDayWage!));
          }
        }else if(value==4){
          //高價到低價排序
          if(paramCareType == null  || paramCareType=='home'){
            recommendCarerList.sort((a, b) => (b.homeOneDayWage!).compareTo(a.homeOneDayWage!));
          } else if (paramCareType=='hospital'){
            recommendCarerList.sort((a, b) => (b.hospitalOneDayWage!).compareTo(a.hospitalOneDayWage!));
          }
        }
        setState(() {});
      }
    });
  }

  Future _getRecommendCarersList(int? cityId, String? careType) async {
    String path = ServerApi.PATH_RECOMMEND_SERVANTS;
    try {
      var mapParams = Map<String, String>();
      if(cityId != null){
        mapParams['city'] = cityId.toString();
      }
      if(careType!=null){
        mapParams['care_type'] = careType;
      }
      mapParams['is_random'] = 'true';
      final response = await http.get(ServerApi.standard(path: path,queryParameters: mapParams),);
      if (response.statusCode == 200) {
        List<dynamic> parsedListJson = json.decode(utf8.decode(response.body.runes.toList()));
        List<Carer> data = List<Carer>.from(parsedListJson.map((i) => Carer.fromJson(i)));
        recommendCarerList = data;
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<User?> _getUserData(String token) async {
    String path = ServerApi.PATH_USER_DATA;
    try {
      final response = await http.get(
        ServerApi.standard(path: path),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Token $token',
        },
      );

      print(response.body);

      if(response.statusCode ==200){
        Map<String, dynamic> map = json.decode(utf8.decode(response.body.runes.toList()));
        User theUser = User.fromJson(map);

        var userModel = context.read<UserModel>();
        userModel.setUser(theUser);
        userModel.token = token;

        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("歡迎回來！${userModel.user!.name}"),));
        return theUser;
      }else{
        //token過期, 需重新登入
        _deleteUserToken();
      }

    } catch (e) {
      print(e);

      // return null;
      // return User(phone: '0000000000', name: 'test test', isGottenLineId: false, token: '4b36f687579602c485093c868b6f2d8f24be74e2',isOwner: false);

    }
    return null;
  }
}