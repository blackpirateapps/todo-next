import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/models/reference.dart';
import 'package:flutter_app/utils/reference_utils.dart';

void main() {
  group('ReferenceUtils Smart Actions & Formatting Tests', () {
    test('detects phone numbers correctly', () {
      const text = 'Call Dr. Kumar at +91 98765 43210 or 022-26401234';
      final actions = ReferenceUtils.detectSmartActions(text);

      expect(actions.any((a) => a.type == SmartActionType.phone), isTrue);
      final phoneAction = actions.firstWhere((a) => a.type == SmartActionType.phone);
      expect(phoneAction.actionUrl.startsWith('tel:'), isTrue);
    });

    test('detects URLs correctly', () {
      const text = 'Dashboard: https://status.cloud.io/api/health or www.example.com';
      final actions = ReferenceUtils.detectSmartActions(text);

      final urls = actions.where((a) => a.type == SmartActionType.url).toList();
      expect(urls.isNotEmpty, isTrue);
      expect(urls.any((u) => u.actionUrl.contains('https://status.cloud.io')), isTrue);
    });

    test('detects Email addresses correctly', () {
      const text = 'For billing contact payments@stripe.com or support@team.io';
      final actions = ReferenceUtils.detectSmartActions(text);

      final emails = actions.where((a) => a.type == SmartActionType.email).toList();
      expect(emails.isNotEmpty, isTrue);
      expect(emails.first.actionUrl, 'mailto:payments@stripe.com');
    });

    test('detects physical address and produces map link', () {
      const text = 'Clinic Address:\n14 Carter Road, Bandra West, Mumbai 400050';
      final actions = ReferenceUtils.detectSmartActions(text);

      final maps = actions.where((a) => a.type == SmartActionType.address).toList();
      expect(maps.isNotEmpty, isTrue);
      expect(maps.first.actionUrl.contains('google.com/maps/search'), isTrue);
    });

    test('extracts tags (+project, @context) from arbitrary text', () {
      const text = 'John Doe +engineering @office contact @leads';
      final tags = ReferenceUtils.extractTagsFromText(text);

      expect(tags, contains('+engineering'));
      expect(tags, contains('@office'));
      expect(tags, contains('@leads'));
    });

    test('formatReferenceForCopy creates clean multiline text', () {
      const ref = Reference(
        id: 'ref-1',
        title: 'Server Keys',
        content: 'SSH: id_ed25519\nHost: 10.0.0.1',
        tags: ['+infra', '@ops'],
        createdAt: '2026-08-01',
        updatedAt: '2026-08-01',
      );

      final formatted = ReferenceUtils.formatReferenceForCopy(ref);
      expect(formatted, contains('Server Keys'));
      expect(formatted, contains('SSH: id_ed25519'));
      expect(formatted, contains('+infra @ops'));
    });
  });
}
