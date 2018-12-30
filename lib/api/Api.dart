
/*final String BASE_URL =
    "http://deembedding.azurewebsites.net/odata/Articles?\$orderby=lastmodifydatetime%20desc";
*/

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:npulse_app/model/Articles.dart';


class Api {
  static const BASE_URL =
      "http://deembedding.azurewebsites.net/odata/Articles?\$orderby=lastmodifydatetime%20desc";
  static String GetUrlByCount(int count)
  {
    return "https://deembedding.azurewebsites.net/odata/Articles?\$orderby=lastmodifydatetime%20desc&\$skip=$count";
  }

  static String GetUrlByDateTime(DateTime dateTime)
  {
    return "https://deembedding.azurewebsites.net/odata/Articles?\$orderby=lastmodifydatetime%20desc&\$filter=LastModifyDateTime%20gt%20${dateTime.toIso8601String()}";
  }

  static Future<Articles> fetchArticles(String url) async {
    final response =
    await http.get(url);

    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON
      return Articles.fromMap(json.decode(response.body));
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load post');
    }
  }

}
