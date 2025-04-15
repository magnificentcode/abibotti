FROM dart:stable

# Crée le répertoire de l'app
WORKDIR /app

# Copie le code Dart
COPY . .

# Récupère les dépendances
RUN dart pub get

# Expose le port attendu par Railway
ENV PORT=8080
EXPOSE 8080

# Lance le serveur Dart Frog avec le bon fichier
CMD ["sh", "-c", "dart run bin/dart_frog.dart --port \$PORT"]