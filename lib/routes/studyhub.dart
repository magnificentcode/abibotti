import 'package:dart_frog/dart_frog.dart';
import 'package:shelf_static/shelf_static.dart';

final staticHandler = createStaticHandler(
  'public',
  defaultDocument: 'studyhub.html',
  serveFilesOutsidePath: false,
);

Future<Response> onRequest(RequestContext context) async {
  return await staticHandler(context.request);
}