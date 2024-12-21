import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const JokeApp());
}

class JokeApp extends StatelessWidget {
  const JokeApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Joke App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const JokeScreen(),
    );
  }
}

class JokeScreen extends StatefulWidget {
  const JokeScreen({Key? key}) : super(key: key);

  @override
  _JokeScreenState createState() => _JokeScreenState();
}

class _JokeScreenState extends State<JokeScreen> {
  List<String> jokes = [];
  bool isLoading = true;

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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange, Colors.pink],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            Text(
              'Hi Buddy!',
              style: GoogleFonts.pacifico(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.yellow,
                shadows: [
                  Shadow(
                    blurRadius: 10.0,
                    color: Colors.black45,
                    offset: Offset(2.0, 2.0),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Welcome to Joke App',
              style: GoogleFonts.lato(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.w600,
                shadows: [
                  Shadow(
                    blurRadius: 5.0,
                    color: Colors.black26,
                    offset: Offset(1.0, 1.0),
                  ),
                ],
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
                    margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.lightBlueAccent, Colors.blueAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.all(15.0),
                      child: Text(
                        jokes[index],
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isLoading = true;
                });
                fetchJokes();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                shadowColor: Colors.black,
                elevation: 10,
              ),
              child: const Text(
                'Refresh Jokes',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Have a good day...!',
              style: GoogleFonts.robotoMono(
                fontSize: 28,  // Increased font size
                fontWeight: FontWeight.w400,
                color: Colors.black,  // Set text color to black
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
