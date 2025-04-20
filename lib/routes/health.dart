import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  return Response.json(
    body: {
      'status': 'ok',
      'uptime': DateTime.now().toIso8601String(),
      'service': 'abibotti'
    },
    headers: {
      'Access-Control-Allow-Origin': '*',
    },
  );
}