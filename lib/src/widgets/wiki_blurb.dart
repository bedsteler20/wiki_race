import 'package:flutter/material.dart';
import 'package:wiki_race/src/helpers/flutter.dart';

class WikiBlurb extends StatelessWidget {
  const WikiBlurb({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width,
      height: 100,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
    );
  }
}
