FROM dart:stable

WORKDIR /app

# Copie tout le projet, y compris public/
COPY . .

# Récupère les dépendances
RUN dart pub get

# Pas besoin de copier public/ : il est déjà là via COPY . .

ENV PORT=8080
EXPOSE 8080

CMD sh -c "dart run bin/dart_frog.dart --port \$PORT"