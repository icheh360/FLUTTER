import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MJPEG Stream Viewer',
      theme: ThemeData(useMaterial3: true),
      home: const StreamPage(),
    );
  }
}

class StreamPage extends StatelessWidget {
  const StreamPage({super.key});

  final String streamUrl = 'http://honjin1.miemasu.net/nphMotionJpeg?Resolution=640x480&Quality=Standard';
  final String customUserAgent = 'MyCustomUserAgent/1.0';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MJPEG Stream')),
      body: InAppWebView(
        initialUrlRequest: URLRequest(
          url: WebUri(streamUrl),
          headers: {'User-Agent': customUserAgent},
        ),
        initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
            userAgent: customUserAgent,
            mediaPlaybackRequiresUserGesture: false,
            useShouldOverrideUrlLoading: true,
          ),
        ),
      ),
    );
  }
}
