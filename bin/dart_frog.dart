import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:abibotti/middleware.dart';

Future<void> main() async {
  final port = int.tryParse(Platform.environment['PORT'] ?? '8080') ?? 8080;
  final handler = await buildHandler(); // ✅ Compatible
  await serve(handler, InternetAddress.anyIPv4, port);
}