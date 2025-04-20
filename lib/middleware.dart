import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'routes/gpt.dart' as gpt;
import 'routes/correction.dart' as correction;

Future<Handler> buildHandler() async {
  final router = Router()
    ..post('/gpt', gpt.onRequest)
    ..post('/correction', correction.onRequest);

  return (RequestContext context) async {
    final path = context.request.uri.path;

    // ✅ 1. Servir fichiers statiques (CSS, JS, IMG, HTML, etc.)
    final staticResponse = await tryServeStatic(path);
    if (staticResponse != null) return staticResponse;

    // ✅ 2. Routes dynamiques backend
    final routeResponse = await router.handler(context);
    if (routeResponse.statusCode != 404) return routeResponse;

    // ✅ 3. Fallback : page d'accueil
    final fallback = await tryServeStatic('/main.html');
    return fallback ?? Response(statusCode: 404, body: '❌ Page non trouvée');
  };
}

// 📂 Essaie de lire un fichier dans /public
Future<Response?> tryServeStatic(String path) async {
  final file = File('public$path');
  if (!await file.exists()) return null;

  final contentType = _getContentType(path);

  return Response(
    body: await file.readAsString(),
    headers: {
      HttpHeaders.contentTypeHeader: contentType,
    },
  );
}

// 🧠 Détection type MIME selon extension
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