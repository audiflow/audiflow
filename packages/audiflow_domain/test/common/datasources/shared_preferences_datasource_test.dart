import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferencesDataSource dataSource;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    dataSource = SharedPreferencesDataSource(prefs);
  });

  group('SharedPreferencesDataSource', () {
    group('getString / setString', () {
      test('returns null when key does not exist', () {
        expect(dataSource.getString('missing'), isNull);
      });

      test('stores and retrieves a string value', () async {
        await dataSource.setString('key', 'hello');
        expect(dataSource.getString('key'), 'hello');
      });

      test('overwrites existing string value', () async {
        await dataSource.setString('key', 'first');
        await dataSource.setString('key', 'second');
        expect(dataSource.getString('key'), 'second');
      });

      test('stores empty string', () async {
        await dataSource.setString('key', '');
        expect(dataSource.getString('key'), '');
      });
    });

    group('getInt / setInt', () {
      test('returns null when key does not exist', () {
        expect(dataSource.getInt('missing'), isNull);
      });

      test('stores and retrieves an int value', () async {
        await dataSource.setInt('count', 42);
        expect(dataSource.getInt('count'), 42);
      });

      test('stores zero', () async {
        await dataSource.setInt('count', 0);
        expect(dataSource.getInt('count'), 0);
      });

      test('stores negative value', () async {
        await dataSource.setInt('count', -10);
        expect(dataSource.getInt('count'), -10);
      });
    });

    group('getDouble / setDouble', () {
      test('returns null when key does not exist', () {
        expect(dataSource.getDouble('missing'), isNull);
      });

      test('stores and retrieves a double value', () async {
        await dataSource.setDouble('rate', 3.14);
        expect(dataSource.getDouble('rate'), 3.14);
      });

      test('stores zero', () async {
        await dataSource.setDouble('rate', 0.0);
        expect(dataSource.getDouble('rate'), 0.0);
      });

      test('stores negative value', () async {
        await dataSource.setDouble('rate', -1.5);
        expect(dataSource.getDouble('rate'), -1.5);
      });
    });

    group('getBool / setBool', () {
      test('returns null when key does not exist', () {
        expect(dataSource.getBool('missing'), isNull);
      });

      test('stores and retrieves true', () async {
        await dataSource.setBool('flag', true);
        expect(dataSource.getBool('flag'), isTrue);
      });

      test('stores and retrieves false', () async {
        await dataSource.setBool('flag', false);
        expect(dataSource.getBool('flag'), isFalse);
      });
    });

    group('remove', () {
      test('removes an existing key', () async {
        await dataSource.setString('key', 'value');
        expect(dataSource.getString('key'), 'value');

        await dataSource.remove('key');
        expect(dataSource.getString('key'), isNull);
      });

      test('returns true when removing a non-existent key', () async {
        final result = await dataSource.remove('nonexistent');
        expect(result, isTrue);
      });
    });

    group('clear', () {
      test('removes all stored values', () async {
        await dataSource.setString('a', 'hello');
        await dataSource.setInt('b', 42);
        await dataSource.setBool('c', true);

        await dataSource.clear();

        expect(dataSource.getString('a'), isNull);
        expect(dataSource.getInt('b'), isNull);
        expect(dataSource.getBool('c'), isNull);
      });
    });

    group('static keys', () {
      test('themeModeKey is defined', () {
        expect(SharedPreferencesDataSource.themeModeKey, 'theme_mode');
      });

      test('localeKey is defined', () {
        expect(SharedPreferencesDataSource.localeKey, 'locale');
      });
    });
  });
}
