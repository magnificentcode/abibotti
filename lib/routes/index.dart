import 'dart:io';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  final path = '${Directory.current.path}/public/studyhub.html';
  print('🔍 PATH: $path'); // <-- ligne de debug

  final file = File(path);

  if (!file.existsSync()) {
    return Response(statusCode: 404, body: '❌ studyhub.html not found at $path');
  }

  return Response.file(
    file.path,
    headers: {'Content-Type': 'text/html; charset=utf-8'},
  );
}