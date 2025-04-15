import 'package:dart_frog/dart_frog.dart';

import '../routes/gpt.dart' as gpt;
import '../routes/correction.dart' as correction;

Future<Handler> buildHandler() async {
  final pipeline = Pipeline();

  final router = Router()
    ..post('/gpt', gpt.onRequest)
    ..post('/correction', correction.onRequest);

  return pipeline.addHandler(router);
}


