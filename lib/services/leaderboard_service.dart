import 'dart:convert';
import 'package:http/http.dart' as http;

class LeaderboardService {
  // change the baseUrl when deploying the server
  final String baseUrl;

  LeaderboardService({this.baseUrl = 'http://localhost:3000'});

  Future<bool> submitScore(String username, String character, double score) async {
    final url = Uri.parse('$baseUrl/api/submitScore');
    final resp = await http.post(url, headers: {'Content-Type': 'application/json'}, body: jsonEncode({
      'username': username,
      'character': character,
      'score': score,
    }));
    return resp.statusCode == 200;
  }

  Future<List<Map<String, dynamic>>> getLeaderboard(String character) async {
    final url = Uri.parse('$baseUrl/api/leaderboard?character=${Uri.encodeComponent(character)}');
    final resp = await http.get(url);
    if (resp.statusCode != 200) return [];
    final body = jsonDecode(resp.body) as Map<String, dynamic>;
    final list = (body['leaderboard'] as List<dynamic>?) ?? [];
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  /// Send contours (arrays of [x,y]) to the server compareContours endpoint.
  /// Returns a map with {score: double, hausdorff: double} or null on failure.
  Future<Map<String, dynamic>?> compareContours({required List<List<num>> reference, required List<List<num>> drawn, String? username, String? character, int size = 256}) async {
    final url = Uri.parse('$baseUrl/api/compareContours');
    final body = {
      'reference': reference,
      'drawn': drawn,
      'size': {'w': size, 'h': size},
    };
    if (username != null) body['username'] = username;
    if (character != null) body['character'] = character;
    final resp = await http.post(url, headers: {'Content-Type': 'application/json'}, body: jsonEncode(body));
    if (resp.statusCode != 200) return null;
    return jsonDecode(resp.body) as Map<String, dynamic>;
  }
}
