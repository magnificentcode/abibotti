import 'dart:io';
import 'package:dart_frog/dart_frog.dart';

// ✅ IMPORTS en haut du fichier
import 'routes/gpt.dart' as gpt;
import 'routes/correction.dart' as correction;

Future<Handler> buildHandler() async {
  return Pipeline()
      .addMiddleware(_logMiddleware())
      .addHandler(_autoRouter());
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

Handler _autoRouter() {
  return (context) async {
    final req = context.request;
    final path = req.uri.path;

    if (req.method == HttpMethod.get) {
      if (path == '/') return await _serveStaticHtml('main.html');
      if (path == '/studyhub') return await _serveStaticHtml('studyhub.html');
      return Response(statusCode: 404, body: '🚫 Route not found');
    }

    if (req.method == HttpMethod.post && path == '/gpt') {
      return await gpt.onRequest(context);
    }

    if (req.method == HttpMethod.post && path == '/correction') {
      return await correction.onRequest(context);
    }

    return Response(statusCode: 404, body: '❌ No matching route.');
  };
}

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


// ⚙️ Redirige vers une route Dart existante
Future<Response> _proxyToRoute(String fileName, RequestContext context) async {
  // Simulation : on importe manuellement ici si nécessaire
  if (fileName == 'gpt.dart') {
    return await importGptRoute(context);
  }
  if (fileName == 'correction.dart') {
    return await importCorrectionRoute(context);
  }
  return Response(statusCode: 404);
}

// 🧠 Import "manuel" simulé (pas dynamique à l’exécution)
import 'routes/gpt.dart' as gpt;
import 'routes/correction.dart' as correction;

Future<Response> importGptRoute(RequestContext context) => gpt.onRequest(context);
Future<Response> importCorrectionRoute(RequestContext context) => correction.onRequest(context);