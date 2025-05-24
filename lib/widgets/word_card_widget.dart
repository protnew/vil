import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/word_card_model.dart';

class WordCardWidget extends StatelessWidget {
  final WordCard card;
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;
  final int knowX;
  final int learnedM;
  final int dontKnowK;

  const WordCardWidget({
    super.key,
    required this.card,
    required this.onSwipeLeft,
    required this.onSwipeRight,
    required this.knowX,
    required this.learnedM,
    required this.dontKnowK,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! > 300) {
          // Свайп вправо - "Запомнил"
          HapticFeedback.lightImpact();
          onSwipeRight();
        } else if (details.primaryVelocity! < -300) {
          // Свайп влево - "Не запомнил"
          HapticFeedback.mediumImpact();
          onSwipeLeft();
        }
      },
      child: Card(
        elevation: 0.0,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Изображение (40% высоты карточки)
              Expanded(
                flex: 4,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    card.imageAssetPath,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image,
                              size: 50,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Изображение недоступно',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Информация о слове
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Слово
                    Text(
                      card.word,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Транскрипция
                    if (card.transcription != null)
                      Text(
                        '[${card.transcription}]',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey[700],
                        ),
                      ),
                    const SizedBox(height: 8),
                    
                    // Перевод
                    Text(
                      card.translation,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Ассоциативная фраза
                    if (card.associativePhrase != null)
                      Text(
                        card.associativePhrase!,
                        style: TextStyle(
                          fontSize: 20,
                          fontStyle: FontStyle.italic,
                          color: Colors.blue[700],
                        ),
                      ),
                    
                    const SizedBox(height: 16),
                    
                    // Дополнительная информация
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // const Text(
                            //   '▼ Дополнительная информация',
                            //   style: TextStyle(
                            //     fontWeight: FontWeight.w500,
                            //     color: Colors.grey,
                            //   ),
                            // ),
                            // const SizedBox(height: 8), // Можно оставить или убрать, если текст был единственным элементом
                            
                            if (card.interestingFact != null)
                              _buildInfoRow(
                                Icons.book,
                                'Интересный факт:',
                                card.interestingFact!,
                              ),
                            
                            if (card.wordOrigin != null)
                              _buildInfoRow(
                                Icons.account_balance,
                                'Происхождение:',
                                card.wordOrigin!,
                              ),
                            
                            const SizedBox(height: 16),
                            
                            // Прогресс
                            _buildProgressIndicator(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                children: [
                  TextSpan(
                    text: '$label ',
                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                  ),
                  TextSpan(text: text, style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text('Знаете: $knowX', style: const TextStyle(fontSize: 14)),
          Text('Выучили: $learnedM', style: const TextStyle(fontSize: 14)),
          Text('Не знаете: $dontKnowK', style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
} 