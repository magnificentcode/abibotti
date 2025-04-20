import 'dart:io'; // pour Platform.environment
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:convert' show utf8;
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  // ✅ GET : pour vérifier que la route fonctionne
  if (context.request.method == HttpMethod.get) {
    return Response.json(
      body: {
        'message': '✅ La route /gpt est active. Utilise POST pour envoyer des données.'
      },
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': '*',
        'Access-Control-Allow-Methods': '*',
      },
    );
  }

  // 🔧 OPTIONS : CORS preflight
  if (context.request.method == HttpMethod.options) {
    return Response(
      statusCode: 204,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type',
      },
    );
  }

  // 🔁 POST : Générer une question via OpenAI
  try {
    final body = await context.request.body();
    final data = jsonDecode(body);
    final subject = data['subject'];
    final topic = data['topic'];

    final prompt = '''
Tu es un expert des examens du bac finlandais. Génère une question de YO-Koe (baccalauréat) en "$subject" inspirée de l'examen de l'année "$topic".NB: tu ne fais rien que t'inspiré des examens ultrieurs. ecrit juste ce que je t'ai demandé d'ecrire, rien d'autre. 
Corrige tous les caractères mal encodés pour qu'ils soient lisibles par un humain (par exemple, "Ã¤" devient "ä").Si le cours est une langue, ne pause pas de question d'ecoute.

Réponds uniquement en JSON :
{
  "question": "...",
  "level": "...",
  "difficulty": "...",
  "solution": "...",
  "steps": "..."
}
Tu dois absolument répondre en **finnois**.
''';

    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${Platform.environment['OPENAI_API_KEY']}',
      },
      body: jsonEncode({
        'model': 'gpt-4',
        'messages': [
          {'role': 'system', 'content': "Tu es un générateur d'examens YO."},
          {'role': 'user', 'content': prompt},
        ],
        'temperature': 0.8,
      }),
    );

    final utf8Content = utf8.decode(response.bodyBytes);
    final parsed = jsonDecode(jsonDecode(utf8Content)['choices'][0]['message']['content']);

    return Response.json(
      body: parsed,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': '*',
        'Access-Control-Allow-Methods': '*',
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {
        'error': "❌ Erreur de parsing JSON ou appel API.",
        'details': e.toString(),
      },
      headers: {'Access-Control-Allow-Origin': '*'},
    );
  }
}