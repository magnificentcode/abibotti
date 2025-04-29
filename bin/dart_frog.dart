import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:abibotti/build_handler.dart'; // ✅ nouvel import propre
import '../lib/database.dart'; // Connexion DB

Future<void> main() async {
  await initDatabase();
  final port = int.tryParse(Platform.environment['PORT'] ?? '8080') ?? 8080;
  final handler = await buildHandler();
  await serve(handler, InternetAddress.anyIPv4, port);
}