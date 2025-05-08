import 'package:dart_frog/dart_frog.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'dart:convert';
import '../../database.dart';

final jwtSecret = const String.fromEnvironment('JWT_SECRET');

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method == HttpMethod.options) {
  return Response(statusCode: 200, headers: {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    'Access-Control-Allow-Headers': '*',
  });
}
  if (context.request.method == HttpMethod.post) {
    if (jwtSecret.isEmpty) {
      return Response.json(
        statusCode: 500,
        body: {'message': 'JWT_SECRET non défini côté serveur.'},
      );
    }

    final body = await context.request.body();
    final data = jsonDecode(body);

    final fullName = data['fullname'];
    final email = data['email']?.toLowerCase().trim();
    final password = data['password'];
    final confirmPassword = data['confirm-password'];

    if (fullName == null || email == null || password == null || confirmPassword == null) {
      return Response.json(
        statusCode: 400,
        body: {'message': 'Tous les champs sont requis.'},
      );
    }

    if (password != confirmPassword) {
      return Response.json(
        statusCode: 400,
        body: {'message': 'Les mots de passe ne correspondent pas.'},
      );
    }

    final result = await db.query(
      'SELECT * FROM users WHERE email = @email',
      substitutionValues: {'email': email},
    );

    if (result.isNotEmpty) {
      return Response.json(
        statusCode: 409,
        body: {'message': 'Cet email est déjà utilisé.'},
      );
    }

    final hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());

    final insertResult = await db.query(
      'INSERT INTO users (full_name, email, password) VALUES (@fullName, @email, @password) RETURNING id',
      substitutionValues: {
        'fullName': fullName,
        'email': email,
        'password': hashedPassword,
      },
    );

    final userId = int.parse(insertResult.first['id']);

    final jwt = JWT(
  {
    'userId': userId,
    'email': email,
    'role': 'user',
  },
);

final token = jwt.sign(
  SecretKey(jwtSecret),
  expiresIn: const Duration(hours: 2), // ✅ ici, pas dans JWT()
);

    return Response.json(
      statusCode: 201,
      body: {
        'message': 'Utilisateur inscrit avec succès.',
        'token': token
      },
      headers: {'access-control-allow-origin': '*'},
    );
  }

  return Response.json(
    statusCode: 405,
    body: {'message': 'Méthode non autorisée.'},
  );
}