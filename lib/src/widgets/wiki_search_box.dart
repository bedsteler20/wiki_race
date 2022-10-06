import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';
import 'package:wiki_race/src/widgets/wiki_image.dart';

import '../providers/wikipedia_api.dart';

class WikiSearchBox extends StatelessWidget {
  const WikiSearchBox({
    super.key,
    required this.label,
    required this.controller,
  });
  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TypeAheadFormField<WikiSummery>(
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
          leading: WikiImage(
            height: 80,
            width: 80,
            url: results.image,
          ),
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
