import 'package:dart_frog/dart_frog.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'dart:convert';
import '../../database.dart'; // Connexion PostgreSQL

final jwtSecret = const String.fromEnvironment('JWT_SECRET');

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method == HttpMethod.post) {
    if (jwtSecret.isEmpty) {
      return Response.json(
        statusCode: 500,
        body: {'message': 'JWT_SECRET non défini côté serveur.'},
      );
    }

    final body = await context.request.body();
    final data = jsonDecode(body);

    final email = data['email'];
    final password = data['password'];

    if (email == null || password == null) {
      return Response.json(
        statusCode: 400,
        body: {'message': 'Email et mot de passe requis.'},
      );
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
if (!emailRegex.hasMatch(email)) {
  return Response.json(
    statusCode: 400,
    body: {'message': 'Adresse email invalide.'},
  );
}



    final result = await db.query(
      'SELECT id, email, password FROM users WHERE email = @email',
      substitutionValues: {'email': email},
    );

    if (result.isEmpty) {
      return Response.json(
        statusCode: 401,
        body: {'message': 'Identifiants invalides.'},
      );
    }

    final user = result.first;
    final hashedPassword = user['password'] as String;

    if (!BCrypt.checkpw(password, hashedPassword)) {
      return Response.json(
        statusCode: 401,
        body: {'message': 'Identifiants invalides.'},
      );
    }

    final jwt = JWT(
      {
        'userId': user['id'],
        'email': user['email'],
        'role': 'user',
      },
      maxAge: const Duration(hours: 2),
    );

    final token = jwt.sign(SecretKey(jwtSecret));

    return Response.json(
      body: {'token': token},
      headers: {'access-control-allow-origin': '*'},
    );
  }

  return Response.json(
    statusCode: 405,
    body: {'message': 'Méthode non autorisée.'},
  );
}