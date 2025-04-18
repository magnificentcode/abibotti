import 'dart:io';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  final scriptDir = File(Platform.script.toFilePath()).parent.path;
final file = File('$scriptDir/../public/studyhub.html');

  if (!file.existsSync()) {
    return Response(statusCode: 404, body: '❌ studyhub.html not found');
  }

  return Response.file(
    file.path,
    headers: {'Content-Type': 'text/html; charset=utf-8'},
  );
}