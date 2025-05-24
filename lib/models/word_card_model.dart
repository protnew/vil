class WordCard {
  final int? id;
  final String word;
  final String? transcription;
  final String translation;
  final String? associativePhrase;
  final String imageAssetPath;
  final String? interestingFact;
  final String? wordOrigin;
  bool isLearned;
  double easeFactor;
  int repetitionCount;
  int intervalDays;
  int? nextReviewDate;
  int? lastReviewDate;
  int cardsSinceLearned;
  bool firstSwipeLeft;
  bool hasBeenLeft;
  bool hasBeenRight;

  WordCard({
    this.id,
    required this.word,
    this.transcription,
    required this.translation,
    this.associativePhrase,
    required this.imageAssetPath,
    this.interestingFact,
    this.wordOrigin,
    this.isLearned = false,
    this.easeFactor = 2.5,
    this.repetitionCount = 0,
    this.intervalDays = 1,
    this.nextReviewDate,
    this.lastReviewDate,
    this.cardsSinceLearned = 0,
    this.firstSwipeLeft = false,
    this.hasBeenLeft = false,
    this.hasBeenRight = false,
  });

  // Конвертация из Map (из базы данных)
  factory WordCard.fromMap(Map<String, dynamic> map) {
    return WordCard(
      id: map['id']?.toInt(),
      word: map['word'] ?? '',
      transcription: map['transcription'],
      translation: map['translation'] ?? '',
      associativePhrase: map['associative_phrase'],
      imageAssetPath: map['image_asset_path'] ?? '',
      interestingFact: map['interesting_fact'],
      wordOrigin: map['word_origin'],
      isLearned: (map['is_learned'] ?? 0) == 1,
      easeFactor: map['ease_factor']?.toDouble() ?? 2.5,
      repetitionCount: map['repetition_count']?.toInt() ?? 0,
      intervalDays: map['interval_days']?.toInt() ?? 1,
      nextReviewDate: map['next_review_date']?.toInt(),
      lastReviewDate: map['last_review_date']?.toInt(),
      cardsSinceLearned: map['cards_since_learned']?.toInt() ?? 0,
      firstSwipeLeft: (map['first_swipe_left'] ?? 0) == 1,
      hasBeenLeft: (map['has_been_left'] ?? 0) == 1,
      hasBeenRight: (map['has_been_right'] ?? 0) == 1,
    );
  }

  // Конвертация в Map (для базы данных)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'word': word,
      'transcription': transcription,
      'translation': translation,
      'associative_phrase': associativePhrase,
      'image_asset_path': imageAssetPath,
      'interesting_fact': interestingFact,
      'word_origin': wordOrigin,
      'is_learned': isLearned ? 1 : 0,
      'ease_factor': easeFactor,
      'repetition_count': repetitionCount,
      'interval_days': intervalDays,
      'next_review_date': nextReviewDate,
      'last_review_date': lastReviewDate,
      'cards_since_learned': cardsSinceLearned,
      'first_swipe_left': firstSwipeLeft ? 1 : 0,
      'has_been_left': hasBeenLeft ? 1 : 0,
      'has_been_right': hasBeenRight ? 1 : 0,
    };
  }

  // Метод для удобного обновления карточки
  WordCard copyWith({
    int? id,
    String? word,
    String? transcription,
    String? translation,
    String? associativePhrase,
    String? imageAssetPath,
    String? interestingFact,
    String? wordOrigin,
    bool? isLearned,
    double? easeFactor,
    int? repetitionCount,
    int? intervalDays,
    int? nextReviewDate,
    int? lastReviewDate,
    int? cardsSinceLearned,
    bool? firstSwipeLeft,
    bool? hasBeenLeft,
    bool? hasBeenRight,
  }) {
    return WordCard(
      id: id ?? this.id,
      word: word ?? this.word,
      transcription: transcription ?? this.transcription,
      translation: translation ?? this.translation,
      associativePhrase: associativePhrase ?? this.associativePhrase,
      imageAssetPath: imageAssetPath ?? this.imageAssetPath,
      interestingFact: interestingFact ?? this.interestingFact,
      wordOrigin: wordOrigin ?? this.wordOrigin,
      isLearned: isLearned ?? this.isLearned,
      easeFactor: easeFactor ?? this.easeFactor,
      repetitionCount: repetitionCount ?? this.repetitionCount,
      intervalDays: intervalDays ?? this.intervalDays,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      lastReviewDate: lastReviewDate ?? this.lastReviewDate,
      cardsSinceLearned: cardsSinceLearned ?? this.cardsSinceLearned,
      firstSwipeLeft: firstSwipeLeft ?? this.firstSwipeLeft,
      hasBeenLeft: hasBeenLeft ?? this.hasBeenLeft,
      hasBeenRight: hasBeenRight ?? this.hasBeenRight,
    );
  }
} 