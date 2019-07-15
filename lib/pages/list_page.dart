import 'package:flutter/material.dart';

import 'package:jisho/models/word.dart';
import 'package:jisho/data/repository.dart';
import 'package:jisho/widgets/search/search_bar.dart';
import 'package:jisho/widgets/word/word_list.dart';

import 'package:jisho/data/word_dao.dart';

class ListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  MapEntry<String, List<Word>> _old;
  String _input;

  _fetchData(query) async {
    if (query == null || query == "") return null;

    if (query == _old.key) return _old.value; // future?

    //return await Repository.get().findWords(query);
    return await WordDao().find(query);
  }

  message() => Container(
        child: Expanded(
          flex: 1,
          child: Center(
            child: Text(
              "辞書",
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                  fontSize: 120.0),
            ),
          ),
        ),
      );

  updateSearch(value) {
    setState(() {
      _input = value;
    });
  }

  @override
  void initState() {
    super.initState();

    _old = Repository.get().getLastSearch();
    updateSearch(_old.key);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jisho'),
        backgroundColor: Colors.red[400],
        elevation: 0,
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            SearchBar(updateSearch),
            FutureBuilder(
                future: _fetchData(_input),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                      return message();
                    case ConnectionState.active:
                    case ConnectionState.waiting:
                      return Expanded(
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.amber),
                          ),
                        ),
                      );
                    case ConnectionState.done:
                      if (snapshot.hasError)
                        return Text(
                          'Error:\n\n${snapshot.error}',
                          textAlign: TextAlign.center,
                        );
                      else if (snapshot.data == null)
                        return message();
                      else
                        return Expanded(
                          child: WordList(snapshot.data),
                        );
                  }
                }),
          ],
        ),
      ),
    );
  }
}
