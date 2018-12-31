import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:npulse_app/api/Api.dart';
import 'package:npulse_app/model/Article.dart';
import 'package:npulse_app/model/Articles.dart';
import 'articleItem.dart';
import 'package:incrementally_loading_listview/incrementally_loading_listview.dart';
import "package:pull_to_refresh/pull_to_refresh.dart";

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
        home: MainPage(title: mainNews));
  }
}

class MainPage extends StatelessWidget {
  final String title;
  ScrollController _scrollViewController;

  MainPage({Key key, @required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new NestedScrollView(
        controller: _scrollViewController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            new SliverAppBar(
              title: new Text("asdsad"),
              pinned: true,
              floating: true,
              forceElevated: innerBoxIsScrolled,
            ),
          ];
        },
        body: new Text("sad")
      ),
    );
  }

  /*@override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 2,
          title: Text(title),
        ),
        body: Center(
            child: FutureBuilder<Articles>(
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
        )));
  }
  */

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
  Articles articles;

  RefreshController _refreshController;

  _CardsListState(this.articles);

  @override
  void initState() {
    _refreshController = new RefreshController();
    super.initState();
  }

  void _fetch() {
    while (isLoading)
      {
        //Lock
      }
    isLoading = true;
    Api.fetchArticles(Api.GetUrlByCount(articles.articles.length))
        .then((data)
    {
        if (data.articles.length == 0)
          {
            _refreshController.sendBack(false, RefreshStatus.noMore);
            new Future.delayed(const Duration(milliseconds: 2000)).then((val) {
              _refreshController.sendBack(false, RefreshStatus.idle);
            });
          }

        for (var item in data.articles)
        {
          if (!articles.articles.any((a) {return a.id == item.id; }))
          {
            articles.articles.add(item);
          }
        }
        articles.odatanextLink = data.odatanextLink;
          setState(() {});
        _refreshController.sendBack(false, RefreshStatus.idle);
        isLoading = false;
    }).catchError((e) {
      _refreshController.sendBack(false, RefreshStatus.failed);
      isLoading = false;
    });
  }

  void _update() {
    while (isLoading)
      {//Lock
      }
      isLoading = true;
    var url = articles.articles.length > 0 ? Api.GetUrlByDateTime(articles.articles.first.lastModifyDateTime) : Api.BASE_URL;
    Api.fetchArticles(url)
        .then((data)
    {
      //Если все новости поместились на 1 страницу, то добавим их в список.
      if (data.odatanextLink == null)
      {
          var articlesList = new List<Article>();
          for (var item in data.articles)
          {
            if (!articles.articles.any((a) {return a.id == item.id; }))
            {
              articlesList.add(item);
            }
          }
          articles.articles.insertAll(0, articlesList);
        } else //Иначе, просто заменим список.
        {
          articles.articles.clear();
          articles.articles.addAll(data.articles);
        }
        setState(() {});
      _refreshController.sendBack(true, RefreshStatus.completed);
      isLoading = false;
    }).catchError((e) {
      _refreshController.sendBack(true, RefreshStatus.failed);
      isLoading = false;
    });
  }

  void _onRefresh(bool up) {
    if (up) {
      if (!isLoading)
        {
          _update();
        }
    }
    else {
      if (!isLoading)
      {
        _fetch();
      }
    }
  }

  Widget _headerCreate(BuildContext context, int mode) {
    return new ClassicIndicator(
      mode: mode,
      failedText: "Произошла ошибка",
      releaseText: "Отпустите, что бы обновить",
      refreshingText: 'Обновляем...',
      completeText: "Лента обновлена",
      idleIcon: const Icon(Icons.arrow_upward),
      idleText: 'Обновить ленту?',
    );
  }

  Widget _footerCreate(BuildContext context, int mode) {
    return new ClassicIndicator(
      mode: mode,
      noDataText: "Новостей больше нет",
      failedText: "Произошла ошибка",
      releaseText: "Отпустите, что бы загрузить",
      refreshingText: 'Загружаем...',
      idleIcon: const Icon(Icons.arrow_upward),
      releaseIcon: const Icon(Icons.arrow_downward),
      idleText: 'Загрузить еще ?',
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: new SmartRefresher(
            enablePullDown: true,
            enablePullUp: true,
            controller: _refreshController,
            onRefresh: _onRefresh,
            headerBuilder: _headerCreate,
            footerBuilder: _footerCreate,
            footerConfig: new RefreshConfig(triggerDistance: 0),
            child: new ListView.builder(
              itemCount: articles.articles.length,
              itemBuilder: (context, index) {
                return new ArticleItem(article: articles.articles[index]);
              },
            )));
  }
}
