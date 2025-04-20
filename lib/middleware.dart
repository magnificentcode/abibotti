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
      .addHandler((RequestContext context) async {
        final request = context.request;
        final path = request.uri.path;

        // ✅ 1. Fichiers statiques (CSS, JS, IMG, etc.)
        final staticResponse = await tryServeStatic(path);
        if (staticResponse != null) return staticResponse;

        // ✅ 2. Routes dynamiques
        if (request.method == HttpMethod.post && path == '/gpt') {
          return await gpt.onRequest(context);
        }

        if (request.method == HttpMethod.post && path == '/correction') {
          return await correction.onRequest(context);
        }

        // ✅ 3. Fallback
        if (path == '/' || path == '/index') {
          return await _serveStaticHtml('main.html');
        }

        if (path == '/studyhub') {
          return await _serveStaticHtml('studyhub.html');
        }

        return Response(statusCode: 404, body: '❌ Page non trouvée');
      });
}

Middleware _logMiddleware() {
  return (handler) {
    return (context) async {
      final req = context.request;
      final res = await handler(context);
      print('📥 ${req.method} ${req.uri} -> ${res.statusCode}');
      return res;
    };
  };
}

Future<Response> _serveStaticHtml(String filename) async {
  final file = File('public/$filename');
  if (await file.exists()) {
    final content = await file.readAsString();
    return Response(
      body: content,
      headers: {'Content-Type': 'text/html; charset=utf-8'},
    );
  }
  return Response(statusCode: 404, body: '$filename not found');
}

Future<Response?> tryServeStatic(String path) async {
  final file = File('public$path');
  if (!await file.exists()) return null;

  final contentType = _getContentType(path);
  final isText = contentType.startsWith('text/') || contentType.contains('javascript');

  return isText
      ? Response(
          body: await file.readAsString(),
          headers: {HttpHeaders.contentTypeHeader: contentType},
        )
      : Response.bytes(
          await file.readAsBytes(),
          headers: {HttpHeaders.contentTypeHeader: contentType},
        );
}

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
  return 'application/octet-stream'; // fallback
}