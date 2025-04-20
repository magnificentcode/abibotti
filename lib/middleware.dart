import 'dart:io';
import 'package:dart_frog/dart_frog.dart';

import 'routes/gpt.dart' as gpt;
import 'routes/correction.dart' as correction;

Future<Handler> buildHandler() async {
  return Pipeline()
      .addMiddleware(_logMiddleware())
      .addHandler(_router);
}

Future<Response> _router(RequestContext context) async {
  final path = context.request.uri.path;

  // 🎯 API
  if (path == '/gpt' && context.request.method == HttpMethod.post) {
    return await gpt.onRequest(context);
  }
  if (path == '/correction' && context.request.method == HttpMethod.post) {
    return await correction.onRequest(context);
  }

  // 📦 Fichiers statiques (css, js, images, html)
  final filePath = 'public$path';
  final file = File(filePath);

  if (await file.exists() && !await FileSystemEntity.isDirectory(filePath)) {
    final ext = file.uri.pathSegments.last.split('.').last;
    final contentType = _getContentType(ext);
    return Response(
      body: await file.readAsBytes(),
      headers: {
        HttpHeaders.contentTypeHeader: contentType,
      },
    );
  }

  // 🏠 Fallback : index
  final indexFile = File('public/main.html');
  if (await indexFile.exists()) {
    return Response(
      body: await indexFile.readAsString(),
      headers: {
        HttpHeaders.contentTypeHeader: 'text/html',
      },
    );
  }

  return Response(statusCode: 404, body: '❌ Not Found');
}

// 📄 Middleware simple pour logs
Middleware _logMiddleware() {
  return (handler) {
    return (context) async {
      final req = context.request;
      final res = await handler(context);
      print('📥 ${req.method} ${req.uri} → ${res.statusCode}');
      return res;
    };
  };
}

// 🧠 Type MIME en fonction de l’extension
String _getContentType(String ext) {
  switch (ext) {
    case 'html':
      return 'text/html';
    case 'css':
      return 'text/css';
    case 'js':
      return 'application/javascript';
    case 'png':
      return 'image/png';
    case 'jpg':
    case 'jpeg':
      return 'image/jpeg';
    case 'svg':
      return 'image/svg+xml';
    case 'webp':
      return 'image/webp';
    case 'json':
      return 'application/json';
    default:
      return 'application/octet-stream';
  }
}