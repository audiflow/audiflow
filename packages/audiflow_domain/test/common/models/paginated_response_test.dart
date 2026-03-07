import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PaginatedResponse', () {
    group('construction', () {
      test('holds all fields', () {
        final response = PaginatedResponse<String>(
          data: ['a', 'b', 'c'],
          total: 10,
          page: 1,
          pageSize: 3,
        );

        expect(response.data, ['a', 'b', 'c']);
        expect(response.total, 10);
        expect(response.page, 1);
        expect(response.pageSize, 3);
      });

      test('holds empty data list', () {
        final response = PaginatedResponse<int>(
          data: [],
          total: 0,
          page: 1,
          pageSize: 10,
        );

        expect(response.data, isEmpty);
        expect(response.total, 0);
      });
    });

    group('hasMore', () {
      test('returns true when more pages exist', () {
        final response = PaginatedResponse<int>(
          data: [1, 2],
          total: 10,
          page: 1,
          pageSize: 2,
        );

        expect(response.hasMore, isTrue);
      });

      test('returns false on last page', () {
        final response = PaginatedResponse<int>(
          data: [9, 10],
          total: 10,
          page: 5,
          pageSize: 2,
        );

        expect(response.hasMore, isFalse);
      });

      test('returns false when exactly at total', () {
        final response = PaginatedResponse<int>(
          data: [1, 2, 3],
          total: 3,
          page: 1,
          pageSize: 3,
        );

        expect(response.hasMore, isFalse);
      });

      test('returns false when page exceeds total', () {
        final response = PaginatedResponse<int>(
          data: [],
          total: 5,
          page: 3,
          pageSize: 5,
        );

        // 3 * 5 = 15, which is not < 5
        expect(response.hasMore, isFalse);
      });

      test('returns true for first page of multi-page result', () {
        final response = PaginatedResponse<int>(
          data: [1, 2, 3, 4, 5],
          total: 15,
          page: 1,
          pageSize: 5,
        );

        // 1 * 5 = 5 < 15
        expect(response.hasMore, isTrue);
      });

      test('returns false for zero total', () {
        final response = PaginatedResponse<int>(
          data: [],
          total: 0,
          page: 1,
          pageSize: 10,
        );

        // 1 * 10 = 10, not < 0
        expect(response.hasMore, isFalse);
      });
    });

    group('totalPages', () {
      test('calculates exact division', () {
        final response = PaginatedResponse<int>(
          data: [1],
          total: 10,
          page: 1,
          pageSize: 5,
        );

        expect(response.totalPages, 2);
      });

      test('rounds up for partial pages', () {
        final response = PaginatedResponse<int>(
          data: [1],
          total: 11,
          page: 1,
          pageSize: 5,
        );

        expect(response.totalPages, 3);
      });

      test('returns 1 when total fits in single page', () {
        final response = PaginatedResponse<int>(
          data: [1],
          total: 3,
          page: 1,
          pageSize: 10,
        );

        expect(response.totalPages, 1);
      });

      test('returns 0 for zero total', () {
        final response = PaginatedResponse<int>(
          data: [],
          total: 0,
          page: 1,
          pageSize: 10,
        );

        expect(response.totalPages, 0);
      });

      test('returns 1 when total equals pageSize', () {
        final response = PaginatedResponse<int>(
          data: [1, 2, 3],
          total: 3,
          page: 1,
          pageSize: 3,
        );

        expect(response.totalPages, 1);
      });

      test('handles single item pages', () {
        final response = PaginatedResponse<int>(
          data: [1],
          total: 7,
          page: 1,
          pageSize: 1,
        );

        expect(response.totalPages, 7);
      });
    });

    group('generic type', () {
      test('works with custom objects', () {
        final response = PaginatedResponse<Map<String, int>>(
          data: [
            {'id': 1},
            {'id': 2},
          ],
          total: 5,
          page: 1,
          pageSize: 2,
        );

        expect(response.data.length, 2);
        expect(response.hasMore, isTrue);
      });
    });
  });
}
