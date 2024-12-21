import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const FriendJokeApp());
}

class FriendJokeApp extends StatelessWidget {
  const FriendJokeApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Joke App - Friend',
      theme: ThemeData(
        primarySwatch: Colors.green,
        textTheme: GoogleFonts.robotoTextTheme(),
      ),
      home: const FriendJokeScreen(),
    );
  }
}

class FriendJokeScreen extends StatefulWidget {
  const FriendJokeScreen({Key? key}) : super(key: key);

  @override
  _FriendJokeScreenState createState() => _FriendJokeScreenState();
}

class _FriendJokeScreenState extends State<FriendJokeScreen> {
  List<String> jokes = [];
  bool isLoading = true;

  final List<Color> cardColors = [
    Colors.orange.shade100,
    Colors.blue.shade100,
    Colors.green.shade100,
    Colors.pink.shade100,
    Colors.yellow.shade100,
  ];

  @override
  void initState() {
    super.initState();
    fetchJokes();
  }

  Future<void> fetchJokes() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedJokes = prefs.getStringList('jokes');

    try {
      final response = await http.get(Uri.parse('https://official-joke-api.appspot.com/jokes/programming/ten'));
      if (response.statusCode == 200) {
        final List<dynamic> jokeList = json.decode(response.body);
        jokes = jokeList
            .take(5)
            .map((joke) {
          final map = joke as Map<String, dynamic>;
          return "${map['setup']} - ${map['punchline']}";
        })
            .toList();
        await prefs.setStringList('jokes', jokes);
      } else {
        throw Exception('Failed to fetch jokes');
      }
    } catch (e) {
      if (cachedJokes != null) {
        jokes = cachedJokes;
      } else {
        jokes = ['Failed to fetch jokes. No cached jokes available.'];
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Joke App - Friend'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green, Colors.lightGreenAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              "Hey! Let's have a fun",
              style: GoogleFonts.roboto(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "Click the REFRESH button to see jokes",
              style: GoogleFonts.roboto(
                fontSize: 16,
                color: Colors.deepPurple,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isLoading = true;
                });
                fetchJokes();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 8,
              ),
              child: const Text(
                'Refresh',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: isLoading
                  ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              )
                  : ListView.builder(
                itemCount: jokes.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: cardColors[index % cardColors.length],
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    shadowColor: Colors.black,
                    elevation: 6,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        jokes[index],
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
