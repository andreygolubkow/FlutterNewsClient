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
import 'package:carousel_pro/carousel_pro.dart';

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
    return article.imageUrl != null && article.imageUrl.length>2;
  }

  Iterable<String> GetImages() {
    var imgs = article.imageUrl.split("\r\n").where((s) => s.length>3);
    return imgs;
    //return imageRegExp.firstMatch(text).group(1);
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
    } else if (IsContainImage(article.text)) {
      var images = GetImages();
      return images.length > 1 ? BuildBigImagesCard(context) :  BuildLeftImageCard(context);
    }
    return BuildTextCard(context);
  }

  BuildLeftImageCard(BuildContext context) {
    //final articleTextNorm =
      //  article.text.replaceAll("//sports.kz", "http://sports.kz");

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
                                      GetImages().first,
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
    /*final articleTextNorm =
        article.text.replaceAll("//sports.kz", "http://sports.kz"); */

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
                  padding: EdgeInsets.all(10) ,
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
    /*final articleTextNorm =
    article.text.replaceAll("//sports.kz", "http://sports.kz");*/

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
                  GetYouTubeLink(article.text),
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

  BuildBigImagesCard(BuildContext context) {
    /*final articleTextNorm =
    article.text.replaceAll("//sports.kz", "http://sports.kz");*/

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
                new SizedBox(
                    height: 200.0,
                    child: new Carousel(
                      images: GetImages().map((i) => new NetworkImage(i)).toList(),
                      boxFit: BoxFit.fitWidth,
                      dotSize: 4.0,
                      dotSpacing: 10.0,
                      dotColor: Colors.white,
                      indicatorBgPadding: 5.0,
                      dotBgColor: Colors.transparent,
                      borderRadius: false,
                    )
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
