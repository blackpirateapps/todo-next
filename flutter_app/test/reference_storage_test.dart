import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_app/models/reference.dart';
import 'package:flutter_app/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('StorageService Reference Persistence Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('loadReferences returns seed defaults on first launch', () async {
      final storage = StorageService();
      final refs = await storage.loadReferences();

      expect(refs.isNotEmpty, isTrue);
      expect(refs.any((r) => r.title.contains('John')), isTrue);
      expect(refs.any((r) => r.title.contains('Wi-Fi')), isTrue);
    });

    test('saveReferences persists to SharedPreferences and reloads correctly', () async {
      final storage = StorageService();
      const customRef = Reference(
        id: 'ref-custom-1',
        title: 'API Gateway Token',
        content: 'Bearer eyJhbGciOi...',
        tags: ['+infra', '@cloud'],
        createdAt: '2026-08-15T00:00:00Z',
        updatedAt: '2026-08-15T00:00:00Z',
        archived: false,
      );

      await storage.saveReferences([customRef]);
      final loaded = await storage.loadReferences();

      expect(loaded.length, 1);
      expect(loaded.first.id, 'ref-custom-1');
      expect(loaded.first.title, 'API Gateway Token');
      expect(loaded.first.tags, ['+infra', '@cloud']);
    });
  });
}
