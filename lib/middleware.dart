import 'package:dart_frog/dart_frog.dart';
import 'package:abibotti/routes/gpt.dart' as gpt;
import 'package:abibotti/routes/correction.dart' as correction;

Future<Handler> buildHandler() async {
  final pipeline = Pipeline();

  final router = Router()
    ..post('/gpt', gpt.onRequest)
    ..post('/correction', correction.onRequest);

  return pipeline.addHandler(router);
}