import 'package:dart_frog/dart_frog.dart';

// ✅ Pas de Router manuel ici.
// Dart Frog utilisera automatiquement les fichiers de lib/routes/*.dart

Handler middleware(Handler handler) {
  // Tu peux ajouter ici des middlewares globaux si tu veux
  return handler;
}