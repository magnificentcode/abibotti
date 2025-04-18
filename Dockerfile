FROM dart:stable

WORKDIR /app
COPY . .

RUN dart pub get

RUN mkdir -p /app/public && cp -r public/* /app/public/

ENV PORT=8080
EXPOSE 8080

FROM dart:stable

WORKDIR /app
COPY . .

RUN dart pub get

ENV PORT=8080
EXPOSE 8080

CMD sh -c "dart run bin/dart_frog.dart --port \$PORT"