import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LegalQuizPage extends StatefulWidget {
  const LegalQuizPage({super.key});

  @override
  State<LegalQuizPage> createState() => _LegalQuizPageState();
}

class _LegalQuizPageState extends State<LegalQuizPage> with TickerProviderStateMixin {
  int _currentQuestion = 0;
  int _score = 0;
  bool _answered = false;
  int? _selectedAnswer;
  int _highScore = 0;
  late AnimationController _confettiController;

  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'What is the legal age to vote in India?',
      'options': ['16 years', '18 years', '21 years', '25 years'],
      'correct': 1,
      'explanation': 'The legal voting age in India is 18 years as per the 61st Amendment Act, 1988.',
    },
    {
      'question': 'Which article of the Indian Constitution abolishes untouchability?',
      'options': ['Article 14', 'Article 17', 'Article 19', 'Article 25'],
      'correct': 1,
      'explanation': 'Article 17 abolishes untouchability and forbids its practice in any form.',
    },
    {
      'question': 'What is the maximum tenure of a judge in the Supreme Court of India?',
      'options': ['60 years', '62 years', '65 years', '70 years'],
      'correct': 2,
      'explanation': 'A Supreme Court judge retires at the age of 65 years.',
    },
    {
      'question': 'Under which article can the President of India declare a national emergency?',
      'options': ['Article 352', 'Article 356', 'Article 360', 'Article 370'],
      'correct': 0,
      'explanation': 'Article 352 empowers the President to proclaim a national emergency.',
    },
    {
      'question': 'What is the minimum punishment for drunk driving in India?',
      'options': ['₹1,000 fine', '₹5,000 fine', '₹10,000 fine', '₹25,000 fine'],
      'correct': 2,
      'explanation': 'Under the Motor Vehicles Amendment Act 2019, the fine is ₹10,000 and/or imprisonment.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadHighScore();
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _highScore = prefs.getInt('quiz_high_score') ?? 0;
    });
  }

  Future<void> _saveHighScore() async {
    if (_score > _highScore) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('quiz_high_score', _score);
      setState(() => _highScore = _score);
    }
  }

  void _answerQuestion(int index) {
    if (_answered) return;
    
    setState(() {
      _answered = true;
      _selectedAnswer = index;
      if (index == _questions[_currentQuestion]['correct']) {
        _score++;
        _confettiController.forward().then((_) => _confettiController.reverse());
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestion < _questions.length - 1) {
      setState(() {
        _currentQuestion++;
        _answered = false;
        _selectedAnswer = null;
      });
    } else {
      _saveHighScore();
      _showResults();
    }
  }

  void _restartQuiz() {
    setState(() {
      _currentQuestion = 0;
      _score = 0;
      _answered = false;
      _selectedAnswer = null;
    });
  }

  void _showResults() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        final percentage = (_score / _questions.length * 100).toInt();
        
        return Container(
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  percentage >= 80 ? '🏆 Excellent!' : percentage >= 60 ? '👏 Good Job!' : '📚 Keep Learning!',
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(height: 16),
                Text(
                  'Your Score',
                  style: TextStyle(
                    fontSize: 18,
                    color: isDarkMode ? Colors.grey : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$_score / ${_questions.length}',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : const Color(0xFF121317),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$percentage% Correct',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: percentage >= 60 ? Colors.green : Colors.orange,
                  ),
                ),
                if (_score > _highScore) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.stars, color: Colors.amber),
                        SizedBox(width: 8),
                        Text(
                          'New High Score!',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (_highScore > 0) ...[
                  const SizedBox(height: 16),
                  Text(
                    'High Score: $_highScore/${_questions.length}',
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey : Colors.grey[600],
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        child: const Text('Close'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _restartQuiz();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF253D79),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Play Again'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final question = _questions[_currentQuestion];
    
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF14171E) : const Color(0xFFF6F7F8),
      appBar: AppBar(
        backgroundColor: isDarkMode ? const Color(0xFF14171E) : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : const Color(0xFF121317),
        elevation: 0,
        title: const Text('Legal Quiz'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                'Score: $_score/${_questions.length}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress
          LinearProgressIndicator(
            value: (_currentQuestion + 1) / _questions.length,
            backgroundColor: isDarkMode ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF253D79)),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Question ${_currentQuestion + 1} of ${_questions.length}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? const Color(0xFFF6B21D) : const Color(0xFF253D79),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    question['question'],
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      height: 1.4,
                      color: isDarkMode ? Colors.white : const Color(0xFF121317),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Options
                  ...List.generate(
                    (question['options'] as List).length,
                    (index) => _buildOption(
                      index,
                      question['options'][index],
                      question['correct'] == index,
                      isDarkMode,
                    ),
                  ),
                  
                  if (_answered) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: (_selectedAnswer == question['correct']
                            ? Colors.green
                            : Colors.orange).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedAnswer == question['correct']
                              ? Colors.green
                              : Colors.orange,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _selectedAnswer == question['correct']
                                    ? Icons.check_circle
                                    : Icons.info_outline,
                                color: _selectedAnswer == question['correct']
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _selectedAnswer == question['correct']
                                    ? 'Correct!'
                                    : 'Not quite!',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: _selectedAnswer == question['correct']
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            question['explanation'],
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: isDarkMode ? Colors.white : const Color(0xFF121317),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _nextQuestion,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF253D79),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          _currentQuestion < _questions.length - 1
                              ? 'Next Question'
                              : 'See Results',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(int index, String text, bool isCorrect, bool isDarkMode) {
    final isSelected = _selectedAnswer == index;
    final showResult = _answered;
    
    Color bgColor;
    Color borderColor;
    Color textColor;
    
    if (showResult) {
      if (isCorrect) {
        bgColor = Colors.green.withOpacity(0.1);
        borderColor = Colors.green;
        textColor = Colors.green;
      } else if (isSelected) {
        bgColor = Colors.red.withOpacity(0.1);
        borderColor = Colors.red;
        textColor = Colors.red;
      } else {
        bgColor = isDarkMode ? const Color(0xFF1F2937) : Colors.white;
        borderColor = isDarkMode ? const Color(0xFF374151) : const Color(0xFFE5E7EB);
        textColor = isDarkMode ? Colors.grey : Colors.grey;
      }
    } else {
      bgColor = isSelected
          ? (isDarkMode ? const Color(0xFF253D79) : const Color(0xFF253D79).withOpacity(0.1))
          : (isDarkMode ? const Color(0xFF1F2937) : Colors.white);
      borderColor = isSelected
          ? const Color(0xFF253D79)
          : (isDarkMode ? const Color(0xFF374151) : const Color(0xFFE5E7EB));
      textColor = isSelected
          ? (isDarkMode ? Colors.white : const Color(0xFF253D79))
          : (isDarkMode ? Colors.white : const Color(0xFF121317));
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _answerQuestion(index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: borderColor,
                ),
                child: Center(
                  child: Text(
                    String.fromCharCode(65 + index),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: textColor,
                  ),
                ),
              ),
              if (showResult && isCorrect)
                const Icon(Icons.check_circle, color: Colors.green),
              if (showResult && isSelected && !isCorrect)
                const Icon(Icons.cancel, color: Colors.red),
            ],
          ),
        ),
      ),
    );
  }
}
