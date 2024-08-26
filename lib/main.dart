// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, sized_box_for_whitespace, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(MyGameApp());
}

class MyGameApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Simon Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

// Home Page Widget
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int highScore = 0;

  @override
  void initState() {
    super.initState();
    _loadHighScore();
  }

  Future<void> _loadHighScore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      highScore = prefs.getInt('highScore') ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Simon Game'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text('About'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AboutPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF178989),
              Color(0xFFEF7D20),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Simon Game',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 40,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'High Score: $highScore',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => GamePage(highScore: highScore)),
                ).then((newHighScore) {
                  if (newHighScore != null) {
                    setState(() {
                      highScore = newHighScore;
                    });
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                backgroundColor: Colors.white, // Updated to backgroundColor
                foregroundColor:
                    Color(0xFF178989), // Updated to foregroundColor
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                'Start Game',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Game Page Widget
class GamePage extends StatefulWidget {
  final int highScore;

  GamePage({required this.highScore});

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  List<String> gameSeq = [];
  List<String> userSeq = [];
  List<String> btns = ["yellow", "green", "red", "purple"];
  bool started = false;
  int level = 0;
  String levelText = "Press anywhere to start game!";
  Map<String, GlobalKey<_ColorButtonState>> buttonKeys = {
    "red": GlobalKey<_ColorButtonState>(),
    "green": GlobalKey<_ColorButtonState>(),
    "yellow": GlobalKey<_ColorButtonState>(),
    "purple": GlobalKey<_ColorButtonState>(),
  };

  void startGame() {
    if (!started) {
      setState(() {
        started = true;
        level = 0;
        gameSeq.clear();
        userSeq.clear();
      });
      levelUp();
    }
  }

  void levelUp() {
    setState(() {
      level++;
      levelText = "Level $level";
    });

    userSeq.clear(); // Clear the user sequence for the next round
    addRandomColorToSequence(); // Add a new color to the game sequence
    playSequence(); // Flash only the new color
  }

  void addRandomColorToSequence() {
    int rdmIdx = Random().nextInt(btns.length);
    String rdmColor = btns[rdmIdx];
    gameSeq.add(rdmColor);
  }

  Future<void> playSequence() async {
    // Get the last color added to the game sequence
    String newColor = gameSeq.last;

    // Flash only the new color
    await buttonKeys[newColor]?.currentState?.flash();
  }

  void checkSeq(int idx) {
    if (userSeq[idx] == gameSeq[idx]) {
      if (userSeq.length == gameSeq.length) {
        // Delay before going to next level
        Future.delayed(Duration(milliseconds: 200), () {
          levelUp();
        });
      }
    } else {
      showGameOver();
    }
  }

  void onButtonPressed(String color) {
    userSeq.add(color);
    buttonKeys[color]?.currentState?.flash();
    checkSeq(userSeq.length - 1);
  }

  Future<void> showGameOver() async {
    setState(() {
      started = false;
      userSeq.clear();
      gameSeq.clear();
      levelText = "Game Over! Press anywhere to start again.";
    });

    int currentScore = level; // Use level directly

    // If the current score is greater than the high score, update it
    if (currentScore > widget.highScore) {
      await _updateHighScore(currentScore);
      Navigator.pop(context, currentScore); // Pass the updated high score back
    } else {
      Navigator.pop(context, null);
    }
  }

  Future<void> _updateHighScore(int newHighScore) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('highScore', newHighScore); // Save new high score
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: startGame,
      child: Scaffold(
        body: Container(
          height: double.infinity,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF178989),
                Color(0xFFEF7D20),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Simon Game',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              Text(
                levelText,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              Container(
                height: 400,
                width: 400,
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  padding: EdgeInsets.all(10),
                  children: [
                    ColorButton(
                        key: buttonKeys["red"]!,
                        color: "red",
                        onPressed: () => onButtonPressed("red")),
                    ColorButton(
                        key: buttonKeys["green"]!,
                        color: "green",
                        onPressed: () => onButtonPressed("green")),
                    ColorButton(
                        key: buttonKeys["yellow"]!,
                        color: "yellow",
                        onPressed: () => onButtonPressed("yellow")),
                    ColorButton(
                        key: buttonKeys["purple"]!,
                        color: "purple",
                        onPressed: () => onButtonPressed("purple")),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ColorButton extends StatefulWidget {
  final String color;
  final VoidCallback onPressed;

  ColorButton({required Key key, required this.color, required this.onPressed})
      : super(key: key);

  @override
  _ColorButtonState createState() => _ColorButtonState();
}

class _ColorButtonState extends State<ColorButton> {
  Color currentColor;

  _ColorButtonState() : currentColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
    currentColor = getOriginalColor();
  }

  Color getOriginalColor() {
    switch (widget.color) {
      case 'red':
        return Colors.red;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow;
      case 'purple':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Future<void> flash() async {
    setState(() {
      currentColor = Colors.white; // Flash to white when clicked
    });

    await Future.delayed(Duration(milliseconds: 200));

    setState(() {
      currentColor = getOriginalColor(); // Return to original color after delay
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      child: Container(
        color: currentColor,
        child: Center(
          child: Text(
            widget.color,
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

// About Page Widget
class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About Simon Game'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            'This Simon Game is a fun and interactive memory game where players '
            'need to follow and repeat sequences of colors. The game progressively '
            'increases in difficulty as the sequences get longer. Try to beat the high score!',
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
