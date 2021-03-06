import 'package:flutter/material.dart';
import 'package:jisho/data/repository.dart';

import 'package:jisho/models/word.dart';
import 'package:jisho/widgets/word/word_item.dart';
import 'package:jisho/pages/details_page.dart';
import 'package:jisho/utils/slide.dart';

class WordList extends StatelessWidget {
  final List<Word> words;

  WordList(this.words);

  final repository = Repository.get();

  @override
  Widget build(BuildContext context) {
    var count = words == null ? -1 : words.length;

    return ListView.separated(
      shrinkWrap: true,
      separatorBuilder: (context, index) => Divider(height: 1.0),
      itemCount: count + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Words - $count found"),
          );
        }

        index--; // decrease the current index each time

        return FlatButton(
          padding: EdgeInsets.all(16.0),
          child: WordItem(words[index]),
          onPressed: () async {
            if (!await repository.isVisitedWord(words[index]))
              repository.addToHistory(words[index]);

            var route = Slide(
              builder: (context) => DetailPage(words[index]),
            );
            Navigator.push(context, route);
          },
        );
      },
    );
  }
}
