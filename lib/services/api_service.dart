import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'http://127.0.0.1:8000/api';

  Future<List<dynamic>> fetchUsers() async {
    final url = Uri.parse('$baseUrl/users/');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load users. Status code: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error fetching users: $error');
    }
  }
}
