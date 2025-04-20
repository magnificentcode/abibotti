import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:shelf_static/shelf_static.dart';

import 'routes/gpt.dart' as gpt;
import 'routes/correction.dart' as correction;

// 🔧 Sert tous les fichiers de public/ statiquement
final staticHandler = createStaticHandler(
  'public',
  defaultDocument: 'main.html',
  serveFilesOutsidePath: false,
);

Future<Handler> buildHandler() async {
  return Pipeline()
      .addMiddleware(logRequests())
      .addHandler((context) async {
        final path = context.request.uri.path;

        // Si un fichier statique existe → on le sert
        final staticFile = File('public/$path');
        if (await staticFile.exists()) {
          return staticHandler(context.request);
        }

        // Sinon, les routes backend
        if (path == '/gpt') return await gpt.onRequest(context);
        if (path == '/correction') return await correction.onRequest(context);

        // Sinon, retourne la page d'accueil
        return await staticHandler(context.request);
      });
}