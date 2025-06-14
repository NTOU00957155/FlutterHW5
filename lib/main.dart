import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'InfoHub 資訊中心',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});
  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool isLoggedIn = false;
  void handleLogin() => setState(() => isLoggedIn = true);
  @override
  Widget build(BuildContext context) {
    return isLoggedIn
        ? MainPage(onLogout: () => setState(() => isLoggedIn = false))
        : LoginPage(onLogin: handleLogin);
  }
}

class LoginPage extends StatefulWidget {
  final VoidCallback onLogin;
  const LoginPage({super.key, required this.onLogin});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool isRegisterMode = false;
  String error = '';

  void loginOrRegister() async {
    const apiKey = 'bcce9158ca4ffce29dbdade9950b0fde';
    final url = isRegisterMode
        ? Uri.parse('https://favqs.com/api/users')
        : Uri.parse('https://favqs.com/api/session');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Token token="$apiKey"'
    };
    final body = jsonEncode({
      'user': {
        'login': usernameController.text.trim(),
        'password': passwordController.text.trim()
      }
    });
    try {
      final response = await http.post(url, headers: headers, body: body);
      final responseData = json.decode(response.body);
      if (response.statusCode == 200 ||
          (isRegisterMode && response.statusCode == 201)) {
        widget.onLogin();
      } else {
        setState(() => error =
            '${isRegisterMode ? '註冊' : '登入'}失敗: ${responseData['message'] ?? '未知錯誤'}');
      }
    } catch (e) {
      setState(() => error = '${isRegisterMode ? '註冊' : '登入'}錯誤: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isRegisterMode ? '註冊' : '登入')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: '使用者名稱'),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: '密碼'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
                onPressed: loginOrRegister,
                child: Text(isRegisterMode ? '註冊' : '登入')),
            TextButton(
              onPressed: () {
                setState(() {
                  isRegisterMode = !isRegisterMode;
                  error = '';
                });
              },
              child: Text(isRegisterMode ? '已有帳號？點此登入' : '沒有帳號？點此註冊'),
            ),
            if (error.isNotEmpty)
              Text(error, style: const TextStyle(color: Colors.red))
          ],
        ),
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  final VoidCallback onLogout;
  const MainPage({super.key, required this.onLogout});
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int selectedIndex = 0;

  // 收藏清單狀態
  final List<Movie> favoriteMovies = [];

  late List<Widget> pages;

  @override
  void initState() {
    super.initState();
    pages = [
      WeatherMovieApp(
        onLogout: widget.onLogout,
        onAddFavorite: addFavoriteMovie,
      ),
      FavoritePage(favorites: favoriteMovies),
      const Placeholder(color: Colors.orange),
    ];
  }

  void addFavoriteMovie(Movie movie) {
    setState(() {
      // 防重複
      if (!favoriteMovies.any((m) => m.title == movie.title)) {
        favoriteMovies.add(movie);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已加入收藏：${movie.title}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('電影已在收藏中：${movie.title}')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) => setState(() => selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '主頁'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: '收藏'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '設定'),
        ],
      ),
    );
  }
}

class WeatherMovieApp extends StatefulWidget {
  final VoidCallback onLogout;
  final void Function(Movie) onAddFavorite;

  const WeatherMovieApp(
      {super.key, required this.onLogout, required this.onAddFavorite});
  @override
  State<WeatherMovieApp> createState() => _WeatherMovieAppState();
}

class _WeatherMovieAppState extends State<WeatherMovieApp> {
  final cityController = TextEditingController();
  Weather? weatherData;
  List<Movie> movieList = [];
  bool loadingWeather = false;
  bool loadingMovies = false;
  String error = '';
  String searchText = '';

  @override
  void initState() {
    super.initState();
    fetchMovies();
  }

  Future<void> fetchWeather(String city) async {
    setState(() {
      loadingWeather = true;
      error = '';
      weatherData = null;
    });
    const apiKey = '45663f2cba65e5c5b58b0b459875903e';
    final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonMap = json.decode(response.body);
        setState(() => weatherData = Weather.fromJson(jsonMap));
      } else {
        setState(() => error = '找不到城市資料');
      }
    } catch (e) {
      setState(() => error = '天氣 API 錯誤: $e');
    } finally {
      setState(() => loadingWeather = false);
    }
  }

  Future<void> fetchMovies() async {
    setState(() {
      loadingMovies = true;
      error = '';
      movieList = [];
    });
    const tmdbApiKey = '311993a5f701d21d3c302760cb656486';
    final url = Uri.parse(
        'https://api.themoviedb.org/3/movie/popular?api_key=$tmdbApiKey&language=zh-TW&page=1');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        List<Movie> loadedMovies =
            (result['results'] as List).map((e) => Movie.fromJson(e)).toList();
        setState(() => movieList = loadedMovies);
      } else {
        setState(() => error = '電影資料取得失敗');
      }
    } catch (e) {
      setState(() => error = '電影 API 錯誤: $e');
    } finally {
      setState(() => loadingMovies = false);
    }
  }

  List<Movie> get filteredMovies {
    if (searchText.isEmpty) return movieList;
    return movieList
        .where((m) => m.title.toLowerCase().contains(searchText.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('InfoHub 資訊中心'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: widget.onLogout,
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: fetchMovies,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('🔎 查詢天氣',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: cityController,
              decoration: InputDecoration(
                hintText: '請輸入城市名稱',
                prefixIcon: const Icon(Icons.location_city),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    final city = cityController.text.trim();
                    if (city.isNotEmpty) fetchWeather(city);
                  },
                ),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) fetchWeather(value.trim());
              },
            ),
            const SizedBox(height: 12),
            if (loadingWeather) const LinearProgressIndicator(),
            if (error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(error, style: const TextStyle(color: Colors.red)),
              ),
            if (weatherData != null)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.cloud_outlined),
                  title: Text('${weatherData!.cityName} 天氣'),
                  subtitle: Text(
                      '${weatherData!.description}，${weatherData!.temp}°C，體感 ${weatherData!.feelsLike}°C'),
                ),
              ),
            const SizedBox(height: 24),
            const Text('🎬 熱門電影',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                hintText: '輸入電影名稱搜尋',
                prefixIcon: const Icon(Icons.movie_filter),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: (value) => setState(() => searchText = value),
            ),
            const SizedBox(height: 12),
            if (loadingMovies) const LinearProgressIndicator(),
            if (filteredMovies.isEmpty && !loadingMovies)
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text('找不到符合的電影', textAlign: TextAlign.center),
              ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredMovies.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                final movie = filteredMovies[index];
                return GestureDetector(
                  onTap: () {
                    widget.onAddFavorite(movie);
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    clipBehavior: Clip.hardEdge,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: movie.posterPath.isNotEmpty
                              ? Image.network(
                                  'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  color: Colors.grey.shade300,
                                  child: const Icon(Icons.movie_outlined,
                                      size: 80),
                                ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(movie.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text('上映: ${movie.releaseDate}',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class FavoritePage extends StatelessWidget {
  final List<Movie> favorites;
  const FavoritePage({super.key, required this.favorites});

  @override
  Widget build(BuildContext context) {
    if (favorites.isEmpty) {
      return const Center(child: Text('尚無收藏的電影'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final movie = favorites[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: movie.posterPath.isNotEmpty
                ? Image.network(
                    'https://image.tmdb.org/t/p/w92${movie.posterPath}',
                    fit: BoxFit.cover,
                  )
                : const Icon(Icons.movie_outlined),
            title: Text(movie.title),
            subtitle: Text('上映: ${movie.releaseDate}'),
          ),
        );
      },
    );
  }
}

class Weather {
  final String cityName;
  final String description;
  final double temp;
  final double feelsLike;
  Weather(
      {required this.cityName,
      required this.description,
      required this.temp,
      required this.feelsLike});
  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'],
      description: json['weather'][0]['description'],
      temp: (json['main']['temp'] as num).toDouble(),
      feelsLike: (json['main']['feels_like'] as num).toDouble(),
    );
  }
}

class Movie {
  final String title;
  final String releaseDate;
  final String posterPath;
  Movie(
      {required this.title,
      required this.releaseDate,
      required this.posterPath});
  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      title: json['title'],
      releaseDate: json['release_date'] ?? '',
      posterPath: json['poster_path'] ?? '',
    );
  }
}
