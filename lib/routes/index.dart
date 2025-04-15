import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  // Servir le fichier public/main.html
  return Response.file(
    'public/main.html',
    headers: {
      'Content-Type': 'text/html; charset=utf-8',
    },
  );
}