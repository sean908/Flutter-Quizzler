import 'dart:math';
import 'question.dart';

// 定义游戏模式枚举
enum QuizMode {
  endless, // 无尽模式
  normal,  // 普通模式
}

class QuizBrain {
  // 问题库
  final List<Question> _questionBank = [
    Question('You can lead a cow down stairs but not up stairs.', false),
    Question('Approximately one quarter of human bones are in the feet.', true),
    Question('A slug\'s blood is green.', true),
    Question('Buzz Aldrin\'s mother\'s maiden name was \"Moon\".', true),
    Question('It is illegal to pee in the Ocean in Portugal.', true),
    Question('No piece of square dry paper can be folded in half more than 7 times.', false),
    Question('In London, UK, if you happen to die in the House of Parliament, you are technically entitled to a state funeral, because the building is considered too sacred a place.', true),
    Question('The loudest sound produced by any animal is 188 decibels. That animal is the African Elephant.', false),
    Question('The total surface area of two human lungs is approximately 70 square metres.', true),
    Question('Google was originally called \"Backrub\".', true),
    Question('Chocolate affects a dog\'s heart and nervous system; a few ounces are enough to kill a small dog.', true),
    Question('In West Virginia, USA, if you accidentally hit an animal with your car, you are free to take it home to eat.', true),
  ];

  int _correctAnswers = 0;
  int _totalAnswers = 0;
  Question? _currentQuestion;
  // 跟踪已回答的问题索引
  Set<int> _answeredQuestionIndices = {};
  // 默认为普通模式
  QuizMode _quizMode = QuizMode.normal;
  
  // 设置游戏模式
  void setQuizMode(QuizMode mode) {
    _quizMode = mode;
    reset(); // 重置状态
    generateRandomQuestion(); // 生成新问题
  }
  
  // 获取当前游戏模式
  QuizMode get quizMode => _quizMode;

  // 生成一个随机问题
  void generateRandomQuestion() {
    final random = Random();
    
    if (_quizMode == QuizMode.endless) {
      // 无尽模式：完全随机抽取题目，可能重复
      final randomIndex = random.nextInt(_questionBank.length);
      _currentQuestion = _questionBank[randomIndex];
    } else {
      // 普通模式：确保一轮内不重复
      // 如果所有问题都已回答过，选择一个随机问题，但不改变答题完成状态
      if (_answeredQuestionIndices.length >= _questionBank.length) {
        final randomIndex = random.nextInt(_questionBank.length);
        _currentQuestion = _questionBank[randomIndex];
        return;
      }

      // 随机生成一个未回答过的问题
      int randomIndex;
      do {
        randomIndex = random.nextInt(_questionBank.length);
      } while (_answeredQuestionIndices.contains(randomIndex));

      _currentQuestion = _questionBank[randomIndex];
    }
  }

  // 获取当前问题文本
  String getQuestionText() {
    if (_currentQuestion == null) {
      generateRandomQuestion();
    }
    return _currentQuestion!.questionText;
  }

  // 获取当前问题答案
  bool getQuestionAnswer() {
    return _currentQuestion!.questionAnswer;
  }

  // 检查用户的答案
  bool checkAnswer(bool userAnswer) {
    bool correctAnswer = _currentQuestion!.questionAnswer;
    bool isCorrect = userAnswer == correctAnswer;
    
    _totalAnswers++;
    if (isCorrect) {
      _correctAnswers++;
    }
    
    // 如果是普通模式，记录当前问题已被回答
    if (_quizMode == QuizMode.normal) {
      int currentIndex = _questionBank.indexOf(_currentQuestion!);
      _answeredQuestionIndices.add(currentIndex);
    }
    
    // 生成新的随机问题
    generateRandomQuestion();
    
    return isCorrect;
  }

  // 获取当前正确率
  double getAccuracy() {
    if (_totalAnswers == 0) {
      return 0.0;
    }
    return _correctAnswers / _totalAnswers * 100;
  }
  
  // 重置quiz状态
  void reset() {
    _correctAnswers = 0;
    _totalAnswers = 0;
    _currentQuestion = null;
    _answeredQuestionIndices.clear();
  }
  
  // 检查是否所有问题都已回答
  bool isAllQuestionsAnswered() {
    // 只在普通模式下才判断是否答完所有题
    if (_quizMode == QuizMode.endless) {
      return false;
    }
    return _answeredQuestionIndices.length >= _questionBank.length;
  }
  
  // 获取问题库中的问题总数
  int get totalQuestions => _questionBank.length;
  
  // 获取已回答的问题数量
  int get answeredQuestions => _answeredQuestionIndices.length;
} 