import 'package:audiflow_podcast/audiflow_podcast.dart';
import 'package:checks/checks.dart';
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

      check(chapters.map((c) => c.title)).deepEquals([
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
      check(
        chapters[1].startTime,
      ).equals(const Duration(minutes: 2, seconds: 57));
      check(
        chapters.last.startTime,
      ).equals(const Duration(minutes: 52, seconds: 41));
    });

    test('an English plain-text list with separators', () {
      const description = '''
In this episode we talk about things.

0:00 - Intro
5:12 – The main topic:
12:40: Listener questions
''';

      check(_titles(description)).deepEquals([
        'Intro',
        'The main topic',
        'Listener questions',
      ]);
      check(
        _starts(description)[1],
      ).equals(const Duration(minutes: 5, seconds: 12));
    });

    test('bullet-prefixed list items', () {
      const description =
          '<ul><li>• 00:00 Opening</li><li>• 10:00 News</li>'
          '<li>• 20:00 Closing</li></ul>';

      check(_titles(description)).deepEquals(['Opening', 'News', 'Closing']);
    });

    test('bracketed times and a paragraph per line', () {
      const description =
          '<p>[00:00] Welcome</p><p>[03:30] Guest intro</p>'
          '<p>(15:00) Deep dive</p>';

      check(
        _titles(description),
      ).deepEquals(['Welcome', 'Guest intro', 'Deep dive']);
    });

    test('Japanese brackets and wave dashes without a space', () {
      check(_titles('【00:00】オープニング<br>【05:10】本編<br>【40:00】お便り')).deepEquals([
        'オープニング',
        '本編',
        'お便り',
      ]);
      check(_titles('[00:00]Intro\n[01:00]Topic\n[02:00]Outro')).deepEquals([
        'Intro',
        'Topic',
        'Outro',
      ]);
      check(_titles('00:00〜オープニング\n03:00〜本編\n09:00〜エンディング')).deepEquals([
        'オープニング',
        '本編',
        'エンディング',
      ]);
    });

    test('entity separators such as &ndash;', () {
      check(
        _titles('0:00 &ndash; Intro<br>2:00 &mdash; Topic<br>4:00 &ndash; End'),
      ).deepEquals(['Intro', 'Topic', 'End']);
    });

    test('hour-long episodes with h:mm:ss times', () {
      const description = '''
00:00:00 Start
0:45:10 Middle
1:02:03 Late topic
1:30:00 Wrap up
''';

      check(_starts(description)).deepEquals([
        Duration.zero,
        const Duration(minutes: 45, seconds: 10),
        const Duration(hours: 1, minutes: 2, seconds: 3),
        const Duration(hours: 1, minutes: 30),
      ]);
    });

    test('a short intro before the first entry', () {
      check(_titles('0:08 Topic A\n4:00 Topic B\n9:00 Topic C')).deepEquals([
        'Topic A',
        'Topic B',
        'Topic C',
      ]);
    });

    test('decodes entities in titles', () {
      check(
        _titles('0:00 Q&amp;A<br>1:00 Tom &amp; Jerry<br>2:00 End'),
      ).deepEquals([
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

      check(_titles(description)).deepEquals([
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

      check(_titles(description)).deepEquals(['A', 'B', 'C']);
    });
  });

  group('DescriptionChaptersParser rejects', () {
    test('a list that does not start near zero', () {
      check(_titles('0:11 A\n1:00 B\n2:00 C')).isEmpty();
      check(_titles('5:00 A\n10:00 B\n15:00 C')).isEmpty();
    });

    test('times that are not strictly increasing', () {
      check(_titles('0:00 A\n5:00 B\n3:00 C')).isEmpty();
      check(_titles('0:00 A\n5:00 B\n5:00 C')).isEmpty();
    });

    test('fewer than three entries', () {
      check(_titles('0:00 Intro\n10:00 Outro')).isEmpty();
    });

    test('timestamps inside sentences', () {
      const description =
          'We meet at 0:00 sharp. At 12:30 we discuss news, and around '
          '45:00 we wrap up.<br>See you at 1:00:00 next week.';

      check(_titles(description)).isEmpty();
    });

    test('a start time at or after the episode duration', () {
      check(
        _titles(
          '0:00 A\n10:00 B\n30:00 C',
          duration: const Duration(minutes: 30),
        ),
      ).isEmpty();
    });

    test('lines without a title', () {
      check(_titles('0:00\n1:00 -\n2:00 C')).isEmpty();
    });

    test('out-of-range fields', () {
      check(_titles('0:00 A\n1:75 B\n2:00 C')).isEmpty();
    });

    test('pathological separator and bracket runs within a second', () {
      final noisy = '0:00 A${'- ' * 20000}x\n${'<' * 20000}\n1:00 B\n2:00 C';
      final watch = Stopwatch()..start();
      _parser.parse(noisy);
      check(watch.elapsed).isLessThan(const Duration(seconds: 1));
    });

    test('an empty description', () {
      check(_titles('')).isEmpty();
    });
  });

  group('IsolateRssParser description chapters', () {
    const feed = '''<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0"
  xmlns:psc="http://podlove.org/simple-chapters"
  xmlns:content="http://purl.org/rss/1.0/modules/content/">
  <channel>
    <title>Notes</title>
    <description>Notes</description>
    <item>
      <guid>notes</guid>
      <title>Notes only</title>
      <description><![CDATA[<p>0:00 A<br />1:00 B<br />2:00 C</p>]]></description>
    </item>
    <item>
      <guid>encoded</guid>
      <title>Content encoded only</title>
      <description>Short teaser</description>
      <content:encoded><![CDATA[<p>0:00 X<br />1:00 Y<br />2:00 Z</p>]]></content:encoded>
    </item>
    <item>
      <guid>psc</guid>
      <title>Feed chapters</title>
      <description><![CDATA[<p>0:00 A<br />1:00 B<br />2:00 C</p>]]></description>
      <psc:chapters version="1.2">
        <psc:chapter start="00:00:00" title="Feed"/>
      </psc:chapters>
    </item>
  </channel>
</rss>''';

    test('derives chapters only where the feed has none', () async {
      final result = await IsolateRssParser.parseFeed(feedXml: feed);
      final byGuid = {for (final e in result.episodes) e.guid: e};

      List<String> titles(String guid) =>
          byGuid[guid]!.descriptionChapters.map((c) => c.title).toList();

      check(titles('notes')).deepEquals(['A', 'B', 'C']);
      check(titles('encoded')).deepEquals(['X', 'Y', 'Z']);
      check(titles('psc')).isEmpty();
    });
  });
}
