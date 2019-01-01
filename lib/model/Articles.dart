import 'Article.dart';

class Articles {
  final List<Article> articles;
  final String odatacontext;
  String odatanextLink;


  Articles(this.articles, this.odatacontext, this.odatanextLink);

  Articles.fromMap(Map<String, dynamic> map)
      : articles = new List<Article>.from(map['value'].map((article) => new Article.fromMap(article))),
        odatacontext = map['@odata.context'],
        odatanextLink = map['@odata.nextLink'];
}