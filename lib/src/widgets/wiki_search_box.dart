import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';

import '../providers/wikipedia_api.dart';

class WikiSearchBox extends StatelessWidget {
  const WikiSearchBox({
    super.key,
    required this.label,
    required this.controller,
  });
  final String label;
  final TextEditingController controller;

  Widget _imageBuilder(String? url, double height, double width) {
    if (url == null) {
      return Container(
        height: height,
        width: width,
        color: Colors.grey.shade600,
        child: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Icon(Icons.article_outlined),
        ),
      );
    } else {
      return Image.network(
        url,
        width: width,
        height: height,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return TypeAheadFormField<WikiSearchResult>(
      textFieldConfiguration: TextFieldConfiguration(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          border: const OutlineInputBorder(
            gapPadding: 10,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
      ),
      hideOnLoading: true,
      minCharsForSuggestions: 2,
      suggestionsCallback: (pattern) async =>
          pattern.isEmpty ? [] : await wikipedia.search(pattern),
      itemBuilder: (context, results) {
        return ListTile(
          leading: _imageBuilder(results.image, 80, 80),
          title: Text(results.title),
          subtitle: Text(results.description ?? ""),
        );
      },
      onSuggestionSelected: ((suggestion) {
        controller.text = suggestion.title;
      }),
    );
  }
}
