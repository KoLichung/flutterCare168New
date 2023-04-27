import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fluttercare168/notifier_model/require_model.dart';
import 'package:fluttercare168/pages/member/register/login_register.dart';
import 'package:fluttercare168/pages/member/my_service/bank_account.dart';
import 'package:fluttercare168/pages/member/my_service/my_cases_page.dart';
import 'package:fluttercare168/pages/member/resetPassword/reset_password_phone.dart';
import 'package:fluttercare168/pages/requirement_step1_basic.dart';

import 'firebase_options.dart';
import 'notifier_model/booking_model.dart';
import 'pages/search_carer/home_page.dart';
import 'pages/member/member_page.dart';
import 'pages/search_case/search_case_page.dart';
import 'pages/news.dart';
import 'pages/recommend_carers_page.dart';
import 'constant/color.dart';
import 'package:fluttercare168/pages/member/register/register_phone.dart';
import 'package:provider/provider.dart';
import 'notifier_model/user_model.dart';
import 'notifier_model/service_model.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('Handling a background message ${message.messageId}');
}

/// Create a [AndroidNotificationChannel] for heads up notifications
late AndroidNotificationChannel channel;

/// Initialize the [FlutterLocalNotificationsPlugin] package.
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  LineSDK.instance.setup('1657316694').then((_) {
    print('LineSDK Prepared');
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context)=>UserModel(),),
        ChangeNotifierProvider(create: (context)=>ServiceModel(),),
        ChangeNotifierProvider(create: (context)=>RequireModel()),
        ChangeNotifierProvider(create: (context)=>BookingModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child:MaterialApp(
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('zh','TW'),
          ],
          locale: const Locale('zh','TW'),
          theme: ThemeData(
            primaryColor: const Color(0xffCCADE9),
            appBarTheme: const AppBarTheme(
              backgroundColor: AppColor.purple,
              elevation: 0,
            ),
            scaffoldBackgroundColor: const Color(0xffFCFCFC),
          ),
          debugShowCheckedModeBanner: false,
          home: const MyHomePage(),
          routes: {
            '/home_page':(context) => const HomePage(),
            '/bankAccount':(context) => const BankAccount(),
            '/myCases':(context) => const MyCasesPage(),
            '/loginRegister':(context) => const LoginRegister(),
            '/registerPhone':(context) => const RegisterPhone(),
            // '/registerLine':(context) => RegisterLine(),
            '/member_page':(context) => const MemberPage(),
            '/requirementStep1Basic':(context) => const RequirementStep1Basic(),
            '/reset_password_phone':(context) => const ResetPasswordPhone(),
          },
          builder: (context, child){
            return MediaQuery(data: MediaQuery.of(context).copyWith(textScaleFactor: 1.1), child: Container(child: child)
            );
          },
        )
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  Future<void> getAPNSToken() async {
    FirebaseMessaging.instance.requestPermission(
      announcement: true,
      carPlay: true,
      criticalAlert: true,
      alert: true,
      badge: true,
      sound: true,
    );
    print('FlutterFire Messaging Example: Getting APNs token...');
    String? token = await FirebaseMessaging.instance.getAPNSToken();
    print('Got APNs token: $token');
    FirebaseMessaging.instance.getToken().then((token){
      print('the token: ' + token.toString());
      var userModel = context.read<UserModel>();
      userModel.fcmToken = token.toString();
    });
  }

  @override
  void initState() {
    super.initState();

    if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS) {
      getAPNSToken();
    }else{
      FirebaseMessaging.instance.getToken().then((token){
        print('the fcm token: ' + token.toString());
        var userModel = context.read<UserModel>();
        userModel.fcmToken = token.toString();
      });
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      print("message recieved");
      print(event.notification!.body);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('Message clicked!');
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: pageCaller(_selectedIndex),
        ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColor.purple, width: 0.8)),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xffFCFCFC),
          selectedItemColor: AppColor.purple,
          unselectedItemColor: const Color(0xff737273),
          currentIndex: _selectedIndex,
          onTap: (int index){
            setState(() {
              _selectedIndex = index;
            });
          },
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.search), label: '搜索服務者'),
            BottomNavigationBarItem(icon: Icon(Icons.event_available), label: '找案件'),
            BottomNavigationBarItem(icon: Icon(Icons.campaign,size: 26,), label: '最新資訊'),
            BottomNavigationBarItem(icon: Icon(Icons.badge), label: '服務者推薦'),
            BottomNavigationBarItem(icon: Icon(Icons.face), label: '會員中心'),
          ],
        ),
      ),
      );
  }

  pageCaller(int index){
    switch(index){
      case 0:{return const HomePage();}
      case 1:{return const SearchCasePage();}
      case 2:{return const News();}
      case 3:{return const RecommendCarersPage();}
      case 4:{return const MemberPage();}
    }
  }
}
