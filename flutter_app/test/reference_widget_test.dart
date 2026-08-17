import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/models/reference.dart';
import 'package:flutter_app/widgets/reference/reference_list.dart';
import 'package:flutter_app/widgets/reference/reference_item.dart';
import 'package:flutter_app/widgets/reference/reference_drawer.dart';
import 'package:flutter_app/widgets/reference/reference_editor_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const sampleRefs = [
    Reference(
      id: 'ref-1',
      title: 'John (Lead)',
      content: '+91 98765 43210\njohn@example.com\n14 Carter Road, Bandra West, Mumbai 400050',
      tags: ['@people', '+work'],
      createdAt: '2026-08-01T00:00:00Z',
      updatedAt: '2026-08-01T00:00:00Z',
      archived: false,
    ),
    Reference(
      id: 'ref-2',
      title: 'Old Server Info',
      content: '192.168.1.1',
      tags: ['+legacy'],
      createdAt: '2026-08-01T00:00:00Z',
      updatedAt: '2026-08-01T00:00:00Z',
      archived: true,
    ),
  ];

  group('Reference Widgets Tests', () {
    testWidgets('ReferenceListWidget renders list items, switches tabs, and handles selection', (WidgetTester tester) async {
      Reference? selected;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReferenceListWidget(
              references: sampleRefs,
              isLight: false,
              onSelectReference: (r) => selected = r,
              onDeleteReference: (_) {},
              onOpenNewReference: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ReferenceListWidget), findsOneWidget);
      expect(find.byType(ReferenceItemWidget), findsOneWidget);
      expect(find.text('[ REFERENCES ]'), findsOneWidget);
      expect(find.text('John (Lead)'), findsOneWidget);

      // Tap the item
      await tester.tap(find.text('John (Lead)'));
      await tester.pumpAndSettle();
      expect(selected?.id, 'ref-1');

      // Switch to Archived tab
      await tester.tap(find.text('Archived'));
      await tester.pumpAndSettle();
      expect(find.text('Old Server Info'), findsOneWidget);
    });

    testWidgets('ReferenceDrawerWidget renders header, smart actions, tags, and action buttons', (WidgetTester tester) async {
      final ref = sampleRefs.first;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReferenceDrawerWidget(
              reference: ref,
              isLight: false,
              onClose: () {},
              onEdit: (_) {},
              onArchive: (_, __) {},
              onDelete: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ReferenceDrawerWidget), findsOneWidget);
      expect(find.text('REFERENCE'), findsOneWidget);
      expect(find.text('John (Lead)'), findsOneWidget);
      expect(find.text('SMART ACTIONS DETECTED'), findsOneWidget);
      expect(find.text('Call'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Map'), findsOneWidget);
      expect(find.text('+work'), findsOneWidget);
      expect(find.text('@people'), findsOneWidget);
      expect(find.byType(OutlinedButton), findsWidgets);
    });

    testWidgets('ReferenceEditorDialog allows entering title, content, and tags', (WidgetTester tester) async {
      String? savedTitle;
      String? savedContent;
      List<String>? savedTags;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReferenceEditorDialog(
              isLight: false,
              initialTitle: 'Wi-Fi Network',
              initialContent: 'SSID: Fiber5G',
              onSave: (title, content, tags) {
                savedTitle = title;
                savedContent = content;
                savedTags = tags;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ReferenceEditorDialog), findsOneWidget);
      expect(find.text('[ NEW REFERENCE ]'), findsOneWidget);
      expect(find.text('Wi-Fi Network'), findsOneWidget);
      expect(find.text('SSID: Fiber5G'), findsOneWidget);

      // Save
      await tester.tap(find.text('Create Reference'));
      await tester.pumpAndSettle();

      expect(savedTitle, 'Wi-Fi Network');
      expect(savedContent, 'SSID: Fiber5G');
      expect(savedTags, isNotNull);
    });
  });
}
