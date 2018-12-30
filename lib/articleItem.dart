import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:npulse_app/ViewArticleTextScreen.dart';

import 'package:npulse_app/model/Article.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutube/flutube.dart';

class ArticleItem extends StatelessWidget {
  ArticleItem({ Key key, @required this.article, this.shape })
      : assert(article != null),
        super(key: key);

  final Article article;
  final ShapeBorder shape;
  final DateFormat dateFormat = new DateFormat("HH:mm dd.MM.yyyy");
  final RegExp iframeVideoRegExp = new RegExp("<iframe[^>]* src=\"([\^\"]*)\"[^>]*>");
  final RegExp youTubeRegExp = new RegExp("((?:https?:\\/\\/)?(?:www\\.)?youtu\\.?be(?:\.com)?\\/?.*(?:watch|embed)?(?:.*v=|v\\/|\\/)([\\w\\-_]+)\\&?)\"");
  final RegExp imageRegExp = new RegExp("<img[^>]* src=\"([\^\"]*)\"[^>]*>");


  @override
  Widget build(BuildContext context) {

    return SafeArea(
      top: false,
      bottom: false,
      child: Center(
        child: BuildCard(context)
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

  bool IsContainImage(String text)
  {
    return imageRegExp.hasMatch(text);
  }

  String GetFirstImage(String text)
  {
    return imageRegExp.firstMatch(text).group(1);
  }

  bool IsContainYouTube(String text)
  {
    return youTubeRegExp.hasMatch(article.text);
  }

  String GetYouTubeLink(String text)
  {
    return "https://www.youtube.com/watch?v=${youTubeRegExp.firstMatch(article.text).group(2)}";
  }

  BuildTextCard(BuildContext context)
  {
    final articleTextNorm = article.text.replaceAll("//sports.kz", "http://sports.kz");
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: ClipRRect(
              child: IsContainImage(articleTextNorm) ? new CachedNetworkImage(
                imageUrl: GetFirstImage(articleTextNorm),
                placeholder: new CircularProgressIndicator(),
                errorWidget: new Icon(Icons.error),
                fit: BoxFit.cover,
                width: 70.0,
                height: 70.0,
              ) : new Icon(Icons.photo),
              borderRadius: BorderRadius.circular(10),
            ),
            title: Text(article.title),
            subtitle: Text('${dateFormat.format(article.lastModifyDateTime.toLocal())}'),
          ),
          ButtonTheme.bar( // make buttons use the appropriate styles for cards
            child: ButtonBar(
              children: <Widget>[
                FlatButton(
                  child: const Text('Читать'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewArticleTextScreen(article: article),
                      ),
                    );
                  },
                ),
                /*iframeVideoRegExp.firstMatch(article.text) != null ? FlatButton(
                  child: const Text('Смотреть'),
                  onPressed: () {
                    _launchURL(iframeVideoRegExp.firstMatch(article.text).group(1));
                  },
                ):null ,*/
              ],
            ),
          ),
        ],
      ),
    );
  }

  BuildVideoCard(BuildContext context)
  {
    final articleTextNorm = article.text.replaceAll("//sports.kz", "http://sports.kz");
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
              FluTube(
                  GetYouTubeLink(articleTextNorm),
                  autoInitialize: true,
                  looping: true,
                  aspectRatio: 16 / 9
                ),
          ListTile(
            title: Text(article.title),
            subtitle: Text('${dateFormat.format(article.lastModifyDateTime.toLocal())}'),
          ),
          ButtonTheme.bar( // make buttons use the appropriate styles for cards
            child: ButtonBar(
              children: <Widget>[
                FlatButton(
                  child: const Text('Читать'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewArticleTextScreen(article: article),
                      ),
                    );
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Card BuildCard(BuildContext context)
  {
    if (IsContainYouTube(article.text))
    {
      return BuildVideoCard(context);
    } else {
      return BuildTextCard(context);
    }
  }
}


