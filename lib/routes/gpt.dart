import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:convert' show utf8;

Future<Response> onRequest(RequestContext context) async {
  final method = context.request.method;

  // GET pour test rapide
  if (method == HttpMethod.get) {
    return _jsonOk({'message': '✅ /gpt ready'});
  }

  // OPTIONS (CORS preflight)
  if (method == HttpMethod.options) {
    return _cors(204);
  }

  // POST
  try {
    final raw = await context.request.body();
    final json = jsonDecode(raw);
    final subject = json['subject']?.toString();
    final topic = json['topic']?.toString();

    if (subject == null || topic == null) {
      return _jsonError("Champs 'subject' et 'topic' requis.");
    }

    final prompt = '''
Tu es un expert YO. Génère une question en "$subject", inspirée de l’année "$topic".
Corrige tous les caractères mal encodés. Réponds uniquement en JSON comme ceci :

{
  "question": "...",
  "level": "...",
  "difficulty": "...",
  "solution": "...",
  "steps": "..."
}
Langue : finnois.
''';

    final res = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${Platform.environment['OPENAI_API_KEY']}',
      },
      body: jsonEncode({
        'model': 'gpt-4',
        'messages': [
          {'role': 'system', 'content': 'Tu es un générateur YO.'},
          {'role': 'user', 'content': prompt}
        ],
        'temperature': 0.8,
      }),
    );

    if (res.statusCode != 200) {
      return _jsonError("Erreur OpenAI (${res.statusCode})", details: res.body);
    }

    final contentUtf8 = utf8.decode(res.bodyBytes);
    final rawOpenAI = jsonDecode(contentUtf8);
    final text = rawOpenAI['choices'][0]['message']['content'];
    final parsed = jsonDecode(text);

    return _jsonOk(parsed);
  } catch (e) {
    return _jsonError("Erreur JSON ou API", details: e.toString());
  }
}

// ✅ Helpers

Response _jsonOk(Map<String, dynamic> body) => Response.json(
  body: body,
  headers: {'Access-Control-Allow-Origin': '*'},
);

Response _jsonError(String message, {String? details}) => Response.json(
  statusCode: 500,
  body: {
    'error': '❌ $message',
    if (details != null) 'details': details,
  },
  headers: {'Access-Control-Allow-Origin': '*'},
);

Response _cors(int status) => Response(
  statusCode: status,
  headers: {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type',
  },
);