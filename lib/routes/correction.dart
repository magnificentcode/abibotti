import 'dart:io'; // pour Platform.environment
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io'; // ✅ pour Platform.environment
import 'package:dart_frog/dart_frog.dart';
import 'package:http/http.dart' as http;

// 🔐 Clé OpenAI depuis l'environnement
final openAiKey = Platform.environment['OPENAI_API_KEY'];

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method == HttpMethod.options) {
    return _corsResponse(status: 204);
  }

  try {
    final body = await context.request.body();
    final data = jsonDecode(body);

    final question = data['question'];
    final reponse = data['reponse'];

    if (question == null || question.toString().trim().isEmpty ||
        reponse == null || reponse.toString().trim().isEmpty) {
      return _jsonError("Champs 'question' et 'reponse' requis.");
    }

    final prompt = '''
Toimi kokeneena yo-kokeiden arvioijana Suomessa.

Tässä on YO-koekysymys:
"$question"

Tässä on oppilaan vastaus:
$reponse

Arvioi vastaus kysymyksen perusteella. Tarkista:
- Sisällön relevanttius ja syvällisyys
- Rakenne ja selkeys
- Kielioppi ja oikeinkirjoitus

Palauta seuraavassa JSON-muodossa:
{
  "Arvosana": "x/10",
  "Korjaus": "Korjattu versio oppilaan vastauksesta",
  "Palaute": "Palaute ja parannusehdotukset"
}

Vastaa vain suomeksi.
''';

    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $openAiKey',
      },
      body: jsonEncode({
        'model': 'gpt-4',
        'messages': [
          {'role': 'system', 'content': "Olet kokenein yo-arvioija Suomessa."},
          {'role': 'user', 'content': prompt},
        ],
        'temperature': 0.7,
      }),
    );

    final utf8Content = utf8.decode(response.bodyBytes);
    final parsed = jsonDecode(jsonDecode(utf8Content)['choices'][0]['message']['content']);

    final translated = {
      'note': parsed['Arvosana'],
      'correction': parsed['Korjaus'],
      'feedback': parsed['Palaute'],
    };

    return Response.json(
      body: translated,
      headers: {'Access-Control-Allow-Origin': '*'},
    );
  } catch (e) {
    return _jsonError("Virhe korjauksen aikana.", details: e.toString());
  }
}

// 🔁 Réponse CORS pour OPTIONS
Response _corsResponse({int status = 200}) {
  return Response(
    statusCode: status,
    headers: {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type',
    },
  );
}

// 🔁 Réponse d’erreur JSON propre
Response _jsonError(String message, {String? details}) {
  return Response.json(
    statusCode: 500,
    body: {
      'error': '❌ $message',
      if (details != null) 'details': details,
    },
    headers: {'Access-Control-Allow-Origin': '*'},
  );
}
