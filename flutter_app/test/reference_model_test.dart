import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/models/reference.dart';

void main() {
  group('Reference Model Tests', () {
    test('fromJson and toJson roundtrip', () {
      final json = {
        'id': 'ref-100',
        'userId': 'user-abc',
        'title': 'John Lead',
        'content': '+91 98765 43210\njohn@example.com',
        'tags': ['@people', '+backend'],
        'createdAt': '2026-08-10T12:00:00Z',
        'updatedAt': '2026-08-10T14:00:00Z',
        'archived': false,
      };

      final ref = Reference.fromJson(json);
      expect(ref.id, 'ref-100');
      expect(ref.userId, 'user-abc');
      expect(ref.title, 'John Lead');
      expect(ref.content, '+91 98765 43210\njohn@example.com');
      expect(ref.tags, ['@people', '+backend']);
      expect(ref.createdAt, '2026-08-10T12:00:00Z');
      expect(ref.updatedAt, '2026-08-10T14:00:00Z');
      expect(ref.archived, false);

      final encoded = ref.toJson();
      expect(encoded['id'], 'ref-100');
      expect(encoded['title'], 'John Lead');
      expect(encoded['tags'], ['@people', '+backend']);
      expect(encoded['archived'], false);
    });

    test('fromJson handles legacy snake_case and missing fields', () {
      final json = {
        'id': 'ref-200',
        'user_id': 'user-xyz',
        'title': 'Wi-Fi credentials',
        'content': 'SSID: Fiber5G',
        'created_at': '2026-08-01T00:00:00Z',
        'updated_at': '2026-08-02T00:00:00Z',
        'archived': 1,
      };

      final ref = Reference.fromJson(json);
      expect(ref.id, 'ref-200');
      expect(ref.userId, 'user-xyz');
      expect(ref.title, 'Wi-Fi credentials');
      expect(ref.tags, isEmpty);
      expect(ref.archived, true);
    });

    test('copyWith works correctly', () {
      const ref = Reference(
        id: 'ref-1',
        title: 'Original Title',
        content: 'Original Content',
        tags: ['@tag1'],
        createdAt: '2026-08-01T00:00:00Z',
        updatedAt: '2026-08-01T00:00:00Z',
        archived: false,
      );

      final updated = ref.copyWith(
        title: 'New Title',
        archived: true,
        tags: ['@tag1', '+work'],
      );

      expect(updated.id, 'ref-1');
      expect(updated.title, 'New Title');
      expect(updated.content, 'Original Content');
      expect(updated.archived, true);
      expect(updated.tags, ['@tag1', '+work']);
    });
  });
}
