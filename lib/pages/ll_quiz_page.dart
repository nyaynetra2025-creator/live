import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import '../services/supabase_service.dart';

class LLQuizPage extends StatefulWidget {
  const LLQuizPage({super.key});

  @override
  State<LLQuizPage> createState() => _LLQuizPageState();
}

class _LLQuizPageState extends State<LLQuizPage> {
  final SupabaseService _supabaseService = SupabaseService();
  bool _isLoading = true;
  bool _quizStarted = false;
  bool _quizCompleted = false;
  List<Map<String, dynamic>> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  String? _selectedAnswer;
  bool _answerSubmitted = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() => _isLoading = true);
    try {
      final questions = await _supabaseService.getQuizQuestions(limit: 10);
      if (mounted) {
        setState(() {
          _questions = questions;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading quiz: $e')),
        );
      }
    }
  }

  void _startQuiz() {
    setState(() {
      _quizStarted = true;
      _currentQuestionIndex = 0;
      _score = 0;
      _selectedAnswer = null;
      _answerSubmitted = false;
    });
  }

  void _submitAnswer() {
    if (_selectedAnswer == null) return;
    
    final correctAnswer = _questions[_currentQuestionIndex]['correct_answer'];
    if (_selectedAnswer == correctAnswer) {
      setState(() => _score++);
    }
    
    setState(() => _answerSubmitted = true);
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
        _answerSubmitted = false;
      });
    } else {
      setState(() => _quizCompleted = true);
    }
  }

  void _restartQuiz() {
    setState(() {
      _quizCompleted = false;
      _quizStarted = false;
      _currentQuestionIndex = 0;
      _score = 0;
      _selectedAnswer = null;
      _answerSubmitted = false;
    });
    _loadQuestions();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDarkMode ? const Color(0xFF14171E) : const Color(0xFFF6F7F8),
        appBar: AppBar(
          title: const Text('LL Practice Test'),
          backgroundColor: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: isDarkMode ? const Color(0xFF14171E) : const Color(0xFFF6F7F8),
        appBar: AppBar(
          title: const Text('LL Practice Test'),
          backgroundColor: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
        ),
        body: const Center(child: Text('No questions available')),
      );
    }

    if (!_quizStarted) {
      return _buildStartScreen(isDarkMode);
    }

    if (_quizCompleted) {
      return _buildResultsScreen(isDarkMode);
    }

    return _buildQuizScreen(isDarkMode);
  }

  Widget _buildStartScreen(bool isDarkMode) {
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF14171E) : const Color(0xFFF6F7F8),
      appBar: AppBar(
        title: Text(
          'LL Practice Test',
          style: TextStyle(
            color: isDarkMode ? const Color(0xFFF5F5F7) : const Color(0xFF121317),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
        leading: BackButton(
          color: isDarkMode ? const Color(0xFFF5F5F7) : const Color(0xFF121317),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                IconlyBold.document,
                size: 100,
                color: isDarkMode ? const Color(0xFF253D79) : const Color(0xFF3B82F6),
              ),
              const SizedBox(height: 24),
              Text(
                'Ready for the Test?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? const Color(0xFFF5F5F7) : const Color(0xFF121317),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Answer 10 questions to test your knowledge',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode ? const Color(0xFFA0AEC0) : const Color(0xFF687082),
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(Icons.quiz, '10 Questions', isDarkMode),
                    const SizedBox(height: 12),
                    _buildInfoRow(Icons.timer_outlined, 'No Time Limit', isDarkMode),
                    const SizedBox(height: 12),
                    _buildInfoRow(Icons.check_circle_outline, 'Instant Feedback', isDarkMode),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _startQuiz,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF253D79),
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Start Test',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, bool isDarkMode) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF253D79), size: 24),
        const SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            color: isDarkMode ? const Color(0xFFF5F5F7) : const Color(0xFF121317),
          ),
        ),
      ],
    );
  }

  Widget _buildQuizScreen(bool isDarkMode) {
    final question = _questions[_currentQuestionIndex];
    final correctAnswer = question['correct_answer'];

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF14171E) : const Color(0xFFF6F7F8),
      appBar: AppBar(
        title: Text(
          'Question ${_currentQuestionIndex + 1}/${_questions.length}',
          style: TextStyle(
            color: isDarkMode ? const Color(0xFFF5F5F7) : const Color(0xFF121317),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
        leading: BackButton(
          color: isDarkMode ? const Color(0xFFF5F5F7) : const Color(0xFF121317),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                'Score: $_score/${_questions.length}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? const Color(0xFFF6B21D) : const Color(0xFF253D79),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                question['question'],
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? const Color(0xFFF5F5F7) : const Color(0xFF121317),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ...['A', 'B', 'C', 'D'].map((option) {
              final optionText = question['option_${option.toLowerCase()}'];
              final isSelected = _selectedAnswer == option;
              final isCorrect = option == correctAnswer;
              
              Color? backgroundColor;
              Color? borderColor;
              
              if (_answerSubmitted) {
                if (isCorrect) {
                  backgroundColor = Colors.green.withOpacity(0.1);
                  borderColor = Colors.green;
                } else if (isSelected) {
                  backgroundColor = Colors.red.withOpacity(0.1);
                  borderColor = Colors.red;
                }
              } else if (isSelected) {
                backgroundColor = const Color(0xFF253D79).withOpacity(0.1);
                borderColor = const Color(0xFF253D79);
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: _answerSubmitted ? null : () => setState(() => _selectedAnswer = option),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: backgroundColor ?? (isDarkMode ? const Color(0xFF1F2937) : Colors.white),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: borderColor ?? (isDarkMode ? const Color(0xFF374151) : const Color(0xFFE5E7EB)),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: borderColor ?? (isDarkMode ? const Color(0xFF374151) : const Color(0xFFE5E7EB)),
                          ),
                          child: Center(
                            child: Text(
                              option,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: borderColor != null ? Colors.white : (isDarkMode ? Colors.white : Colors.black),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            optionText,
                            style: TextStyle(
                              fontSize: 16,
                              color: isDarkMode ? const Color(0xFFF5F5F7) : const Color(0xFF121317),
                            ),
                          ),
                        ),
                        if (_answerSubmitted && isCorrect)
                          const Icon(Icons.check_circle, color: Colors.green),
                        if (_answerSubmitted && isSelected && !isCorrect)
                          const Icon(Icons.cancel, color: Colors.red),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _answerSubmitted ? _nextQuestion : (_selectedAnswer != null ? _submitAnswer : null),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _answerSubmitted ? Colors.green : const Color(0xFF253D79),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  _answerSubmitted 
                      ? (_currentQuestionIndex < _questions.length - 1 ? 'Next Question' : 'View Results')
                      : 'Submit Answer',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsScreen(bool isDarkMode) {
    final percentage = (_score / _questions.length * 100).round();
    final passed = percentage >= 60;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF14171E) : const Color(0xFFF6F7F8),
      appBar: AppBar(
        title: Text(
          'Test Results',
          style: TextStyle(
            color: isDarkMode ? const Color(0xFFF5F5F7) : const Color(0xFF121317),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
        leading: BackButton(
          color: isDarkMode ? const Color(0xFFF5F5F7) : const Color(0xFF121317),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                passed ? Icons.check_circle : Icons.cancel,
                size: 100,
                color: passed ? Colors.green : Colors.red,
              ),
              const SizedBox(height: 24),
              Text(
                passed ? 'Congratulations!' : 'Keep Practicing!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? const Color(0xFFF5F5F7) : const Color(0xFF121317),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'You scored',
                style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode ? const Color(0xFFA0AEC0) : const Color(0xFF687082),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$_score/${_questions.length}',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: passed ? Colors.green : Colors.red,
                ),
              ),
              Text(
                '$percentage%',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? const Color(0xFFA0AEC0) : const Color(0xFF687082),
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildResultRow('Correct Answers', '$_score', Colors.green, isDarkMode),
                    const SizedBox(height: 12),
                    _buildResultRow('Wrong Answers', '${_questions.length - _score}', Colors.red, isDarkMode),
                    const SizedBox(height: 12),
                    _buildResultRow('Pass Mark', '60%', const Color(0xFF253D79), isDarkMode),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDarkMode ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        'Exit',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _restartQuiz,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF253D79),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'Try Again',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value, Color color, bool isDarkMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: isDarkMode ? const Color(0xFFA0AEC0) : const Color(0xFF687082),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
