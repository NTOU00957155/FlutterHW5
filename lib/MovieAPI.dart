import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List> fetchPopularMovies() async {
  const apiKey = '311993a5f701d21d3c302760cb656486';
  final url =
      Uri.parse('https://api.themoviedb.org/3/movie/popular?api_key=$apiKey');

  final response = await http.get(url);
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['results'];
  } else {
    throw Exception('無法取得資料');
  }
}
