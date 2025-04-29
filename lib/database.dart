import 'package:postgres/postgres.dart';

late final PostgreSQLConnection db;

Future<void> initDatabase() async {
  const databaseUrl = 'postgresql://postgres:oJGgtyUSnuQDxnqoXmUAbzdpqjaPuNLy@postgres.railway.internal:5432/railway';
  final uri = Uri.parse(databaseUrl);

  db = PostgreSQLConnection(
    uri.host,
    uri.port,
    uri.pathSegments.first,
    username: uri.userInfo.split(':')[0],
    password: uri.userInfo.split(':')[1],
    useSSL: true,
  );

  await db.open(); // ✅ parenthèses obligatoires
}