import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttercare168/pages/member/order_management/reviews_given_tab.dart';
import 'package:fluttercare168/pages/member/order_management/reviews_received_tab.dart';
import 'package:fluttercare168/pages/member/order_management/reviews_unrated_tab.dart';

class ReviewsPage extends StatefulWidget {
  const ReviewsPage({Key? key}) : super(key: key);
  @override
  _ReviewsPageState createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          elevation: 2,
          shadowColor: Colors.black26,
          title: const Text('評價'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50.0),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 1),
              child: const TabBar(
                // indicatorWeight: 4,
                indicatorPadding: EdgeInsets.symmetric(vertical: 8),
                labelColor: Colors.white,
                indicatorColor: Colors.white,
                indicatorSize: TabBarIndicatorSize.label,
                tabs: [
                  Tab(text: '尚未評價',),
                  Tab(text: '我的評價',),
                  Tab(text: '給我的評價',),
                ],
              ),
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            ReviewsUnratedTab(),
            ReviewsGivenTab(),
            ReviewsReceivedTab(),
          ],
        ),
      ),
    );
  }

}
