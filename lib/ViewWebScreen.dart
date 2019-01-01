import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewWebScreen extends StatelessWidget with RouteAware{
  // Declare a field that holds the Todo
  final String url;
  WebView _web;
  WebViewController _controller;

  ViewWebScreen({Key key, @required this.url}) : super(key: key)
  {
    _web = new WebView(
      initialUrl: url.replaceFirst("www.sports.kz", "m.sports.kz"),
      javaScriptMode: JavaScriptMode.disabled,
      onWebViewCreated: (c) {
        _controller = c;
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    // Use the Todo to create our UI
    return new Scaffold(
      appBar:  AppBar(
        backgroundColor: Color.fromRGBO(44, 43, 40, 1),
        title: Text(url, style: TextStyle(fontSize: 14),),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.open_in_new),
            tooltip: 'Открыть источник',
            onPressed: () async {
              var url = await _controller.currentUrl();
              _launchURL(url);
            },
          ),
        ],
      ),
      body: Center(
        child: _web,
      ),
    );
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}