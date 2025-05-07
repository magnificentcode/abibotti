



import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'middleware/cors.dart';
import 'package:mime/mime.dart'; // pour détecter le Content-Type automatiquement si besoin
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
        final response = await router(context);
        if (response.statusCode != 404) return response;

        // 3. Pages HTML simples ("/", "/studyhub")
        if (path == '/') return await _serveStaticHtml('main.html');
        if (path == '/studyhub') return await _serveStaticHtml('studyhub.html');

        // 4. Sinon, 404
        return Response(statusCode: 404, body: '❌ Page not found');
      });
}

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

Future<Response?> tryServeStatic(String path) async {
  final file = File('public$path');
  if (!await file.exists()) return null;

  final contentType = _getContentType(path);
  final isBinary = _isBinaryFile(path);

  if (isBinary) {
    // Lire les fichiers binaires en bytes
    return Response.body(
      await file.readAsBytes(),
      headers: {HttpHeaders.contentTypeHeader: contentType},
    );
  } else {
    // Lire les fichiers textes en string
    return Response(
      body: await file.readAsString(),
      headers: {HttpHeaders.contentTypeHeader: contentType},
    );
  }
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

String _getContentType(String path) {
  // Essaie d'utiliser mime si possible
  final mimeType = lookupMimeType(path);
  if (mimeType != null) {
    return mimeType;
  }

  // Sinon fallback manuel
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
  if (path.endsWith('.ttf')) return 'font/ttf';
  if (path.endsWith('.eot')) return 'application/vnd.ms-fontobject';
  if (path.endsWith('.otf')) return 'font/otf';
  if (path.endsWith('.ico')) return 'image/x-icon';
  return 'application/octet-stream'; // Par défaut
}

bool _isBinaryFile(String path) {
  return path.endsWith('.png') ||
         path.endsWith('.jpg') ||
         path.endsWith('.jpeg') ||
         path.endsWith('.webp') ||
         path.endsWith('.svg') ||
         path.endsWith('.woff') ||
         path.endsWith('.woff2') ||
         path.endsWith('.ttf') ||
         path.endsWith('.eot') ||
         path.endsWith('.otf') ||
         path.endsWith('.ico');
}