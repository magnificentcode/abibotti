import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'routes/gpt.dart' as gpt;
import 'routes/correction.dart' as correction;

Future<Handler> buildHandler() async {
  final router = Router()
    ..post('/gpt', gpt.onRequest)
    ..post('/correction', correction.onRequest);

  return Pipeline()
      .addMiddleware(_logMiddleware())
      .addHandler((context) async {
        final path = context.request.uri.path;

        // 1. Fichiers statiques
        final staticResponse = await tryServeStatic(path);
        if (staticResponse != null) return staticResponse;

        // 2. Routes dynamiques backend
        final response = await router.handler(context);
        if (response.statusCode != 404) return response;

        // 3. Pages HTML simples ("/", "/studyhub")
        if (path == '/') return await _serveStaticHtml('main.html');
        if (path == '/studyhub') return await _serveStaticHtml('studyhub.html');

        // 4. Sinon, 404
        return Response(statusCode: 404, body: '❌ Page not found');
      });
}

// 🧾 Logger simple
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

// 🔹 Sert fichiers statiques comme .css, .js, .png
Future<Response?> tryServeStatic(String path) async {
  final file = File('public$path');
  if (!await file.exists()) return null;

  final contentType = _getContentType(path);
  return Response(
    body: await file.readAsString(),
    headers: {HttpHeaders.contentTypeHeader: contentType},
  );
}

// 🧠 Type MIME
String _getContentType(String path) {
  if (path.endsWith('.html')) return 'text/html; charset=utf-8';
  if (path.endsWith('.css')) return 'text/css';
  if (path.endsWith('.js')) return 'application/javascript';
  if (path.endsWith('.json')) return 'application/json';
  if (path.endsWith('.png')) return 'image/png';
  if (path.endsWith('.jpg') || path.endsWith('.jpeg')) return 'image/jpeg';
  if (path.endsWith('.webp')) return 'image/webp';
  if (path.endsWith('.svg')) return 'image/svg+xml';
  if (path.endsWith('.woff2')) return 'font/woff2';
  if (path.endsWith('.woff')) return 'font/woff';
  return 'application/octet-stream';
}

// 🔸 Pages HTML simples
Future<Response> _serveStaticHtml(String filename) async {
  final file = File('public/$filename');
  if (await file.exists()) {
    final content = await file.readAsString();
    return Response(
      body: content,
      headers: {'Content-Type': 'text/html'},
    );
  }
  return Response(statusCode: 404, body: '$filename not found');
}