import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:convert' show utf8;

Future<Response> onRequest(RequestContext context) async {
  final method = context.request.method;

  if (method == HttpMethod.get) {
    return _jsonOk({'message': '✅ /gpt ready'});
  }

  if (method == HttpMethod.options) {
    return _cors(204);
  }

  if (method != HttpMethod.post) {
    return _jsonError("Méthode non autorisée", status: 405);
  }

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
Corrige tous les caractères mal encodés et affiche les expressions mathematiques de manière lisible. Réponds uniquement en JSON :

{
  "question": "...",
  "level": "...",
  "difficulty": "...",
  "solution": "...",
  "steps": "..."
}
Langue : finnois.
⚠️ Important : tu dois toujours répondre exactement en JSON, sans texte autour, et inclure les champs :
- question
- level
- difficulty
- solution
- steps





Comportement spécifique selon la matière :

- Si "$subject" est "Suomi toisena kielenä" :
  ➤ Génère un sujet de rédaction (kirjoitustehtävä) inspiré d’un matériel (article, photo, statistique, poème…).
  ➤ Propose deux options de traitement : argumentatiivinen ou analyyttinen teksti.
  ➤ Fournis 2–3 titres de rédaction.
  ➤ La solution inclut un plan de rédaction ou les idées attendues.

- Si "$subject" est "Matematiikka, pitkä oppimäärä" :
  ➤ Génère un exercice de niveau avancé avec raisonnement approfondi, modélisation, ou application réelle.
  ➤ Respecte la logique YO : notation claire, étapes visibles, expressions lisibles (LaTeX ou clair).

- Si "$subject" est "Matematiikka, lyhyt oppimäärä" :
  ➤ Génère un exercice plus direct et concret, basé sur des contextes simples, avec une solution rigoureuse et lisible.

- Si "$subject" est "Biologia" :
  ➤ Crée une question ouverte ou une analyse basée sur un texte ou une donnée (image, graphe...).
  ➤ Donne une réponse bien structurée, utilisant un vocabulaire biologique correct.

- Si "$subject" est "Fysiikka" :
  ➤ Génère un problème basé sur un phénomène réel (mécanique, énergie, optique, etc.).
  ➤ Inclut équations, unités et raisonnement physique dans la solution.

- Si "$subject" est "Kemia" :
  ➤ Génère un exercice de calcul, de titrage, ou de réaction chimique.
  ➤ Inclut équations chimiques, explications et étapes.
  ➤ Sois précis : pas d’erreurs d’équilibrage ou de logique.

- Si "$subject" est "Historia" :
  ➤ Crée une tâche d’analyse de texte ou image.
  ➤ Pose une question argumentative ou réflexive basée sur une période précise.
  ➤ La réponse doit inclure les éléments d’une analyse historique ou d’un plan structuré.

Langue : finnois.
Ne réponds jamais avec autre chose que le JSON demandé.
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

    final match = RegExp(r'{[\s\S]*}').firstMatch(text);
    if (match == null) {
      return _jsonError("⚠️ Aucun JSON détecté", details: text);
    }

    final jsonOnly = match.group(0);
    final parsed = jsonDecode(jsonOnly!);

    if (!parsed.containsKey("question")) {
      return _jsonError("⚠️ JSON incomplet ou malformé", details: text);
    }

    return _jsonOk(parsed);
  } catch (e) {
    return _jsonError("Erreur JSON ou API", details: e.toString());
  }
}

Response _jsonOk(Map<String, dynamic> body) => Response.json(
  body: body,
  headers: {'Access-Control-Allow-Origin': '*'},
);

Response _jsonError(String message, {String? details, int status = 500}) => Response.json(
  statusCode: status,
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