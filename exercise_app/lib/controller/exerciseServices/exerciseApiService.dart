import 'dart:convert';
import 'package:http/http.dart' as http;

class ExerciseApiService {
  static const String baseUrl = "https://exercisedb.p.rapidapi.com";
  static const Map<String, String> headers = {
    "X-RapidAPI-Key":
        "6aa889bcfcmshe9fb60718bb7a70p128ca8jsn74811232f98a", // Replace with your actual key
    "X-RapidAPI-Host": "exercisedb.p.rapidapi.com",
  };

  /// **Fetch All Exercises with Limit Support**
  static Future<List<dynamic>> getExercises({int limit = 10}) async {
    final response = await http.get(
      Uri.parse("$baseUrl/exercises?limit=$limit"),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load exercises");
    }
  }

  /// **Fetch Exercises by Body Part**
  static Future<List<dynamic>> getExercisesByBodyPart(String bodyPart) async {
    final uri = Uri.parse("$baseUrl/exercises/bodyPart/$bodyPart?limit=0");
    print("🌐 API Request URI: $uri");

    final response = await http.get(uri, headers: headers);

    print("🔁 Status Code: ${response.statusCode}");
    print("📦 Response Body: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load exercises for $bodyPart");
    }
  }

  /// **Fetch Exercise by Name**
  static Future<List<dynamic>> getExerciseByName(String name) async {
    final response = await http.get(
      Uri.parse("$baseUrl/exercises/name/$name"),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Exercise not found");
    }
  }
}
