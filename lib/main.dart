import 'package:flutter/material.dart';
import 'quiz_brain.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

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
    
    // 延迟一帧显示模式选择弹窗，确保界面已经构建完成
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showModeSelectionDialog();
    });
  }
  
  // 显示模式选择弹窗
  void showModeSelectionDialog() {
    Alert(
      context: context,
      title: "选择答题模式",
      desc: "请选择您想要的答题模式",
      buttons: [
        DialogButton(
          child: Text(
            "无尽模式",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            Navigator.pop(context);
            setState(() {
              // 切换到无尽模式并重置状态
              quizBrain.setQuizMode(QuizMode.endless);
              // 清空答题记录
              scoreKeeper.clear();
              resultMessage = '';
            });
          },
          color: Colors.blue,
        ),
        DialogButton(
          child: Text(
            "普通模式",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            Navigator.pop(context);
            setState(() {
              // 切换到普通模式并重置状态
              quizBrain.setQuizMode(QuizMode.normal);
              // 清空答题记录
              scoreKeeper.clear();
              resultMessage = '';
            });
          },
          color: Colors.green,
        )
      ],
    ).show();
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
      
      // 检查是否所有问题都已回答
      if (quizBrain.isAllQuestionsAnswered()) {
        resultMessage = '已完成所有题目，请重置或更换模式继续';
        showCompletionAlert();
      }
    });
  }
  
  void showCompletionAlert() {
    Alert(
      context: context,
      title: "恭喜!",
      desc: "您已经答完题库里所有问题\n答题按钮已禁用\n请点击\"再来一次\"重新开始，或\"确认\"保留当前状态",
      buttons: [
        DialogButton(
          child: Text(
            "确认",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context),
          color: Colors.green,
        ),
        DialogButton(
          child: Text(
            "再来一次",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            Navigator.pop(context);
            resetQuiz();
          },
          color: Colors.blue,
        )
      ],
    ).show();
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
    // 获取当前模式名称
    String modeName = quizBrain.quizMode == QuizMode.endless ? '无尽模式' : '普通模式';
    // 获取题目统计
    String questionStats = quizBrain.quizMode == QuizMode.normal 
        ? '${quizBrain.answeredQuestions}/${quizBrain.totalQuestions}题'
        : '已答${quizBrain.answeredQuestions}题';
    // 获取正确率
    String accuracyText = '正确率: ${quizBrain.getAccuracy().toStringAsFixed(1)}%';
    
    // 判断按钮是否应该禁用（普通模式下答完所有题目）
    bool buttonsDisabled = quizBrain.quizMode == QuizMode.normal && quizBrain.isAllQuestionsAnswered();
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10.0, left: 10.0),
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                ),
                onPressed: showModeSelectionDialog,
                child: const Text(
                  '模式',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                  ),
                ),
              ),
            ),
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
        
        // 显示当前模式和统计信息
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                modeName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                ),
              ),
              Text(
                '$questionStats - $accuracyText',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                ),
              ),
            ],
          ),
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
                // 如果按钮禁用，设置更暗的颜色
                disabledBackgroundColor: Colors.green.withOpacity(0.3),
              ),
              child: Text(
                'True',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                ),
              ),
              onPressed: buttonsDisabled ? null : () {
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
                // 如果按钮禁用，设置更暗的颜色
                disabledBackgroundColor: Colors.red.withOpacity(0.3),
              ),
              child: Text(
                'False',
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.white,
                ),
              ),
              onPressed: buttonsDisabled ? null : () {
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

//TODO: Nothing
