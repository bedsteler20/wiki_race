import 'package:flutter/material.dart';

class WikiImage extends StatelessWidget {
  const WikiImage({
    super.key,
    required this.height,
    required this.width,
    this.url,
  });

  final double height;
  final double width;
  final String? url;

  @override
  Widget build(BuildContext context) {
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
        url!,
        width: width,
        height: height,
      );
    }
  }
}
