FROM dart:stable

# Crée le dossier de l'app
WORKDIR /app

# Copie tous les fichiers du projet
COPY . .

# Récupère les dépendances
RUN dart pub get

# S'assure que le dossier public est bien présent
RUN mkdir -p /app/public && cp -r public/* /app/public/

# Expose le port utilisé par Railway
ENV PORT=8080
EXPOSE 8080

# Lance le serveur Dart Frog
CMD sh -c "dart run bin/dart_frog.dart --port \$PORT"