import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'routes/gpt.dart' as gpt;
import 'routes/correction.dart' as correction;

Future<Handler> buildHandler() async {
  final router = Router()
    ..post('/gpt', gpt.onRequest)
    ..post('/correction', correction.onRequest);

  return (RequestContext context) async {
    final request = context.request;
    final path = request.uri.path;

    // ✅ 1. Priorité aux routes API
    final match = router.match(request);
    if (match != null) return await match.handler(context);

    // ✅ 2. Fichiers statiques (CSS, JS, IMG, etc.)
    final filePath = 'public$path';
    final file = File(filePath);
    if (await file.exists()) {
      final contentType = _getContentType(path);
      return Response.bytes(
        await file.readAsBytes(),
        statusCode: 200,
        headers: {
          HttpHeaders.contentTypeHeader: contentType,
        },
      );
    }

    // ✅ 3. Fallback : sert public/main.html
    final indexFile = File('public/main.html');
    if (await indexFile.exists()) {
      return Response(
        body: await indexFile.readAsString(),
        headers: {
          HttpHeaders.contentTypeHeader: 'text/html; charset=utf-8',
        },
      );
    }

    return Response(statusCode: 404, body: '❌ Page non trouvée');
  };
}

// 🧠 Déduction du Content-Type par extension
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