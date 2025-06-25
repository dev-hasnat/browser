import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Desktop View Browser',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DesktopWebView(),
    );
  }
}

class DesktopWebView extends StatefulWidget {
  @override
  _DesktopWebViewState createState() => _DesktopWebViewState();
}

class _DesktopWebViewState extends State<DesktopWebView> {
  InAppWebViewController? webViewController;
  final urlController = TextEditingController(text: "https://www.google.com");
  final List<String> bookmarks = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: urlController,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Enter URL",
            hintStyle: TextStyle(color: Colors.white54),
            border: InputBorder.none,
          ),
          onSubmitted: (url) {
            _loadUrl(url);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () async {
              if (webViewController != null && await webViewController!.canGoBack()) {
                webViewController!.goBack();
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward),
            onPressed: () async {
              if (webViewController != null && await webViewController!.canGoForward()) {
                webViewController!.goForward();
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.bookmark),
            onPressed: () async {
              var url = (await webViewController?.getUrl())?.toString();
              if (url != null && !bookmarks.contains(url)) {
                setState(() {
                  bookmarks.add(url);
                });
              }
            },
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.menu),
            onSelected: (value) => _loadUrl(value),
            itemBuilder: (context) => bookmarks
                .map((url) => PopupMenuItem(
                      value: url,
                      child: Text(url, overflow: TextOverflow.ellipsis),
                    ))
                .toList(),
          )
        ],
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: Uri.parse("https://www.google.com")),
        initialSettings: InAppWebViewSettings(
          userAgent: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36",
          useWideViewPort: true,
          loadWithOverviewMode: true,
          javaScriptEnabled: true,
          mediaPlaybackRequiresUserGesture: false,
          supportZoom: true,
          builtInZoomControls: true,
          displayZoomControls: false,
        ),
        onWebViewCreated: (controller) {
          webViewController = controller;
        },
        onTitleChanged: (controller, title) async {
          var url = await controller.getUrl();
          if (url != null) {
            urlController.text = url.toString();
          }
        },
      ),
    );
  }

  void _loadUrl(String url) {
    if (!url.startsWith("http")) {
      url = "https://" + url;
    }
    webViewController?.loadUrl(urlRequest: URLRequest(url: Uri.parse(url)));
  }
}
