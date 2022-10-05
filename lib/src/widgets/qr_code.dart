import 'package:flutter/material.dart';

class QrCodeWidget extends StatelessWidget {
  const QrCodeWidget({
    super.key,
    this.height = 150,
    this.width = 150,
    required this.data,
  });

  final int height;
  final int width;
  final String data;

  Uri get _url => Uri(
          host: "api.qrserver.com",
          scheme: "https",
          path: "/v1/create-qr-code/",
          queryParameters: {
            "size": "${width}x$height",
            "data": data,
          });

  @override
  Widget build(BuildContext context) {
    return Image.network(_url.toString());
  }
}
