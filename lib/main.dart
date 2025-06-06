
import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

void main() => runApp(MaterialApp(
  title: 'Animal Math Game',
  home: MathGameScreen(),
  debugShowCheckedModeBanner: false,
));

class MathGameScreen extends StatefulWidget {
  @override
  _MathGameScreenState createState() => _MathGameScreenState();
}

class _MathGameScreenState extends State<MathGameScreen> {
  late int a, b, result;
  late String op, correctAnswer;
  String? droppedValue;
  late List<String> options;
  int correctStreak = 0;
  bool advancedOpsUnlocked = false, showLevelUp = false;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _generateNewEquation();
  }

  void _generateNewEquation() {
    a = _random.nextInt(9) + 1;
    b = _random.nextInt(9) + 1;

    op = (advancedOpsUnlocked
      ? ['×', '×', '×', '÷', '÷', '÷', '+', '-']
      : ['+', '-'])[_random.nextInt(advancedOpsUnlocked ? 8 : 2)];

    if (op == '+') {
      result = a + b;
    } else if (op == '-') {
      result = a;
      a += b;
    } else if (op == '×') {
      result = a * b;
    } else if (op == '÷') {
      result = a;
      a *= b;
    }
    correctAnswer = b.toString();

    options = [correctAnswer];
    while (options.length < 3) {
      String option = (_random.nextInt(9) + 1).toString();
      if (!options.contains(option)) options.add(option);
    }
    options.shuffle();
    droppedValue = null;
  }

  void _triggerLevelUp() {
    setState(() => showLevelUp = true);
    Timer(Duration(seconds: 2), () => setState(() => showLevelUp = false));
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/background.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '$correctStreak/10',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                        fontFamily: 'ComicNeue',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFF9C4),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.orangeAccent.withOpacity(0.6), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orangeAccent.withOpacity(0.3),
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildEquationText('$a'),
                      SizedBox(width: 16),
                      _buildEquationText(op),
                      SizedBox(width: 16),
                      DragTarget<String>(
                        onAccept: (value) => setState(() => droppedValue = value),
                        builder: (context, _, __) => Container(
                          width: 72,
                          height: 72,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            droppedValue ?? '?',
                            style: _numberTextStyle(),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      _buildEquationText('='),
                      SizedBox(width: 16),
                      _buildEquationText('$result'),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                if (droppedValue != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        droppedValue == correctAnswer ? 'assets/kitty_happy.png' : 'assets/kitty_sad.png',
                        width: 144,
                        height: 144,
                      ),
                      SizedBox(width: 0.0001),
                      Text(
                        droppedValue == correctAnswer ? 'Correct!' : 'Try again',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: droppedValue == correctAnswer ? Colors.green : Colors.red,
                          fontFamily: 'ComicNeue',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 0.1),
                  if (droppedValue == correctAnswer)
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          correctStreak++;
                          if (correctStreak >= 10 && !advancedOpsUnlocked) {
                            advancedOpsUnlocked = true;
                            _triggerLevelUp();
                          }
                          _generateNewEquation();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFFB74D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 36, vertical: 18),
                        elevation: 5,
                        shadowColor: Colors.deepOrangeAccent,
                      ),
                      child: Text(
                        'Next',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'ComicNeue',
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
                Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 50),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Transform.translate(
                        offset: Offset(-screenWidth * 0.188, -5),
                        child: _buildDraggableNumber(options[0]),
                      ),
                      SizedBox(width: 40),
                      Transform.translate(
                        offset: Offset(screenWidth * 0.015, -5),
                        child: _buildDraggableNumber(options[1]),
                      ),
                      SizedBox(width: 40),
                      Transform.translate(
                        offset: Offset(screenWidth * 0.214, -5),
                        child: _buildDraggableNumber(options[2]),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ),
        if (showLevelUp)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.translate(
                  offset: Offset(0, -120),
                  child: Image.asset('assets/turtle_levelup.png', width: 240, height: 240),
                ),
              ],
            ),
          ),
      ]),
    );
  }

  TextStyle _numberTextStyle() => TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.bold,
    color: Colors.brown[800],
    fontFamily: 'ComicNeue',
  );

  Widget _buildDraggableNumber(String value) => Draggable<String>(
    data: value,
    feedback: Material(
      color: Colors.transparent,
      child: Text(value, style: _numberTextStyle()),
    ),
    childWhenDragging: Opacity(
      opacity: 0.0,
      child: Text(value, style: _numberTextStyle()),
    ),
    child: Text(value, style: _numberTextStyle()),
  );

  Widget _buildEquationText(String text) => Text(
    text,
    style: TextStyle(
      fontSize: 56,
      fontWeight: FontWeight.bold,
      color: Colors.brown[800],
      fontFamily: 'ComicNeue',
    ),
  );
}
