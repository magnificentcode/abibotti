import 'dart:io';
import 'package:dart_frog/dart_frog.dart';

Future<void> main() async {
  final port = int.tryParse(Platform.environment['PORT'] ?? '8080') ?? 8080;

  // 🔧 Crée le handler avec routage automatique + middleware global
  final handler = await buildHandler();

  // 🚀 Lance le serveur sur 0.0.0.0:$PORT (nécessaire pour Railway)
  await serve(handler, InternetAddress.anyIPv4, port);
}