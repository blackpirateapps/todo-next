import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/services/storage_service.dart';
import 'package:flutter_app/models/task.dart';
import 'package:flutter_app/models/template.dart';
import 'package:flutter_app/models/subtask.dart';
import 'package:flutter_app/models/comment.dart';
import 'package:flutter_app/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('AppTheme loads without error', () {
    final dark = AppTheme.darkTheme();
    final light = AppTheme.lightTheme();
    expect(dark, isNotNull);
    expect(light, isNotNull);
  });

  test('StorageService initializes and loads seed data', () async {
    final storage = StorageService();
    final tasks = await storage.loadTasks();
    final templates = await storage.loadTemplates();
    expect(tasks.isNotEmpty, true);
    expect(templates.isNotEmpty, true);
  });

  test('Defensive model deserialization handles malformed and edge-case data', () {
    final task = Task.fromJson({
      'id': 12345,
      'title': null,
      'raw': null,
      'completed': '1',
      'subtasks': '[{"id": 1, "title": "Subtask 1", "completed": true}]',
      'comments': '[{"id": "c1", "text": "Comment 1"}]',
      'projects': '+proj1',
      'contexts': '@ctx1',
    });
    expect(task.id, '12345');
    expect(task.completed, true);
    expect(task.subtasks.length, 1);
    expect(task.comments.length, 1);

    final subtask = Subtask.fromJson({'id': 99, 'completed': 1});
    expect(subtask.id, '99');
    expect(subtask.completed, true);

    final comment = Comment.fromJson({'id': 88, 'text': 'test'});
    expect(comment.id, '88');
    expect(comment.text, 'test');

    final template = Template.fromJson({
      'id': 100,
      'name': 'Test',
      'subtasks': '[{"id": 200, "title": "Tmpl Sub", "position": "3"}]'
    });
    expect(template.id, '100');
    expect(template.subtasks.length, 1);
    expect(template.subtasks.first.position, 3);
  });

  testWidgets('TodoNextApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TodoNextApp());
    expect(find.byType(TodoNextApp), findsOneWidget);
  });
}
