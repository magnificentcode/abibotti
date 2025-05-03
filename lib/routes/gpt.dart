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
Tu es un expert des examens de baccalauréat finlandais (Ylioppilaskoe).

Génère du contenu en "$subject", inspiré du style officiel des examens de l'année "$topic".

**Si "$subject" est "Suomi toisena kielenä"**, génère un sujet de rédaction ("kirjoitustehtävä") :
- Présente brièvement un matériel inspiré (extrait d’article, graphique, poème, film, image).
- Donne deux types d’écriture possibles : soit rédiger un texte argumentatif, soit un texte analytique.
- Propose 2 à 3 titres d’essai possibles au choix.
- Respecte la longueur et le style typique des examens S2 (description concise, 2 à 4 phrases maximum).
Corrige tous les caractères mal encodés et affiche les expressions mathématiques de manière lisible en utilisant LaTeX si besoin.
- n'oublie pas de mettre le liens reels vers le text ou l'article ou la video. utilise yle pour les articles et tout les autres textes que l'utilisatuer aura besoin de lire.
Inspire-toi du style réel des examens de matriculation finlandais pour S2 (ylioppilaskoe), en particulier pour :

- Pitkä matematiikka (mathématiques longues)
- Lyhyt matematiikka (mathématiques courtes)

Suis bien les formats d'examen : pour Pitkä, les exercices peuvent être plus longs, plus analytiques ; pour Lyhyt, privilégie des calculs plus directs et de la modélisation simple.


** Si "$subject" est "Biologia", alors La question doit respecter les formats vus dans les vrais examens finlandais :
- Question ouverte nécessitant une réponse rédigée (explication, analyse, justification biologique).
- Ou question de type **analyse d'un texte ou d'un schéma**. et tu proposes un lien ou une source où trouver le texte ou le schema.
- Le niveau doit être adapté pour un examen final de lycée (lukio) YO.
- Corrige tous les caractères mal encodés.

Si nécessaire, propose un petit texte introductif (simulant un "Aineisto" comme dans les vrais sujets), puis pose 1 à 3 sous-questions.
Mentionne clairement si la réponse attend une explication biologique, un schéma ou une analyse d’un processus.

Utilise la langue finnoise.



Si "$subject" est "Fysiikka" (Physique) :
- Génère une question adaptée au style YO en Fysiikka.
- Peut être soit :
  - Un exercice de calcul (ex : énergie, mécanique, électricité, thermodynamique...),
  - Une question d'analyse basée sur un petit texte ou un schéma (comme dans les tâches de type "aineisto").
- Utilise des unités correctes (SI) et assure-toi que toutes les formules sont lisibles (LaTeX ou texte clair).

Respecte les styles suivants :
- Une question de type problème de physique avec énoncé précis.
- La réponse doit inclure une **solution complète** avec étapes et justifications.
- Toutes les réponses doivent être logiques, cohérentes et suivies d'une explication courte.



Si "$subject" est "Historia" (Histoire) :
- Génère une question adaptée au style des examens YO d'histoire.
- La question doit demander une réponse rédigée et argumentée.
- Inspire-toi de vrais sujets : analyse d'un texte, d'un document, d'une image ou réflexion sur un thème historique.
- Structure attendue :
  - Donner un **contexte historique** en 1 à 2 phrases (par exemple : référence à un événement, une période, un document).
  - Poser 1 ou 2 **questions ouvertes** qui appellent une analyse historique, une interprétation de sources ou une réflexion critique.
- Tous les éléments doivent être formulés en **finnois**.
- Le candidat doit utiliser une méthode historique : contextualisation, comparaison, interprétation critique des sources.



Si "$subject" est "Kemia" (Chimie) :
- Génère une question adaptée au style YO en chimie.
- La question peut être :
  - Un exercice de calcul (stœchiométrie, concentrations, thermodynamique, etc.),
  - Un problème de réaction chimique (équilibrer, identifier, prévoir le résultat),
  - Une analyse d'un schéma, d'un spectre ou d'un processus expérimental.
- Utilise un style clair, avec unités SI correctes et si nécessaire présente les équations chimiques en format lisible (LaTeX recommandé).

Respecte le style typique :
- Les réponses doivent inclure une **solution complète** (calculs détaillés, équations chimiques équilibrées, justifications claires).
- Les exercices peuvent comporter plusieurs sous-questions (par exemple 2 ou 3 sous-tâches sur le même sujet).
- Utilise la langue **finnoise** (suomeksi).





- Génère une question claire et directe adaptée au style YO.
- Corrige tous les éventuels caractères mal encodés.
- Si la matière est scientifique (mathématiques, physique, chimie), écris toutes les formules de façon lisible (LaTeX ou texte clair).
- Utilise les types de tâches typiques du YO : résolution d’équations, simplification, intégration, analyse de texte, dissertation argumentée, etc.

**Réponds uniquement en format JSON**, comme ceci :

{
  "question": "Contenu de la question ou du sujet ici",
  "level": "Niveau approximatif (lyhyt oppimäärä, pitkä oppimäärä, helppo, keskitaso, vaikea)",
  "difficulty": "Facile / Moyen / Difficile",
  "solution": "Correction complète, modèle de réponse ou éléments de rédaction attendus. en cas de faute d'orthographe, explique pourquoi c'est une faute en bref et comment bien läecire ",
  "steps": "Explication pas à pas ou structure de la réponse"
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