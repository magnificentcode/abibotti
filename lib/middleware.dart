import 'package:dart_frog/dart_frog.dart';

Future<Handler> buildHandler() async {
  final pipeline = Pipeline();

  // Tu peux ajouter ici des middlewares globaux
  return pipeline.addHandler(_router);
}

Handler _router(RequestContext context) {
  return Response.json(body: {
    'message': 'Dart Frog est en ligne 🎉',
    'status': 'OK'
  });
}