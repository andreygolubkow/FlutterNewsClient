import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:npulse_app/model/Article.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as dom;
import 'package:url_launcher/url_launcher.dart';

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
        title: Text("${article.title}"),
      ),
      body: new Center(
      child: SingleChildScrollView(
    child: Html(
        data: article.text.replaceAll("//sports.kz", "http://sports.kz"),
        //Optional parameters:
        padding: EdgeInsets.all(8.0),
        onLinkTap: (url) {
          _launchURL(url);
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
      )
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
