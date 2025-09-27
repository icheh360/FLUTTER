import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'dart:isolate';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: StreamPage(),
    );
  }
}

class StreamPage extends StatefulWidget {
  const StreamPage({super.key});

  @override
  State<StreamPage> createState() => _StreamPageState();
}

class _StreamPageState extends State<StreamPage> {
  Uint8List? liveImage;
  Uint8List? processedImage;
  Timer? timer;

  final String streamUrl = 'http://honjin1.miemasu.net/nphMotionJpeg?Resolution=640x480&Quality=Standard'; // لینک استریم

  @override
  void initState() {
    super.initState();
    startStream();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void startStream() {
    timer = Timer.periodic(const Duration(milliseconds: 30), (_) async {
      try {
        final response = await http.get(Uri.parse(streamUrl));
        if (response.statusCode == 200) {
          Uint8List bytes = response.bodyBytes;
          setState(() {
            liveImage = bytes;
          });
          // پردازش تصویر در isolate
          FlutterIsolate.spawn(processImage, [bytes, ReceivePort().sendPort])
              .then((isolate) {});
        }
      } catch (e) {
        // ignore network errors
      }
    });
  }

  // Isolate برای پردازش تصویر
  static void processImage(List<dynamic> params) async {
    Uint8List bytes = params[0];
    SendPort sendPort = params[1];

    img.Image? image = img.decodeImage(bytes);
    if (image != null) {
      // مثال پردازش: grayscale
      img.grayscale(image);
      Uint8List processed = Uint8List.fromList(img.encodeJpg(image));
      sendPort.send(processed);
    }
  }

  // دکمه عکس گرفتن
  Future<void> capturePhoto() async {
    if (liveImage != null) {
      final dir = await getTemporaryDirectory();
      String filePath = '${dir.path}/photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
      File file = File(filePath);
      await file.writeAsBytes(liveImage!);
      await GallerySaver.saveImage(file.path);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Photo saved to gallery')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Stream & Processing')),
      body: Column(
        children: [
          // نمایش تصویر زنده
          Expanded(
            child: Container(
              color: Colors.black,
              child: liveImage != null
                  ? Image.memory(liveImage!, fit: BoxFit.cover)
                  : const Center(child: CircularProgressIndicator()),
            ),
          ),
          // نمایش تصویر پردازش شده
          Expanded(
            child: Container(
              color: Colors.grey[900],
              child: processedImage != null
                  ? Image.memory(processedImage!, fit: BoxFit.cover)
                  : const Center(child: Text('Processed image here', style: TextStyle(color: Colors.white))),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(onPressed: capturePhoto, child: const Text('Capture Photo')),
              ElevatedButton(
                  onPressed: () async {
                    // نمایش گالری (می‌تونی بسته‌های گالری یا فایل منیجر استفاده کنی)
                  },
                  child: const Text('Open Gallery')),
            ],
          ),
        ],
      ),
    );
  }
}
