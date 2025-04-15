import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

void main() async {
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  await serve(handler, InternetAddress.anyIPv4, port);
}