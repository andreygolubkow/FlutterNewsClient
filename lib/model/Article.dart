class Article {
  final int id;
  final String title;
  final String text;
  final String imageUrl;
  final String sourceUrl;
  final String mobileUrl;
  final DateTime lastModifyDateTime;


  const Article({
    this.id,
    this.title,
    this.text,
    this.imageUrl,
    this.sourceUrl,
    this.lastModifyDateTime,
    this.mobileUrl
  });

  Article.fromMap(Map<String, dynamic>  map) :
        id = map['Id'],
        title = map['Title'],
        text = map['Text'],
        imageUrl = map['ImageUrl'],
        sourceUrl = map['SourceUrl'],
        lastModifyDateTime = DateTime.parse(map['LastModifyDateTime']),
            mobileUrl = map['MobileUrl'];
}