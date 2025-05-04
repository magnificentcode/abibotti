import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
Tu es un générateur d’examens YO (baccalauréat finlandais). Crée une question en "${subject}" dans le style officiel du YO, basée sur l’année ou le thème "${topic}".

🧠 Exigences :
- Sujet en **finnois**
- Format inspiré des vrais examens
- Si science → formules lisibles, unités SI
- Si rédaction → donne contexte + consignes claires

🎯 Cas particuliers :
- "Suomi toisena kielenä" → rédaction avec 2–3 titres au choix
- "Fysiikka" → problème de calcul ou schéma à analyser
- "Biologia" → texte ou schéma + 1–3 sous-questions explicatives
- "Historia" → document ou sujet argumenté à analyser
- "Kemia" → exercice sur réactions ou calculs chimiques

⚠️ Réponds uniquement en JSON strict, comme ci-dessous :

{
  "question": "Texte de la question ici",
  "level": "lyhyt / pitkä / helppo / keskitaso / vaikea",
  "difficulty": "Facile / Moyen / Difficile",
  "solution": "Modèle de réponse ou correction attendue",
  "steps": "Étapes ou structure de raisonnement"
}

Langue : **finnois**.

Inspire-toi des vrais examens YO finlandais, sans inventer de styles d’examens inexistants.  
Si "$topic" est vide ou inconnu, base-toi sur les tendances des 5 dernières années.
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