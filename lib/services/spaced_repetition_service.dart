import 'dart:math';
import '../models/word_card_model.dart';

class SpacedRepetitionService {
  static WordCard calculateNextReviewState(WordCard currentCard, bool wasCorrect) {
    final now = DateTime.now().millisecondsSinceEpoch;
    
    if (wasCorrect) {
      return _handleCorrectAnswer(currentCard, now);
    } else {
      return _handleIncorrectAnswer(currentCard, now);
    }
  }

  static WordCard _handleCorrectAnswer(WordCard card, int timestamp) {
    int newRepetitionCount = card.repetitionCount + 1;
    int newIntervalDays;
    double newEaseFactor = min(2.5, card.easeFactor + 0.1);
    
    if (card.repetitionCount == 0) {
      newIntervalDays = 1;
    } else if (card.repetitionCount == 1) {
      newIntervalDays = 6;
    } else {
      newIntervalDays = (card.intervalDays * card.easeFactor).round();
    }
    
    final nextReviewDate = timestamp + (newIntervalDays * 24 * 60 * 60 * 1000);
    final isLearned = newRepetitionCount >= 3 || newIntervalDays > 21;
    
    return card.copyWith(
      repetitionCount: newRepetitionCount,
      intervalDays: newIntervalDays,
      easeFactor: newEaseFactor,
      nextReviewDate: nextReviewDate,
      lastReviewDate: timestamp,
      isLearned: isLearned,
      cardsSinceLearned: 0, // Сброс счетчика
    );
  }

  static WordCard _handleIncorrectAnswer(WordCard card, int timestamp) {
    final newEaseFactor = max(1.3, card.easeFactor - 0.2);
    final nextReviewDate = timestamp + (1 * 24 * 60 * 60 * 1000); // +1 день
    
    return card.copyWith(
      repetitionCount: 0,
      intervalDays: 1,
      easeFactor: newEaseFactor,
      nextReviewDate: nextReviewDate,
      lastReviewDate: timestamp,
      isLearned: false,
    );
  }
} 