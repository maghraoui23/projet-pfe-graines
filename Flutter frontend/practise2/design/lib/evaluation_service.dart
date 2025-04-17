import 'dart:convert';
import 'package:http/http.dart' as http;
import 'Evaluation.dart';
import 'dart:async';

class EvaluationService {
  static const String _baseUrl = 'http://192.168.1.5:9090';

  final StreamController<List<Evaluation>> _evaluationsController =
      StreamController<List<Evaluation>>.broadcast();

  Stream<List<Evaluation>> getEvaluationsStream(int professionalId) {
    getEvaluations(professionalId).then(_evaluationsController.add);
    return _evaluationsController.stream;
  }

  Future<Evaluation> addEvaluation({
    required int userId,
    required int professionalId,
    required int rating,
    String? comment,
  }) async {
    final uri = Uri.parse('$_baseUrl/evaluations/ajouter');
    final request = http.MultipartRequest('POST', uri)
      ..fields['userId'] = userId.toString()
      ..fields['professionalId'] = professionalId.toString()
      ..fields['rating'] = rating.toString()
      ..fields['comment'] = comment ?? '';

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      _evaluationsController.add(await getEvaluations(professionalId));
      return Evaluation.fromJson(json.decode(responseBody));
    } else {
      throw Exception('Échec de l\'ajout: ${response.reasonPhrase}');
    }
  }

  Future<List<Evaluation>> getEvaluations(int professionalId) async {
    final uri = Uri.parse('$_baseUrl/evaluations/$professionalId');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      try {
        return (json.decode(response.body) as List)
            .map((e) => Evaluation.fromJson(e))
            .toList();
      } catch (e) {
        throw Exception('Erreur de décodage: $e');
      }
    }
    return [];
  }

  Future<double> getMoyenneAvis(int professionalId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/professionals/$professionalId/moyenne-avis'),
    );

    if (response.statusCode == 200) {
      return double.parse(response.body);
    }
    throw Exception('Erreur ${response.statusCode}');
  }

  Future<Evaluation> updateEvaluation({
    required int evaluationId,
    required int newRating,
    required int professionalId,
    String? newComment,
  }) async {
    final uri = Uri.parse('$_baseUrl/evaluations/update/$evaluationId');
    final request = http.MultipartRequest('PUT', uri)
      ..fields['newRating'] = newRating.toString()
      ..fields['newComment'] = newComment ?? '';

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      _evaluationsController.add(await getEvaluations(professionalId));
      return Evaluation.fromJson(json.decode(responseBody));
    }
    throw Exception('Échec de la mise à jour');
  }

  Future<bool> hasUserEvaluatedProfessional({
    required int userId,
    required int professionalId,
  }) async {
    final uri = Uri.parse('$_baseUrl/evaluations/check-evaluation')
        .replace(queryParameters: {
      'userId': userId.toString(),
      'professionalId': professionalId.toString(),
    });

    final response = await http.get(uri);
    if (response.statusCode == 200) return json.decode(response.body) as bool;
    throw Exception('Erreur de vérification');
  }

  void dispose() {
    _evaluationsController.close();
  }
}
