FROM dart:stable

WORKDIR /app
COPY . .

RUN dart pub get

EXPOSE 8080
CMD ["dart", "run", "dart_frog", "dev", "--hostname", "0.0.0.0", "--port", "8080"]
