import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:swipedetector/swipedetector.dart';

class ViewWebScreen extends StatelessWidget {
  // Declare a field that holds the Todo
  final String url;
  WebViewController _controller;
  // In the constructor, require a Todo
  ViewWebScreen({Key key, @required this.url}) : super(key: key) ;

  @override
  Widget build(BuildContext context) {
    // Use the Todo to create our UI
    return new Scaffold(
      appBar:  AppBar(
        backgroundColor: Color.fromRGBO(44, 43, 40, 1),
        title: Text(url, style: TextStyle(fontSize: 14),),
      ),
      body: Center(
        child: new WebView(
            initialUrl: url.replaceFirst("www.sports.kz", "m.sports.kz"),
            javaScriptMode: JavaScriptMode.disabled,
        ),
      ),
    );
  }
}