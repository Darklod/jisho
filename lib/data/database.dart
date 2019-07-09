import 'package:mongo_dart/mongo_dart.dart';

import 'package:jisho/data/crendentials.dart';
import 'package:jisho/models/word.dart';
import 'package:jisho/models/kanji.dart' as k;
import 'package:jisho/utils/japanese.dart';

class WordDatabase {
  static final _wordDatabase = new WordDatabase._internal();

  Db db;

  bool didInit = false;

  static WordDatabase get() {
    return _wordDatabase;
  }

  WordDatabase._internal();

  Future<Db> _getDb() async {
    if (!didInit) await _init();
    return db;
  }

  Future _init() async {
    var usr = Credentials.username;
    var pwd = Credentials.password;

    db = new Db("mongodb://$usr:$pwd@ds135786.mlab.com:35786/jisho");
    await db.open();

    didInit = true;
  }

  Future init() async {
    return await _init();
  }

  Future close() async {
    var db = await _getDb();
    return db.close();
  }

  Future<List<Word>> findWords(String query) async {
    await _getDb();

    String param;
    if (Japanese.hasKanji(query)) {
      param = "kanji.text";
    } else if (Japanese.hasKana(query)) {
      param = "kana.text";
    } else {
      param = "sense.gloss.text";
    }

    var result = await db
        .collection('words')
        .find(where.match(param, "^$query"))
        .take(10)
        .toList();

    List<Word> words = [];
    result.forEach((map) => words.add(new Word.fromMap(map)));

    return words;
  }

  Future<List<Word>> getWords(String property) async {
    await _getDb();

    var result =
        await db.collection('words').find(where.eq(property, true)).toList();

    List<Word> words = [];

    for (Map<String, dynamic> map in result) {
      words.add(new Word.fromMap(map));
    }

    return words;
  }

  Future updateWord(String id, String property, bool value) async {
    await _getDb();

    await db
        .collection('words')
        .update(where.eq("id", id), modify.set(property, value));
  }

  Future<List<k.Kanji>> getKanjiList(List<String> list) async {
    await _getDb();

    var result = await db.collection('kanji').find({
      'literal': {"\$in": list}
    }).toList();

    List<k.Kanji> kanji = [];

    for (var x in list) {
      var el = result.singleWhere((r) => r["literal"] == x); // keep order
      if (el != null) kanji.add(k.Kanji.fromMap(el));
    }

    return kanji;
  }

  Future<k.Kanji> getKanji(String text) async {
    await _getDb();

    var result =
        await db.collection('kanji').findOne(where.eq("literal", text));

    return new k.Kanji.fromMap(result);
  }
}
