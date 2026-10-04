import 'package:audiflow_podcast/audiflow_podcast.dart';
import 'package:flutter_test/flutter_test.dart';

const _parser = DescriptionChaptersParser();

List<String> _titles(String description, {Duration? duration}) => _parser
    .parse(description, episodeDuration: duration)
    .map((c) => c.title)
    .toList();

List<Duration> _starts(String description) =>
    _parser.parse(description).map((c) => c.startTime).toList();

void main() {
  group('DescriptionChaptersParser accepts', () {
    test('a Japanese <br />-separated list from a real feed', () {
      const description =
          '<p>•─────• 💬 <strong>Topics</strong> 💬 •─────•<br />'
          '00:00 オープニング・改名のご報告<br />'
          '02:57 人生の選択とエレベーターでの挨拶<br />'
          '17:22 餃子の王将とイベントでの出会い<br />'
          '21:32 ビデオポッドキャストの感想<br />'
          '23:58 量子力学の絵本<br />'
          '33:21 フラネカーのプラネタリウムとオールトの雲<br />'
          '37:15 ニュートンの実家と暗号解読機について<br />'
          '45:51 暗号を解く方法を発見したら発表すべきか<br />'
          '52:41 イベントのお知らせ<br /></p>';

      final chapters = _parser.parse(
        description,
        episodeDuration: const Duration(minutes: 58),
      );

      expect(chapters.map((c) => c.title), [
        'オープニング・改名のご報告',
        '人生の選択とエレベーターでの挨拶',
        '餃子の王将とイベントでの出会い',
        'ビデオポッドキャストの感想',
        '量子力学の絵本',
        'フラネカーのプラネタリウムとオールトの雲',
        'ニュートンの実家と暗号解読機について',
        '暗号を解く方法を発見したら発表すべきか',
        'イベントのお知らせ',
      ]);
      expect(chapters[1].startTime, const Duration(minutes: 2, seconds: 57));
      expect(chapters.last.startTime, const Duration(minutes: 52, seconds: 41));
    });

    test('an English plain-text list with separators', () {
      const description = '''
In this episode we talk about things.

0:00 - Intro
5:12 – The main topic:
12:40: Listener questions
''';

      expect(_titles(description), [
        'Intro',
        'The main topic',
        'Listener questions',
      ]);
      expect(_starts(description)[1], const Duration(minutes: 5, seconds: 12));
    });

    test('bullet-prefixed list items', () {
      const description =
          '<ul><li>• 00:00 Opening</li><li>• 10:00 News</li>'
          '<li>• 20:00 Closing</li></ul>';

      expect(_titles(description), ['Opening', 'News', 'Closing']);
    });

    test('bracketed times and a paragraph per line', () {
      const description =
          '<p>[00:00] Welcome</p><p>[03:30] Guest intro</p>'
          '<p>(15:00) Deep dive</p>';

      expect(_titles(description), ['Welcome', 'Guest intro', 'Deep dive']);
    });

    test('hour-long episodes with h:mm:ss times', () {
      const description = '''
00:00:00 Start
0:45:10 Middle
1:02:03 Late topic
1:30:00 Wrap up
''';

      expect(_starts(description), [
        Duration.zero,
        const Duration(minutes: 45, seconds: 10),
        const Duration(hours: 1, minutes: 2, seconds: 3),
        const Duration(hours: 1, minutes: 30),
      ]);
    });

    test('a short intro before the first entry', () {
      expect(_titles('0:08 Topic A\n4:00 Topic B\n9:00 Topic C'), [
        'Topic A',
        'Topic B',
        'Topic C',
      ]);
    });

    test('decodes entities in titles', () {
      expect(_titles('0:00 Q&amp;A<br>1:00 Tom &amp; Jerry<br>2:00 End'), [
        'Q&A',
        'Tom & Jerry',
        'End',
      ]);
    });

    test('the first qualifying block when there are several', () {
      const description = '''
Chapters:
0:00 First list A
1:00 First list B
2:00 First list C

Links mentioned:
0:00 Second list A
3:00 Second list B
4:00 Second list C
''';

      expect(_titles(description), [
        'First list A',
        'First list B',
        'First list C',
      ]);
    });

    test('skips a non-qualifying block and uses a later one', () {
      const description = '''
10:00 Not a chapter list
20:00 Starts too late
Chapters
0:00 A
1:00 B
2:00 C
''';

      expect(_titles(description), ['A', 'B', 'C']);
    });
  });

  group('DescriptionChaptersParser rejects', () {
    test('a list that does not start near zero', () {
      expect(_titles('0:11 A\n1:00 B\n2:00 C'), isEmpty);
      expect(_titles('5:00 A\n10:00 B\n15:00 C'), isEmpty);
    });

    test('times that are not strictly increasing', () {
      expect(_titles('0:00 A\n5:00 B\n3:00 C'), isEmpty);
      expect(_titles('0:00 A\n5:00 B\n5:00 C'), isEmpty);
    });

    test('fewer than three entries', () {
      expect(_titles('0:00 Intro\n10:00 Outro'), isEmpty);
    });

    test('timestamps inside sentences', () {
      const description =
          'We meet at 0:00 sharp. At 12:30 we discuss news, and around '
          '45:00 we wrap up.<br>See you at 1:00:00 next week.';

      expect(_titles(description), isEmpty);
    });

    test('a start time at or after the episode duration', () {
      expect(
        _titles(
          '0:00 A\n10:00 B\n30:00 C',
          duration: const Duration(minutes: 30),
        ),
        isEmpty,
      );
    });

    test('lines without a title', () {
      expect(_titles('0:00\n1:00 -\n2:00 C'), isEmpty);
    });

    test('out-of-range fields', () {
      expect(_titles('0:00 A\n1:75 B\n2:00 C'), isEmpty);
    });

    test('an empty description', () {
      expect(_titles(''), isEmpty);
    });
  });
}
