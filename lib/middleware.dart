import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'routes/gpt.dart' as gpt;
import 'routes/correction.dart' as correction;

/// Middleware principal
Future<Handler> middleware(Handler handler) async {
  return handler;
}

/// Génère le `Handler` principal
Future<Handler> buildHandler() async {
  final router = Router()
    ..post('/gpt', gpt.onRequest)
    ..post('/correction', correction.onRequest);

  final staticHandler = await createStaticHandler(
    'public',
    defaultDocument: 'main.html',
    serveFilesOutsidePath: true,
  );

  return (RequestContext context) async {
    final request = context.request;

    // 🔍 Priorité aux routes déclarées
    final match = router.match(request);

    if (match != null) {
      return await match.handler(context);
    }

    // 🗂️ Si pas de route API, essayer de servir un fichier statique
    final path = request.uri.path;
    final file = File('public/$path');

    if (await file.exists()) {
      final contentType = _getContentType(path);
      return Response.bytes(
        await file.readAsBytes(),
        headers: {
          HttpHeaders.contentTypeHeader: contentType,
        },
      );
    }

    // 🧭 Fallback → page principale
    final indexFile = File('public/main.html');
    final indexContent = await indexFile.readAsString();
    return Response(
      body: indexContent,
      headers: {
        HttpHeaders.contentTypeHeader: 'text/html; charset=utf-8',
      },
    );
  };
}

/// 🔍 Déduction du Content-Type
String _getContentType(String path) {
  if (path.endsWith('.css')) return 'text/css';
  if (path.endsWith('.js')) return 'application/javascript';
  if (path.endsWith('.png')) return 'image/png';
  if (path.endsWith('.jpg') || path.endsWith('.jpeg')) return 'image/jpeg';
  if (path.endsWith('.webp')) return 'image/webp';
  if (path.endsWith('.svg')) return 'image/svg+xml';
  if (path.endsWith('.woff')) return 'font/woff';
  if (path.endsWith('.woff2')) return 'font/woff2';
  return 'application/octet-stream'; // fallback
}