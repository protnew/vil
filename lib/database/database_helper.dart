import 'dart:math';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/word_card_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;
  static const String _dbName = 'vocab_cards.db';
  static const int _dbVersion = 2; // Увеличиваем версию БД

  Future<Database> get database async {
    _database ??= await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), _dbName);
    
    return await openDatabase(
      path,
      version: _dbVersion, // Используем новую версию
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE word_cards (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            word TEXT NOT NULL,
            transcription TEXT,
            translation TEXT NOT NULL,
            associative_phrase TEXT,
            image_asset_path TEXT NOT NULL,
            interesting_fact TEXT,
            word_origin TEXT,
            is_learned INTEGER DEFAULT 0,
            ease_factor REAL DEFAULT 2.5,
            repetition_count INTEGER DEFAULT 0,
            interval_days INTEGER DEFAULT 1,
            next_review_date INTEGER,
            last_review_date INTEGER,
            cards_since_learned INTEGER DEFAULT 0,
            first_swipe_left INTEGER DEFAULT 0,
            has_been_left INTEGER DEFAULT 0,
            has_been_right INTEGER DEFAULT 0
          )
        ''');
      },
      // onUpgrade можно добавить для более сложных миграций, но для MVP onCreate при смене версии достаточно
    );
  }

  Future<bool> isDatabaseEmpty() async {
    final db = await database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM word_cards')
    );
    return count == 0;
  }

  Future<void> insertInitialData(List<WordCard> initialCards) async {
    final db = await database;
    final batch = db.batch();
    
    for (final card in initialCards) {
      // Убедимся, что toMap() включает новые поля с их значениями по умолчанию (0 для false)
      batch.insert('word_cards', card.toMap()); 
    }
    
    await batch.commit();
  }

  Future<WordCard?> getNextCardToReview() async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    final urgentCards = await db.query(
      'word_cards',
      where: 'next_review_date <= ? AND (is_learned = 0 OR (is_learned = 1 AND cards_since_learned >= 100))',
      whereArgs: [now],
      orderBy: 'RANDOM()',
      limit: 1,
    );
    
    if (urgentCards.isNotEmpty) {
      return WordCard.fromMap(urgentCards.first);
    }
    
    final newCards = await db.query(
      'word_cards',
      where: 'repetition_count = 0',
      orderBy: 'id ASC',
      limit: 1,
    );
    
    if (newCards.isNotEmpty) {
      return WordCard.fromMap(newCards.first);
    }
    
    return null;
  }

  Future<void> updateCard(WordCard card) async {
    final db = await database;
    await db.update(
      'word_cards',
      card.toMap(),
      where: 'id = ?',
      whereArgs: [card.id],
    );
  }

  Future<void> incrementCardsSinceLearnedForAllLearned() async {
    final db = await database;
    await db.rawUpdate(
      'UPDATE word_cards SET cards_since_learned = cards_since_learned + 1 WHERE is_learned = 1'
    );
  }

  Future<List<WordCard>> getAllCards() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('word_cards');
    return List.generate(maps.length, (i) {
      return WordCard.fromMap(maps[i]);
    });
  }

  Future<Map<String, int>> getStudyStatistics() async {
    final List<WordCard> allCards = await getAllCards();
    
    int knowX = 0;
    int learnedM = 0;
    int dontKnowK = 0;

    for (final card in allCards) {
      if (card.hasBeenRight) {
        knowX++;
      }
      if (card.firstSwipeLeft && card.hasBeenRight) {
        learnedM++;
      }
      if (card.hasBeenLeft && !card.hasBeenRight) {
        dontKnowK++;
      }
    }
    
    // Старые счетчики для совместимости или если они понадобятся где-то еще
    final db = await database; // нужен для legacy статистики
    final now = DateTime.now().millisecondsSinceEpoch;
    final total = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM word_cards')
    ) ?? 0;
    final smLearned = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM word_cards WHERE is_learned = 1')
    ) ?? 0;
    final dueToday = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM word_cards WHERE next_review_date <= ?', [now])
    ) ?? 0;

    return {
      'knowX': knowX,
      'learnedM': learnedM,
      'dontKnowK': dontKnowK,
      'total': total, // старый счетчик
      'sm_learned': smLearned, // старый счетчик
      'due_today': dueToday, // старый счетчик
    };
  }

  static List<WordCard> getInitialCards() {
    final now = DateTime.now().millisecondsSinceEpoch;
    
    // Новые поля будут инициализированы значениями по умолчанию из конструктора WordCard (false)
    return [
      WordCard(
        word: 'Sun',
        transcription: 'sʌn',
        translation: 'солнце',
        associativePhrase: 'САНя под СОЛНЦЕМ сгорел',
        imageAssetPath: 'assets/images/sun1.jpg',
        interestingFact: 'Солнце древние считали богом',
        wordOrigin: 'Древнеанглийское sunne, от прагерм. *sunnǭ',
        nextReviewDate: now,
      ),
      WordCard(
        word: 'Moon',
        transcription: 'mu:n',
        translation: 'луна',
        associativePhrase: 'МУравьи на ЛУНе гуляют',
        imageAssetPath: 'assets/images/moon1.jpg',
        interestingFact: 'Луна всегда повернута к Земле одной стороной',
        wordOrigin: 'Древнеанглийское mōna, от прагерм. *mēnô',
        nextReviewDate: now,
      ),
      WordCard(
        word: 'Tree',
        transcription: 'tri:',
        translation: 'дерево',
        associativePhrase: 'ТРИ ДЕРЕВА – уже лес',
        imageAssetPath: 'assets/images/tree1.jpg',
        interestingFact: 'Самое старое дерево на Земле около 5000 лет',
        wordOrigin: 'Древнеанглийское trēow, от прагерм. *trewą',
        nextReviewDate: now,
      ),
      WordCard(
        word: 'Star',
        transcription: 'stɑːr',
        translation: 'звезда',
        associativePhrase: 'СТАРуха звезда эстрады',
        imageAssetPath: 'assets/images/star1.jpg',
        interestingFact: 'Свет звёзд, который мы видим, шёл до Земли сотни лет',
        wordOrigin: 'Древнеанглийское steorra, от прагерм. *sterrô',
        nextReviewDate: now,
      ),
    ];
  }
} 