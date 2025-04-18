FROM dart:stable

WORKDIR /app

# 🔥 Copie tous les fichiers, pas juste "public"
COPY . .

# ✅ Télécharge les dépendances
RUN dart pub get

# ✅ Railway attend que ton app écoute sur $PORT
ENV PORT=8080
EXPOSE 8080

# ✅ Lance le serveur Dart Frog
CMD ["dart", "run", "bin/dart_frog.dart"]