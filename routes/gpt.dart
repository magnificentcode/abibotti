Future<Response> onRequest(RequestContext context) async {
  // 🔧 CORS preflight
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

  // ✅ Ajout explicite du POST
  if (context.request.method == HttpMethod.post) {
    final body = await context.request.body();
    final data = jsonDecode(body);
    final subject = data['subject'];
    final topic = data['topic'];

    final prompt = '''
Tu es un expert des examens du bac finlandais. Génère une question de YO-Koe (baccalauréat) en "$subject" inspirée de l'examen de l'année "$topic".
Corrige tous les caractères mal encodés pour qu'ils soient lisibles par un humain.
Réponds uniquement en JSON (et en finnois) :
{
  "question": "...",
  "level": "...",
  "difficulty": "...",
  "solution": "...",
  "steps": "..."
}
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

    try {
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
          'error': "❌ Erreur de parsing JSON.",
          'raw': utf8Content,
          'details': e.toString(),
        },
        headers: {'Access-Control-Allow-Origin': '*'},
      );
    }
  }

  // ❌ Toutes les autres méthodes sont rejetées
  return Response(statusCode: 405, body: 'Method Not Allowed');
}