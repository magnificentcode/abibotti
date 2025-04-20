import 'package:dart_frog/dart_frog.dart';
import 'package:shelf_static/shelf_static.dart';

final staticHandler = createStaticHandler(
  'public', 
  defaultDocument: 'main.html', 
  serveFilesOutsidePath: false,
);

Future<Response> onRequest(RequestContext context) async {
  final response = await staticHandler(context.request);
  return response;
}