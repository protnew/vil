import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/word_card_model.dart';
import '../services/spaced_repetition_service.dart';
import '../widgets/word_card_widget.dart';

class CardScreen extends StatefulWidget {
  const CardScreen({super.key});

  @override
  State<CardScreen> createState() => _CardScreenState();
}

class _CardScreenState extends State<CardScreen> with TickerProviderStateMixin {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  WordCard? _currentCard;
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, int> _statistics = {
    'knowX': 0,
    'learnedM': 0,
    'dontKnowK': 0,
    'total': 0, 
    'sm_learned': 0, 
    'due_today': 0,
  };
  
  late AnimationController _swipeAnimationController;
  late Animation<Color?> _cardColorAnimation;

  @override
  void initState() {
    super.initState();
    _swipeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _cardColorAnimation = ColorTween(
      begin: Colors.transparent,
      end: Colors.green.withOpacity(0.3),
    ).animate(_swipeAnimationController);
    
    _initializeApp();
  }

  @override
  void dispose() {
    _swipeAnimationController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Инициализация базы данных
      await _dbHelper.initDatabase();
      
      // Проверка и вставка начальных данных
      if (await _dbHelper.isDatabaseEmpty()) {
        await _dbHelper.insertInitialData(DatabaseHelper.getInitialCards());
      }
      
      // Загрузка первой карточки и статистики
      await _loadNextCard();
      await _loadStatistics();
      
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка загрузки базы данных: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadNextCard() async {
    try {
      final nextCard = await _dbHelper.getNextCardToReview();
      setState(() {
        _currentCard = nextCard;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка загрузки карточки: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadStatistics() async {
    try {
      final stats = await _dbHelper.getStudyStatistics();
      setState(() {
        _statistics = stats;
      });
    } catch (e) {
      print('Ошибка загрузки статистики: $e');
      // Устанавливаем значения по умолчанию, если есть ошибка
      setState(() {
        _statistics = {
          'knowX': 0,
          'learnedM': 0,
          'dontKnowK': 0,
          'total': 0, 
          'sm_learned': 0, 
          'due_today': 0,
        };
      });
    }
  }

  Future<void> _handleSwipe(bool wasCorrect) async {
    if (_currentCard == null) return;

    WordCard cardToUpdate = _currentCard!;

    // Логика для новых флагов
    if (wasCorrect) {
      cardToUpdate.hasBeenRight = true;
    } else {
      // Если это самый первый свайп (карточка еще не была ни влево, ни вправо)
      if (!cardToUpdate.hasBeenLeft && !cardToUpdate.hasBeenRight) {
        cardToUpdate.firstSwipeLeft = true;
      }
      cardToUpdate.hasBeenLeft = true;
    }

    try {
      // Визуальная обратная связь
      _cardColorAnimation = ColorTween(
        begin: Colors.transparent,
        end: wasCorrect 
            ? Colors.green.withOpacity(0.3)
            : Colors.red.withOpacity(0.3),
      ).animate(_swipeAnimationController);
      
      await _swipeAnimationController.forward();
      await Future.delayed(const Duration(milliseconds: 200));
      await _swipeAnimationController.reverse();

      // Обновление карточки с помощью SRS
      final updatedCardFromSRS = SpacedRepetitionService.calculateNextReviewState(
        cardToUpdate, // Передаем карточку с уже обновленными флагами hasBeen/firstSwipe
        wasCorrect,
      );

      // Сохранение в базу данных
      await _dbHelper.updateCard(updatedCardFromSRS); // SRS мог изменить другие поля, сохраняем результат из SRS
      
      // Обновление счетчика для изученных карточек
      await _dbHelper.incrementCardsSinceLearnedForAllLearned();

      // Загрузка следующей карточки
      await _loadNextCard();
      await _loadStatistics();

    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка обработки ответа: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return InkWell(
              onTap: () {
                print("Menu tapped");
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Icon(Icons.menu, color: Colors.black54),
              ),
            );
          }
        ),
        title: const Text('Изучение слов', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.grey[200],
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Загрузка...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _initializeApp,
              child: const Text('Попробовать снова'),
            ),
          ],
        ),
      );
    }

    if (_currentCard == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.celebration,
              size: 64,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            const Text(
              'Поздравляем!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'На сегодня все карточки изучены!\nВозвращайтесь завтра.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    }

    return WordCardWidget(
      card: _currentCard!,
      onSwipeLeft: () => _handleSwipe(false),
      onSwipeRight: () => _handleSwipe(true),
      knowX: _statistics['knowX'] ?? 0,
      learnedM: _statistics['learnedM'] ?? 0,
      dontKnowK: _statistics['dontKnowK'] ?? 0,
    );
  }
} 