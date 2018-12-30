import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:npulse_app/ViewWebScreen.dart';
import 'package:npulse_app/model/Article.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as dom;
import 'package:url_launcher/url_launcher.dart';
import 'package:backdrop/backdrop.dart';
import 'package:swipedetector/swipedetector.dart';


class ViewArticleTextScreen extends StatelessWidget {
  // Declare a field that holds the Todo
  final Article article;
  // In the constructor, require a Todo
  ViewArticleTextScreen({Key key, @required this.article}) : super(key: key) ;

 @override
  Widget build(BuildContext context) {
    // Use the Todo to create our UI
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(44, 43, 40, 1),
        title: Text("${article.title}",style: TextStyle(fontSize: 14)),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.open_in_new),
            tooltip: 'Открыть источник',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ViewWebScreen(url: article.sourceUrl),
                ),
              );
            },
          ),
        ],
      ),
      body: new Center(
      child: SwipeDetector(
   onSwipeRight: () {
     Navigator.pop(context);
   },
   child: SingleChildScrollView(
    child: Html(
        data: article.text.replaceAll("//sports.kz", "http://sports.kz"),
        //Optional parameters:
        padding: EdgeInsets.all(8.0),
        onLinkTap: (url) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ViewWebScreen(url: url),
            ),
          );
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
      ),
      ),
      backgroundColor: Color.fromRGBO(245, 239, 221, 1),
    );
  }
}
