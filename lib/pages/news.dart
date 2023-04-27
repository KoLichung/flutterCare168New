import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttercare168/constant/color.dart';
import 'package:fluttercare168/notifier_model/user_model.dart';
import 'package:fluttercare168/pages/member/register/login_register.dart';
import 'package:fluttercare168/pages/member/my_service/bank_account.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fluttercare168/constant/custom_tag.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constant/server_api.dart';
import '../models/blog_category.dart';
import '../models/blog_post.dart';
import '../models/user.dart';
import 'messages/messages.dart';
import 'package:http/http.dart' as http;

//最新資訊
class News extends StatefulWidget {
  const News({Key? key}) : super(key: key);

  @override
  _NewsState createState() => _NewsState();
}

class _NewsState extends State<News> {

  List<BlogPost> blogPosts = [];
  List<BlogCategory> blogCategories = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getBlogCategories();
    getBlogPosts(-1);
    _getUserTokenAndRefreshUser();
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
    return DefaultTabController(
      length: blogCategories.length+1,
      child: Scaffold(
        appBar: AppBar(
          elevation: 2,
            shadowColor: Colors.black26,
            title: const Text('最新資訊'),
            actions: [
              Stack(
                alignment: Alignment.topRight,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16,16,8,0),
                    child: IconButton(
                      icon: const FaIcon(FontAwesomeIcons.comments),
                      onPressed: (){
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
            ],
        // elevation: 1.5,
        bottom:PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 1),
            color: Colors.white,
            child: TabBar(
              isScrollable:true,
              indicatorPadding: EdgeInsets.symmetric(vertical: 8),
              labelColor: AppColor.deepPurple,
              indicatorColor: AppColor.deepPurple,
              indicatorSize: TabBarIndicatorSize.label,
              tabs: getTabs(),
              ),
            ),
          ),
        ),
        body: TabBarView(
              children: getTabContentPostViews(),
            ),
      ),
    );
  }

  getTabs(){
    List<Tab> tabs = [];
    tabs.add(Tab(text: '全部'));
    for(var category in blogCategories){
      tabs.add(Tab(text: category.name));
    }
    return tabs;
  }

  getTabContentPostViews(){
    List<Widget> views = [];

    ListView newListView = ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: blogPosts.length,
        itemBuilder: (BuildContext context,int i){
          return GestureDetector(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
                  child: Row(
                    children: [
                      Container(
                        height: 70,
                        width: 100,
                        child: (blogPosts[i].coverImage!=null)?Image.network(blogPosts[i].coverImage!,fit: BoxFit.fill):Container(),
                      ), //文章圖片
                      const SizedBox(width: 20,),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(blogPosts[i].createDate!.substring(0,10)),
                                SizedBox(width: 10),
                                // CustomTag.topArticle
                              ],
                            ),
                            Text(blogPosts[i].title!, overflow: TextOverflow.fade,)
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                const Divider(
                  color: Color(0xffC0C0C0),
                ),
              ],
            ),
            onTap: ()async{
              Uri url = Uri.parse(ServerApi.getBlogDetailUrl(blogPosts[i].id!));
              if (!await launchUrl(url)) {
                throw 'Could not launch $url';
              }
            } ,
          );
        }
    );
    views.add(newListView);

    for(var category in blogCategories){
      List<BlogPost> categoryPosts = blogPosts.where((element){
       for(var elementCategory in element.categories!){
         if(elementCategory.id == category.id){
           return true;
         }
       }
       return false;
      }).toList();

      ListView newListView = ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: categoryPosts.length,
          itemBuilder: (BuildContext context,int i){
            return  GestureDetector(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
                      child: Row(
                        children: [
                          Container(
                            height: 70,
                            width: 100,
                            child: Image.network(categoryPosts[i].coverImage!,fit: BoxFit.fill),
                          ), //文章圖片
                          const SizedBox(width: 20,),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(categoryPosts[i].publishDate!.substring(0,10)),
                                    SizedBox(width: 10),
                                    // CustomTag.topArticle
                                  ],
                                ),
                                Text(categoryPosts[i].title!, overflow: TextOverflow.fade,)
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    const Divider(
                      color: Color(0xffC0C0C0),
                    ),
                  ],
                ),
                onTap:() async{
                  Uri url = Uri.parse(ServerApi.getBlogDetailUrl(categoryPosts[i].id!));
                  if (!await launchUrl(url)) {
                    throw 'Could not launch $url';
                  }
                },
              );
          });
      views.add(newListView);
    }
    return views;
  }

  Future getBlogPosts(int categoryId) async{
    String path = ServerApi.PATH_BLOG_POST;
    try {
      Map<String, String> queryParms = {};
      if(categoryId!=-1) {
        queryParms['category_id'] = categoryId.toString();
      }
      final response = await http.get(ServerApi.standard(
          path: path,
          queryParameters: queryParms
        )
      );
      if (response.statusCode == 200) {
        List<dynamic> parsedListJson = json.decode(utf8.decode(response.body.runes.toList()));
        blogPosts = List<BlogPost>.from(parsedListJson.map((i) => BlogPost.fromJson(i)));
        setState(() {});
      }
    } catch (e) {
      print(e);
    }
  }

  Future getBlogCategories() async{
    String path = ServerApi.PATH_BLOG_CATEGORIES;
    try {
      final response = await http.get(ServerApi.standard(
          path: path,
        )
      );
      if (response.statusCode == 200) {
        List<dynamic> parsedListJson = json.decode(utf8.decode(response.body.runes.toList()));
        setState(() {
          blogCategories = List<BlogCategory>.from(parsedListJson.map((i) => BlogCategory.fromJson(i)));
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
