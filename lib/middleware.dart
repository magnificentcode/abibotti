import 'package:dart_frog/dart_frog.dart';

// 🧩 On importe chaque route à la main
import 'routes/gpt.dart' as gpt;
import 'routes/correction.dart' as correction;
import 'routes/index.dart' as index;
import 'routes/studyhub.dart' as studyhub;

Future<Handler> buildHandler() async {
  final router = Router()
    ..post('/gpt', gpt.onRequest)
    ..post('/correction', correction.onRequest)
    ..get('/', index.onRequest)
    ..get('/studyhub', studyhub.onRequest);

  final pipeline = Pipeline()
    .addMiddleware(_loggingMiddleware());

  return pipeline.addHandler(router);
}
Middleware _loggingMiddleware() {
  return (handler) {
    return (context) async {
      final request = context.request;
      final response = await handler(context);
      print('📥 ${request.method} ${request.uri} => ${response.statusCode}');
      return response;
    };
  };
}