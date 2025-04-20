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

    // ✅ 1. Routes déclarées
    final response = await router.handler(context);
    if (response.statusCode != 404) return response;

    // ✅ 2. Fichier statique ?
    final filePath = 'public$path';
    final file = File(filePath);
    if (await file.exists()) {
      final contentType = _getContentType(path);
      final bytes = await file.readAsBytes();
      return Response(
        body: Body.bytes(bytes),
        headers: {
          HttpHeaders.contentTypeHeader: contentType,
        },
      );
    }

    // ✅ 3. Page d’accueil par défaut
    final indexFile = File('public/main.html');
    if (await indexFile.exists()) {
      final html = await indexFile.readAsString();
      return Response(
        body: html,
        headers: {
          HttpHeaders.contentTypeHeader: 'text/html; charset=utf-8',
        },
      );
    }

    // ❌ 404 si rien trouvé
    return Response(statusCode: 404, body: '❌ Page non trouvée');
  };
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
  return 'application/octet-stream';
}