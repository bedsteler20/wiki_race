import 'dart:convert';

import 'package:http/http.dart' as http;

class WikiSearchResult {
  final String title;
  final String? description;
  final String? image;

  WikiSearchResult({
    required this.title,
    this.description,
    this.image,
  });
}

class WikipediaApi {
  String formatTitle(String title) {
    return title.replaceAll(" ", "_");
  }

  Future<bool> dosePageExist(String title) async {
    final uri = Uri.parse("en.wikipedia.org/api/rest_v1/page/title/$title");
    final res = await http.get(uri);

    if (res.statusCode == 200) {
      return true;
    } else if (res.statusCode == 404) {
      return false;
    } else {
      throw "Wikipedia Error: ${res.statusCode}";
    }
  }

  Future<List<WikiSearchResult>> search(String query, {int limit = 3}) async {
    final url = Uri(
      host: "en.wikipedia.org",
      path: "/w/api.php", // php 🤮,
      scheme: "https",
      queryParameters: {
        "action": "query",
        "format": "json",
        "generator": "prefixsearch",
        "prop": "pageprops|pageimages|description",
        "ppprop": "displaytitle",
        "piprop": "thumbnail",
        "pithumbsize": "80",
        "pilimit": limit.toString(),
        "gpssearch": query,
        "gpsnamespace": "0",
        "gpslimit": limit.toString(),
        "origin": "*",
      },
    );
    final res = await http.get(url);

    if (res.statusCode != 200) {
      throw "Wikipedia Search Error: ${res.statusCode}";
    }

    final data = json.decode(res.body);

    if (data?["query"]?["pages"] == null) {
      throw "Wikipedia Search Error: Invalid Json";
    }

    return [
      for (var page in data["query"]["pages"].values)
        WikiSearchResult(
          title: page["title"],
          description: page["description"],
          image: page["thumbnail"]?["source"],
        ),
    ];
  }
}

final wikipedia = WikipediaApi();
