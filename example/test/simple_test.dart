/// 简单的 Flutter 测试文件
///
/// 这是一个独立的、可运行的测试文件
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('基础功能测试', () {
    test('数学运算测试', () {
      expect(1 + 1, equals(2));
      expect(2 * 3, equals(6));
      expect(10 / 2, equals(5.0));
    });

    test('字符串操作测试', () {
      const str = 'Hello Flutter';
      expect(str.length, equals(13));
      expect(str.toLowerCase(), equals('hello flutter'));
      expect(str.contains('Flutter'), isTrue);
    });

    test('列表操作测试', () {
      final list = [1, 2, 3, 4, 5];
      expect(list.length, equals(5));
      expect(list.first, equals(1));
      expect(list.last, equals(5));
      expect(list.contains(3), isTrue);
    });

    test('Map 操作测试', () {
      final map = {'name': 'Flutter', 'version': '3.0'};
      expect(map['name'], equals('Flutter'));
      expect(map.containsKey('version'), isTrue);
      expect(map.keys.length, equals(2));
    });
  });

  group('错误处理测试', () {
    test('除零错误', () {
      expect(() => 10 ~/ 0, throwsA(isA<UnsupportedError>()));
    });

    test('空列表访问', () {
      final emptyList = <int>[];
      expect(() => emptyList.first, throwsA(isA<StateError>()));
    });

    test('空 Map 访问', () {
      final emptyMap = <String, String>{};
      expect(emptyMap['nonexistent'], isNull);
    });
  });

  group('异步测试', () {
    test('Future 测试', () async {
      final result = await Future.delayed(
        const Duration(milliseconds: 100),
        () => 'async result',
      );
      expect(result, equals('async result'));
    });

    test('Stream 测试', () async {
      final stream = Stream.fromIterable([1, 2, 3, 4, 5]);
      final list = await stream.toList();
      expect(list, equals([1, 2, 3, 4, 5]));
    });

    test('Future 错误处理', () async {
      expect(
        () async => await Future.delayed(
          const Duration(milliseconds: 50),
          () => throw Exception('测试异常'),
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('类型测试', () {
    test('类型检查', () {
      final value = 'Hello';
      expect(value, isA<String>());
      expect(value.length, isA<int>());
      expect(value.isEmpty, isA<bool>());
    });

    test('null 安全测试', () {
      String? nullableString;
      expect(nullableString, isNull);
      
      nullableString = 'Not null';
      expect(nullableString, isNotNull);
      expect(nullableString, equals('Not null'));
    });
  });
}
