import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:npulse_app/api/Api.dart';
import 'package:npulse_app/model/Articles.dart';
import 'articleItem.dart';
import 'package:incrementally_loading_listview/incrementally_loading_listview.dart';

final Api _api = Api();

void main() => runApp(MainApp());

class MainApp extends StatelessWidget {
  MainApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appName = 'NPulse';
    final mainNews = 'Главные новости';

    return MaterialApp(
      title: appName,
      theme: ThemeData(
        // Define the default Brightness and Colors
        brightness: Brightness.light,
        primaryColor: Colors.green,
        accentColor: Colors.indigo,
      ),
      home:
        MainPage(
          title: mainNews
        )
    );
  }
}

class MainPage extends StatelessWidget {
  final String title;

  MainPage({Key key, @required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child:
        FutureBuilder<Articles>(
          future: Api.fetchArticles(Api.BASE_URL),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return CardsList(snapshot.data);
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }

            // By default, show a loading spinner
            return CircularProgressIndicator();
          },
        )
      )
    );
  }
}

class CardsList extends StatefulWidget {
  static const String routeName = '/material/cards';
  Articles articles;

  CardsList(this.articles);

  @override
  _CardsListState createState() => new _CardsListState(articles);
}

class _CardsListState extends State<CardsList> {
  ShapeBorder _shape;
  bool isLoading = false;
  final Articles articles;

  ScrollController controller;

  _CardsListState(this.articles);

  void addArticles(Articles a)
  {
    articles.articles.addAll(a.articles);
    articles.odatanextLink = a.odatanextLink;
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Scrollbar(
        child: IncrementallyLoadingListView(
          hasMore: () => articles.odatanextLink != null,
        itemCount: () => articles.articles.length,
        loadMore: () async {
          // can shorten to "loadMore: _loadMoreItems" but this syntax is used to demonstrate that
          // functions with parameters can also be invoked if needed
          if (isLoading)
            return;
          isLoading = true;
          await Api.fetchArticles(articles.odatanextLink).then(
                  (v) => addArticles(v));
        },
        loadMoreOffsetFromBottom: 2,
        itemBuilder: (context, index) {
          return ArticleItem(article: articles.articles[index]);
        })
      ),
    );
  }

}