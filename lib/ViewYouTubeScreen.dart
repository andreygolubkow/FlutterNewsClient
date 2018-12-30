import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:npulse_app/model/Article.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as dom;
import 'package:http/http.dart' as http;

class ViewYouTubeScreen extends StatelessWidget {
  // Declare a field that holds the Todo
  final Article article;
  final String url;

  // In the constructor, require a Todo
  ViewYouTubeScreen({Key key, @required this.article, @required this.url}) : super(key: key) ;

  @override
  Widget build(BuildContext context) {
    // Use the Todo to create our UI
    return Scaffold(
        appBar: AppBar(
          title: Text("${article.title}"),
        ),
        body: FutureBuilder<http.Response>(
          future: http.get(url),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return
                new Center(
                    child: SingleChildScrollView(
                        child: Html(
                            data: snapshot.data.body,
                            padding: EdgeInsets.all(8.0),
                            onLinkTap: (url) {
                              print("Opening $url...");
                            },
                            customRender: (node, children) {
                              if (node is dom.Element) {
                                switch (node.localName) {
                                  case "custom_tag":
                                    return Column(children: children);
                                }
                              }
                            }
                        )
                    )
                );
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }

            // By default, show a loading spinner
            return CircularProgressIndicator();
          },
        )
    );
  }

}