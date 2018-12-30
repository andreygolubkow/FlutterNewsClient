import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:npulse_app/ViewArticleTextScreen.dart';

import 'package:npulse_app/model/Article.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutube/flutube.dart';

class ArticleItem extends StatelessWidget {
  ArticleItem({Key key, @required this.article, this.shape})
      : assert(article != null),
        super(key: key);

  final Article article;
  final ShapeBorder shape;
  final DateFormat timeFormat = new DateFormat("HH:mm");
  final DateFormat dateFormat = new DateFormat("dd.MM.yyyy");
  final RegExp iframeVideoRegExp =
      new RegExp("<iframe[^>]* src=\"([\^\"]*)\"[^>]*>");
  final RegExp youTubeRegExp = new RegExp(
      "((?:https?:\\/\\/)?(?:www\\.)?youtu\\.?be(?:\.com)?\\/?.*(?:watch|embed)?(?:.*v=|v\\/|\\/)([\\w\\-_]+)\\&?)\"");
  final RegExp imageRegExp = new RegExp("<img[^>]* src=\"([\^\"]*)\"[^>]*>");

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

  BuildTextCard(BuildContext context) {
    final articleTextNorm =
        article.text.replaceAll("//sports.kz", "http://sports.kz");
    return new GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewArticleTextScreen(article: article),
            ),
          );
        },
        child: Card(
          margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
          elevation: 0,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              ListTile(
                  leading: IsContainImage(articleTextNorm)
                      ? ClipRRect(
                          child: new CachedNetworkImage(
                            imageUrl: GetFirstImage(articleTextNorm),
                            placeholder: new CircularProgressIndicator(),
                            errorWidget: new Icon(Icons.error),
                            fit: BoxFit.cover,
                            width: 70.0,
                            height: 70.0,
                          ),
                          borderRadius: BorderRadius.circular(2),
                        )
                      : null,
                  subtitle: Text(article.title, style: TextStyle(fontSize: 15)),
                  title: RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 12, color: Colors.black),
                      children: <TextSpan>[
                        TextSpan(
                            text:
                                '${timeFormat.format(article.lastModifyDateTime.toLocal())}',
                            style: TextStyle(fontWeight: FontWeight.w500)),
                        TextSpan(
                            text:
                                ' ${dateFormat.format(article.lastModifyDateTime.toLocal())}',
                            style: TextStyle(fontWeight: FontWeight.w300)),
                      ],
                    ),
                  ))
            ],
          ),
        ));
  }

  BuildVideoCard(BuildContext context) {
    final articleTextNorm =
        article.text.replaceAll("//sports.kz", "http://sports.kz");
    return Card(
      margin: EdgeInsets.fromLTRB(0, 5, 1, 0),
      elevation: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          FluTube(
            GetYouTubeLink(articleTextNorm),
            autoInitialize: true,
            looping: true,
            aspectRatio: (16 / 9),
          ),
          new GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewArticleTextScreen(article: article),
                ),
              );
            },
            child: ListTile(
              title: Text(article.title),
              subtitle: RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 12, color: Colors.black),
                  children: <TextSpan>[
                    TextSpan(
                        text:
                            '${timeFormat.format(article.lastModifyDateTime.toLocal())}',
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    TextSpan(
                        text:
                            ' ${dateFormat.format(article.lastModifyDateTime.toLocal())}',
                        style: TextStyle(fontWeight: FontWeight.w300)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget BuildCard(BuildContext context) {
    if (IsContainYouTube(article.text)) {
      return BuildVideoCard(context);
    } else {
      return BuildTextCard(context);
    }
  }
}
