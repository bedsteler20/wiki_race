import 'package:flutter/material.dart';
import 'package:webviewx/webviewx.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

class WikiFrame extends StatefulWidget {
  const WikiFrame({
    super.key,
    required this.onPageChange,
    required this.startPage,
  });

  final void Function(String title) onPageChange;
  final String startPage;
  @override
  State<WikiFrame> createState() => _WikiFrameState();
}

class _WikiFrameState extends State<WikiFrame> {
  late WebViewXController webviewController;

  Future<String> _loadContent(String title) async {
    final u =
        Uri.parse("https://en.wikipedia.org/api/rest_v1/page/html/$title");
    final res = await http.get(u);
    final html = parse(res.body);

    for (var element in html.getElementsByTagName("a")) {
      element.attributes["href"] =
          "javascript:navigateMessage('${element.attributes["href"]}');";
    }

    return html.outerHtml;
  }

  void _onLinkClick(dynamic url) async {
    if (url.runtimeType != String) return;

    if (!(url as String).startsWith("./")) return;

    final String u = (url).replaceFirst("./", "");

    final content = await _loadContent(u);
    widget.onPageChange(u); // TODO: Sanitize input better
    webviewController.loadContent(content, SourceType.html);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadContent("https://${widget.startPage}"),
      builder: (context, data) {
        if (data.hasData) {
          return WebViewX(
            onWebViewCreated: (controller) {
              webviewController = controller;
            },
            dartCallBacks: {
              DartCallback(
                name: "navigateMessageCallback",
                callBack: _onLinkClick,
              )
            },
            jsContent: const {
              EmbeddedJsContent(
                mobileJs:
                    "function navigateMessage(m) {navigateMessageCallback.postMessage(m)}",
                webJs:
                    "function navigateMessage(m) {navigateMessageCallback(m)}",
              )
            },
            initialContent: data.data!,
            initialSourceType: SourceType.html,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
          );
        } else {
          return Container();
        }
      },
    );
  }
}
