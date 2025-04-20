import 'dart:io';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  final file = File('public/studyhub.html');
  if (await file.exists()) {
    final content = await file.readAsString();
    return Response(
      body: content,
      headers: {
        HttpHeaders.contentTypeHeader: 'text/html',
      },
    );
  }
  return Response(statusCode: 404, body: 'studyhub.html not found');
}