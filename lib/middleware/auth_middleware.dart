import 'package:dart_frog/dart_frog.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

final jwtSecret = const String.fromEnvironment('JWT_SECRET');

Middleware checkAuth() {
  return (handler) {
    return (context) async {
      final authHeader = context.request.headers['Authorization'];

      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response.json(
          statusCode: 401,
          body: {'message': 'Token manquant ou invalide.'},
        );
      }

      final token = authHeader.substring(7); // Retire "Bearer "
      try {
        final jwt = JWT.verify(token, SecretKey(jwtSecret));

        // Injecte les infos du token dans le contexte
        return handler(context.provide(() => jwt.payload));
      } catch (e) {
        return Response.json(
          statusCode: 401,
          body: {'message': 'Token invalide ou expiré.'},
        );
      }
    };
  };
}