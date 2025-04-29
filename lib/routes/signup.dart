import 'package:dart_frog/dart_frog.dart';
import 'package:bcrypt/bcrypt.dart';
import 'dart:convert';
import '../../database.dart'; // Connexion à PostgreSQL

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method == HttpMethod.post) {
    final body = await context.request.body();
    final data = jsonDecode(body);

    final fullName = data['fullname'];
    final email = data['email'];
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

    // Vérifier si email existe
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

    // Hashage du mot de passe
    final hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());

    // Enregistrement en base
    await db.query(
      'INSERT INTO users (full_name, email, password) VALUES (@fullName, @email, @password)',
      substitutionValues: {
        'fullName': fullName,
        'email': email,
        'password': hashedPassword,
      },
    );

    return Response.json(
      statusCode: 201,
      body: {'message': 'Utilisateur inscrit avec succès.'},
    );
  }

  return Response.json(
    statusCode: 405,
    body: {'message': 'Méthode non autorisée.'},
  );
}