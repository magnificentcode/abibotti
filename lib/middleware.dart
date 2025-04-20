import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:shelf_static/shelf_static.dart' as shelf_static;
import 'package:shelf/shelf.dart' as shelf;

import 'routes/gpt.dart' as gpt;
import 'routes/correction.dart' as correction;

final shelfHandler = shelf_static.createStaticHandler(
  'public',
  defaultDocument: 'main.html',
  serveFilesOutsidePath: false,
);

Future<Handler> buildHandler() async {
  return Pipeline()
      .addMiddleware(_logMiddleware())
      .addHandler((context) async {
        final request = context.request;
        final path = request.uri.path;

        // ⚙️ Check si le fichier statique existe
        if (await File('public/$path').exists()) {
          final shelfResponse = await shelfHandler(request.toShelfRequest());
          return Response(
            statusCode: shelfResponse.statusCode,
            body: await shelfResponse.readAsString(),
            headers: Map.from(shelfResponse.headers),
          );
        }

        // 🎯 Routes API personnalisées
        if (path == '/gpt') return await gpt.onRequest(context);
        if (path == '/correction') return await correction.onRequest(context);

        // 🏠 Sinon, retourne la page d’accueil
        final fallback = await shelfHandler(Request.get('/'));
        return Response(
          statusCode: fallback.statusCode,
          body: await fallback.readAsString(),
          headers: Map.from(fallback.headers),
        );
      });
}

// 👀 Middleware simple pour logguer les requêtes
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