import 'package:flutter/material.dart';
import 'quiz_brain.dart';

void main() => runApp(Quizzler());

class Quizzler extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.grey.shade900,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: QuizPage(),
          ),
        ),
      ),
    );
  }
}

class QuizPage extends StatefulWidget {
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final QuizBrain quizBrain = QuizBrain();
  String resultMessage = '';
  List<Icon> scoreKeeper = [];
  
  // 最大显示图标数量
  final int maxIcons = 15;
  
  @override
  void initState() {
    super.initState();
    // 生成初始问题
    quizBrain.generateRandomQuestion();
  }

  void checkAnswer(bool userAnswer) {
    bool isCorrect = quizBrain.checkAnswer(userAnswer);
    double accuracy = quizBrain.getAccuracy();
    
    setState(() {
      resultMessage = isCorrect ? '回答正确' : '回答错误';
      // 在控制台打印结果和正确率
      print('$resultMessage - 正确率: ${accuracy.toStringAsFixed(1)}%');
      
      // 添加答题记录图标
      Icon newIcon = isCorrect 
          ? const Icon(Icons.check, color: Colors.green) 
          : const Icon(Icons.close, color: Colors.red);
      
      // 如果图标数量已经达到最大值，移除第一个
      if (scoreKeeper.length >= maxIcons) {
        scoreKeeper.removeAt(0);
      }
      
      // 添加新图标
      scoreKeeper.add(newIcon);
    });
  }
  
  void resetQuiz() {
    setState(() {
      // 清空答题记录
      scoreKeeper.clear();
      resultMessage = '';
      // 重置QuizBrain
      quizBrain.reset();
      // 生成新问题
      quizBrain.generateRandomQuestion();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10.0, right: 10.0),
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey,
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                ),
                onPressed: resetQuiz,
                child: const Text(
                  '重置',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                  ),
                ),
              ),
            ),
          ],
        ),
        Expanded(
          flex: 5,
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Center(
              child: Text(
                quizBrain.getQuestionText(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25.0,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(15.0),
            child: TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.green,
                padding: const EdgeInsets.all(16.0),
              ),
              child: Text(
                'True',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                ),
              ),
              onPressed: () {
                checkAnswer(true);
              },
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(15.0),
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text(
                'False',
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.white,
                ),
              ),
              onPressed: () {
                checkAnswer(false);
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Text(
            resultMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20.0,
              color: Colors.white,
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: scoreKeeper,
          ),
        ),
        SizedBox(height: 10.0),
      ],
    );
  }
}

/*
question1: 'You can lead a cow down stairs but not up stairs.', false,
question2: 'Approximately one quarter of human bones are in the feet.', true,
question3: 'A slug\'s blood is green.', true,
*/
//TODO: Nothing
