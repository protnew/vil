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
    
    return [
      WordCard(
        word: 'Kettle',
        transcription: 'ˈkɛtl',
        translation: 'чайник',
        associativePhrase: 'КЕТчуп льют из ЧАЙНИКА',
        imageAssetPath: 'assets/images/kettle_1.webp',
        interestingFact: 'Чайники широко распространены в Англии, где чай является очень популярным напитком.',
        wordOrigin: 'Др.-англ. cetel, cytel "чайник, котел" ← Прагерм. *katilaz "котел" ← Лат. catillus (уменьш. от catīnus "глубокая миска, горшок для приготовления пищи"). Возможно, отдаленно связано с праиндоевр. *gʰet- "сосуд".',
        nextReviewDate: now,
      ),
      WordCard(
        word: 'Scissors',
        transcription: 'ˈsɪzərz',
        translation: 'ножницы',
        associativePhrase: 'СИЗЫЙ голубь режет НОЖНИЦАМИ',
        imageAssetPath: 'assets/images/scissors_1.webp',
        interestingFact: 'Ножницы известны с древности; Леонардо да Винчи, возможно, усовершенствовал их конструкцию.',
        wordOrigin: 'Старофр. cisoires (мн.ч.) ← Позднелат. *cisoria (мн.ч. от *cisorium "режущий инструмент") ← Лат. caedere "резать, рубить" ← праиндоевр. *kh₂eyd- "резать, ударять".',
        nextReviewDate: now,
      ),
      WordCard(
        word: 'Wind',
        transcription: 'wɪnd',
        translation: 'ветер',
        associativePhrase: 'ВИНДсёрфинг и ветер',
        imageAssetPath: 'assets/images/wind_2.webp',
        interestingFact: 'Самый сильный порыв ветра (408 км/ч) зафиксирован на о-ве Барроу (Австралия) в 1996 г. (циклон Оливия).',
        wordOrigin: 'Др.-англ. wind "ветер" ← Прагерм. *windaz "ветер" ← праиндоевр. *h₂wéh₁n̥ts "дующий" (прич. от *h₂weh₁- "дуть"). Родственно санскр. वात (vāta) "ветер".',
        nextReviewDate: now,
      ),
      WordCard(
        word: 'Sand',
        transcription: 'sænd',
        translation: 'песок',
        associativePhrase: 'СЭНДвич наполнен песком вместо ветчины',
        imageAssetPath: 'assets/images/sand_1.webp',
        interestingFact: 'Пустыня Сахара большей частью (ок. 70-80%) состоит из камня и гравия, а не из песка.',
        wordOrigin: 'Др.-англ. sand "песок, гравий, берег" ← Прагерм. *sandam "песок" ← праиндоевр. *sámHdʰos "песок, гравий".',
        nextReviewDate: now,
      ),
      WordCard(
        word: 'Hill',
        transcription: 'hɪl',
        translation: 'холм',
        associativePhrase: 'ХИЛый поднялся на ХОЛМ',
        imageAssetPath: 'assets/images/hill_1.webp',
        interestingFact: 'Голгофа в Иерусалиме – один из самых известных холмов в мире.',
        wordOrigin: 'Др.-англ. hyll "холм" ← Прагерм. *hulliz, *hulnijaz "холм" ← праиндоевр. *kolHn- "холм, вершина" (от корня *kelH- "подниматься, выдаваться"). Родственно санскр. शैल (śaila) "холм, гора".',
        nextReviewDate: now,
      ),
      WordCard(
        word: 'Ice',
        transcription: 'aɪs',
        translation: 'лёд',
        associativePhrase: 'АЙСберг улыбается и добавляет ЛЁД себе в коктейль',
        imageAssetPath: 'assets/images/ice_1.webp',
        interestingFact: 'Лёд покрывает около 10% поверхности суши Земли.',
        wordOrigin: 'Др.-англ. īs "лёд" ← Прагерм. *īsą, *īsaz "лёд" ← праиндоевр. *h₁eyH-s-, *h₁eyH-g- "лёд, иней".',
        nextReviewDate: now,
      ),
      WordCard(
        word: 'King',
        transcription: 'kɪŋ',
        translation: 'король',
        associativePhrase: 'КИНГ Конг надел золотую корону и стал КОРОЛЁМ джунглей',
        imageAssetPath: 'assets/images/king_1.webp',
        interestingFact: 'Генрих VI стал королем Англии в возрасте около 8-9 месяцев.',
        wordOrigin: 'Др.-англ. cyning "король" ← Прагерм. *kuningaz "король" (букв. "принадлежащий к роду/знати") ← *kunjam "род, племя" ← праиндоевр. *ǵenh₁- "рождать, производить".',
        nextReviewDate: now,
      ),
      WordCard(
        word: 'Leaf',
        transcription: 'liːf',
        translation: 'лист',
        associativePhrase: 'Человек ЛИФтом поднимает огромный зелёный ЛИСТ',
        imageAssetPath: 'assets/images/leaf_1.webp',
        interestingFact: 'Листья пальмы *Raphia regalis* могут достигать 25 метров в длину.',
        wordOrigin: 'Др.-англ. lēaf "лист растения, страница" ← Прагерм. *laubą "лист" ← праиндоевр. *lowbʰ-o-m (от *lewbʰ- "сдирать, кора, лист"). Родственно рус. "луб".',
        nextReviewDate: now,
      ),
      WordCard(
        word: 'Horse',
        transcription: 'hɔːrs',
        translation: 'лошадь',
        associativePhrase: 'ХОРС поёт хор ЛОШАДЕЙ в конюшне',
        imageAssetPath: 'assets/images/horse_1.webp',
        interestingFact: 'Лошади могут спать (дремать) стоя благодаря особому аппарату фиксации в ногах; для глубокого сна ложатся.',
        wordOrigin: 'Др.-англ. hors "лошадь" ← Прагерм. *hrussą "лошадь" (букв. "быстрый") ← праиндоевр. *ḱr̥s-o- (от *ḱers- "бежать").',
        nextReviewDate: now,
      ),
    ];
  }
} 