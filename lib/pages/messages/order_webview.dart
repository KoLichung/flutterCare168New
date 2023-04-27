import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class OrderWebview extends StatefulWidget {
  final String initUrl;

  const OrderWebview({Key? key, required this.initUrl}) : super(key: key);

  @override
  State<OrderWebview> createState() => _WebViewState();
}

class _WebViewState extends State<OrderWebview> {

  double progressDouble = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      appBar: AppBar(
        title: const Text('訂單付款'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          (progressDouble!=1.toDouble())?
          LinearProgressIndicator(
            value: progressDouble,
          )
              :
          Container()
          ,
          Expanded(
              child:WebView(
                initialUrl: widget.initUrl,
                javascriptMode: JavascriptMode.unrestricted,
                onProgress: (int progress) {
                  setState(() {
                    progressDouble = progress.toDouble() / 100 ;
                  });
                  print('WebView is loading (progress : $progress  %)');
                },
                onPageStarted: (url){
                  if(url.contains("success_pay")){
                    Navigator.pop(context, "reload");
                  }
                },
              )
          ),
        ],
      )
    );
  }
}