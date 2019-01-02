import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:npulse_app/RuTimeMessages.dart';
import 'package:npulse_app/ViewArticleTextScreen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:npulse_app/model/Article.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutube/flutube.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:auto_size_text/auto_size_text.dart';

class ArticleItem extends StatelessWidget {
  final FirebaseAnalytics analytics;

  ArticleItem({Key key, @required this.article, this.shape, this.analytics})
      : assert(article != null),
        super(key: key) {
    timeago.setLocaleMessages('ru', RuTimeMessages());
  }

  final Article article;
  final ShapeBorder shape;
  final RegExp iframeVideoRegExp =
      new RegExp("<iframe[^>]* src=\"([\^\"]*)\"[^>]*>");
  final RegExp youTubeRegExp = new RegExp(
      "((?:https?:\\/\\/)?(?:www\\.)?youtu\\.?be(?:\.com)?\\/?.*(?:watch|embed)?(?:.*v=|v\\/|\\/)([\\w\\-_]+)\\&?)\"");
  final RegExp imageRegExp = new RegExp("<img[^>]* src=\"([\^\"]*)\"[^>]*>");
  final RegExp firstLetter = new RegExp("([A-zА-я])");

  String timeFormat(DateTime date) {
    return timeago.format(date, locale: "ru");
  }

  double getMainCardWidth(BuildContext context) {
    double fullWidth = MediaQuery.of(context).size.width;
    return fullWidth - getImageCardWidth(context) - fullWidth * 0.05;
  }

  double getImageCardWidth(BuildContext context) {
    return MediaQuery.of(context).size.width * 0.3;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        top: false, bottom: false, child: Center(child: BuildCard(context)));
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  bool IsContainImage(String text) {
    return imageRegExp.hasMatch(text);
  }

  String GetFirstImage(String text) {
    return imageRegExp.firstMatch(text).group(1);
  }

  bool IsContainYouTube(String text) {
    return youTubeRegExp.hasMatch(article.text);
  }

  String GetYouTubeLink(String text) {
    return "https://www.youtube.com/watch?v=${youTubeRegExp.firstMatch(article.text).group(2)}";
  }

  String CutTitle(String title) {
    int maxChars = 70;
    if (title.length <= maxChars) {
      return title;
    }
    int space = 0;
    for (int i = maxChars; i >= 0; i--) {
      if (title[i] == ' ') {
        space = i;
        break;
      }
    }
    return "${title.substring(0, space)}...";
  }

  Widget BuildCard(BuildContext context) {
    if (IsContainYouTube(article.text)) {
      return BuildVideoCard(context);
    } else {
      return IsContainImage(article.text) ? BuildLeftImageCard(context) : BuildTextCard(context);
    }
  }

  BuildLeftImageCard(BuildContext context) {
    final articleTextNorm =
        article.text.replaceAll("//sports.kz", "http://sports.kz");

    return new GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            PageTransition(
                type: PageTransitionType.rightToLeft,
                child: ViewArticleTextScreen(article, analytics)),
          );
        },
        child: Card(
            margin: EdgeInsets.fromLTRB(0, 4, 0, 4),
            elevation: 2,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Container(
                  //padding: const EdgeInsets.all(32.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Flex(
                        direction: Axis.vertical,
                        children: <Widget>[
                          Align(
                            child: Container(
                              width: getImageCardWidth(context),
                              height: getImageCardWidth(context),
                              padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
                              child: ClipRRect(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(0),
                                      topRight: Radius.circular(10),
                                      bottomLeft: Radius.circular(0),
                                      bottomRight: Radius.circular(10)),
                                  child: AspectRatio(
                                    aspectRatio: 1,
                                    child: Image.network(
                                      GetFirstImage(articleTextNorm),
                                      fit: BoxFit.fitHeight,
                                    ),
                                  )),
                            ),
                          )
                        ],
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            RichText(
                              maxLines:5,
                              text:
                              TextSpan(
                                style: TextStyle( color: Colors.black),
                                children: <TextSpan>[
                                  TextSpan(text: CutTitle(article.title), style: TextStyle(
                                      fontSize: 16, fontFamily: "NotoSerif")),
                                  TextSpan(text: "\n",style: TextStyle(
                                      fontSize: 16, fontFamily: "NotoSerif")),
                                  TextSpan(
                                      text:
                                      '${timeFormat(article.lastModifyDateTime)}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w200, fontSize: 12)),
                                ],
                              ),
                            )
                            //Text(CutTitle(article.title)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )));
  }

  BuildTextCard(BuildContext context) {
    final articleTextNorm =
        article.text.replaceAll("//sports.kz", "http://sports.kz");

    return new GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            PageTransition(
                type: PageTransitionType.rightToLeft,
                child: ViewArticleTextScreen(article, analytics)),
          );
        },
        child: Card(
            margin: EdgeInsets.fromLTRB(0, 4, 0, 4),
            elevation: 2,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Container(
                  child: RichText(
                    maxLines:5,
                    text:
                    TextSpan(
                      style: TextStyle(
                          fontSize: 12, color: Colors.black),
                      children: <TextSpan>[
                        TextSpan(text: CutTitle(article.title), style: TextStyle(
                            fontSize: 16, fontFamily: "NotoSerif")),
                        TextSpan(text: "\n"),
                        TextSpan(
                            text:
                            '${timeFormat(article.lastModifyDateTime)}',
                            style: TextStyle(
                                fontWeight: FontWeight.w200)),
                      ],
                    ),
                  ),
                ),
              ],
            )));
  }

  BuildVideoCard(BuildContext context) {
    final articleTextNorm =
    article.text.replaceAll("//sports.kz", "http://sports.kz");

    return new GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            PageTransition(
                type: PageTransitionType.rightToLeft,
                child: ViewArticleTextScreen(article, analytics)),
          );
        },
        child: Card(
            margin: EdgeInsets.fromLTRB(0, 4, 0, 4),
            elevation: 2,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                FluTube(
                  GetYouTubeLink(articleTextNorm),
                  autoInitialize: true,
                  looping: true,
                  aspectRatio: (16 / 9),
                  onVideoStart: () {
                    analytics.logViewItem(
                        itemId: article.id.toString(),
                        itemName: article.title,
                        itemCategory: "Video");
                  },
                ),
                Container(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(CutTitle(article.title)),
                            Container(
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.black),
                                  children: <TextSpan>[
                                    TextSpan(
                                        text:
                                        '${timeFormat(article.lastModifyDateTime)}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w200)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )));
  }
}
