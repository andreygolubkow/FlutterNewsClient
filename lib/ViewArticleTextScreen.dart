import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:npulse_app/ViewWebScreen.dart';
import 'package:npulse_app/model/Article.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as dom;
import 'package:page_transition/page_transition.dart';
import 'package:swipedetector/swipedetector.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

class ViewArticleTextScreen extends StatefulWidget {
  final FirebaseAnalytics analytics;

  final Article _article;

  ViewArticleTextScreen(this._article, this.analytics){}

  @override
  ViewArticleTextScreenState createState() => ViewArticleTextScreenState(article: this._article, key: this.key, analytics: analytics);


}

class ViewArticleTextScreenState extends State<ViewArticleTextScreen> {

  final Article article;
  final FirebaseAnalytics analytics;
  final RegExp youTubeRegExp = new RegExp(
      "((?:https?:\\/\\/)?(?:www\\.)?youtu\\.?be(?:\.com)?\\/?.*(?:watch|embed)?(?:.*v=|v\\/|\\/)([\\w\\-_]+)\\&?)\"");

  ViewArticleTextScreenState({Key key, @required this.article, this.analytics});

  @override
  void initState() {
    super.initState();
    analytics.setCurrentScreen(
      screenName: 'ViewText/${article.id}',
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool IsContainYouTube(String text) {
    return youTubeRegExp.hasMatch(article.text);
  }

  @override
  Widget build(BuildContext context) {
    analytics.setUserProperty(name: "lastArticle", value: article.id.toString() );
    // Use the Todo to create our UI
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.black,
              title: Text("${article.title}", style: TextStyle(fontSize: 14)),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.open_in_new),
                  tooltip: 'Открыть источник',
                  onPressed: () {
                    analytics.logViewItem(itemId: article.id.toString(), itemName: article.title, itemCategory: "Web");
                    analytics.setCurrentScreen(
                      screenName: 'Web/${article.id}',
                    );
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
                          data: article.text,
                          //Optional parameters:
                          padding: EdgeInsets.all(8.0),
                          onLinkTap: (url) {
                            analytics.setCurrentScreen(screenName: "Web/${url}");
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
