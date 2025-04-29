import 'package:dart_frog/dart_frog.dart';
import '../lib/database.dart'; // Connecte à PostgreSQL

void main() async {
  await initDatabase(); // ⚡ Connexion PostgreSQL Railway
  runApp(); // ⚡ Lance Dart Frog
}