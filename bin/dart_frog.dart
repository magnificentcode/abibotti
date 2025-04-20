import 'dart:io';
import 'package:dart_frog/dart_frog.dart';

Future<void> main() async {
  final port = int.tryParse(Platform.environment['PORT'] ?? '8080') ?? 8080;

  // ✅ Crée le handler à partir du répertoire racine (routing automatique)
  final handler = await createHandler();

  // ✅ Lance le serveur sur Railway
  await serve(handler, InternetAddress.anyIPv4, port);
}