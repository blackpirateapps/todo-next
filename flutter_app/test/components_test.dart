import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/models/task.dart';
import 'package:flutter_app/models/template.dart';
import 'package:flutter_app/models/subtask.dart';
import 'package:flutter_app/models/comment.dart';
import 'package:flutter_app/theme/app_theme.dart';
import 'package:flutter_app/widgets/task_list.dart';
import 'package:flutter_app/widgets/calendar_view.dart';
import 'package:flutter_app/widgets/inspector_drawer.dart';
import 'package:flutter_app/widgets/settings_modal.dart';
import 'package:flutter_app/widgets/modals/add_task_dialog.dart';
import 'package:flutter_app/widgets/formatted_text.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final testTasks = [
    Task(
      id: 't-1',
      title: 'Fix server bug',
      raw: '(A) 2026-08-16 Fix server bug +backend @dev due:2026-08-16 rec:1w',
      status: 'open',
      completed: false,
      priority: 'A',
      creationDate: '2026-08-16',
      dueDate: '2026-08-16',
      recurrence: '1w',
      description: 'Check logs and restart container',
      projects: ['+backend'],
      contexts: ['@dev'],
      subtasks: [
        Subtask(id: 'st-1', taskId: 't-1', title: 'Check logs', raw: 'Check logs', completed: true),
        Subtask(id: 'st-2', taskId: 't-1', title: 'Deploy fix', raw: 'Deploy fix', completed: false),
      ],
      comments: [
        Comment(id: 'c-1', taskId: 't-1', author: 'dog', timestamp: '2026-08-16 12:00', text: 'Started investigating'),
      ],
    ),
    Task(
      id: 't-2',
      title: 'Buy groceries',
      raw: 'x 2026-08-16 Buy groceries +home @errands',
      status: 'completed',
      completed: true,
      priority: null,
      creationDate: '2026-08-15',
      completionDate: '2026-08-16',
      dueDate: null,
      recurrence: null,
      description: '',
      projects: ['+home'],
      contexts: ['@errands'],
      subtasks: [],
      comments: [],
    ),
  ];

  final testTemplates = [
    Template(
      id: 'tmpl-1',
      name: 'Weekly Planning',
      rawTemplate: '(B) Weekly planning +review @desk due:{today}',
      description: 'Review OKRs and plan next week',
      createdAt: '2026-08-01',
      updatedAt: '2026-08-01',
      projects: ['+review'],
      contexts: ['@desk'],
      subtasks: [
        TemplateSubtask(id: 'tst-1', title: 'Review completed items', position: 0),
        TemplateSubtask(id: 'tst-2', title: 'Set 3 priorities', position: 1),
      ],
    ),
  ];

  group('TaskListWidget & Components Tests', () {
    testWidgets('renders TaskListWidget with open tasks and toggles filter', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskListWidget(
              tasks: testTasks,
              selectedTaskId: 't-1',
              onSelectTask: (_) {},
              onToggleTask: (_) {},
              onDeleteTask: (_) {},
              isLight: false,
            ),
          ),
        ),
      );

      expect(find.byType(FormattedText), findsWidgets);
      expect(find.byType(TaskListToolbar), findsOneWidget);
      expect(find.byType(TaskListHeader), findsOneWidget);
      // Defaults to open tasks (1 open task)
      expect(find.byType(TaskListItem), findsOneWidget);

      // Select Status: All
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Status: All').last);
      await tester.pumpAndSettle();

      expect(find.byType(TaskListItem), findsNWidgets(2));
    });
  });

  group('CalendarViewWidget & Components Tests', () {
    testWidgets('renders CalendarViewWidget and navigates', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarViewWidget(
              tasks: testTasks,
              selectedTaskId: 't-1',
              onSelectTask: (_) {},
              onToggleTask: (_) {},
              onMoveTask: (_, __, ___) {},
              onCreateTaskAtDate: (_, __) {},
              isLight: false,
            ),
          ),
        ),
      );

      expect(find.byType(CalendarHeader), findsOneWidget);
      expect(find.byType(CalendarWeekdayHeader), findsOneWidget);
      expect(find.byType(CalendarDayCell), findsWidgets);
    });
  });

  group('InspectorDrawerWidget & Components Tests', () {
    testWidgets('renders InspectorDrawerWidget with all sections', (tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InspectorDrawerWidget(
              task: testTasks.first,
              onClose: () {},
              onUpdateTask: (_, __) {},
              onSaveAsTemplate: (_) {},
              onSkipRecurrence: (_) {},
              isLight: false,
            ),
          ),
        ),
      );

      expect(find.byType(InspectorHeader), findsOneWidget);
      expect(find.byType(InspectorTitleSection), findsOneWidget);
      expect(find.byType(InspectorMetadataSection), findsOneWidget);
      expect(find.byType(InspectorRecurrenceCard), findsOneWidget);
      expect(find.byType(InspectorTagsSection), findsOneWidget);
      expect(find.byType(InspectorDescriptionSection), findsOneWidget);
      expect(find.byType(InspectorSubtasksSection), findsOneWidget);
      expect(find.byType(InspectorCommentsSection), findsOneWidget);
      expect(find.text('INSPECTOR'), findsOneWidget);
      expect(find.text('+backend'), findsOneWidget);
      expect(find.text('@dev'), findsOneWidget);
    });
  });

  group('SettingsModalWidget & Sub-Tabs Tests', () {
    testWidgets('renders SettingsModalWidget and switches tabs', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsModalWidget(
              templates: testTemplates,
              onInstantiateTemplate: (_) {},
              onCreateTemplate: (_) {},
              onDeleteTemplate: (_) {},
              currentTheme: AppThemeId.mocha,
              onSelectTheme: (_) {},
              isLight: false,
            ),
          ),
        ),
      );

      expect(find.byType(ThemeSettingsTab), findsOneWidget);
      expect(find.text('[ Themes ]'), findsOneWidget);
      expect(find.text('[ Templates ]'), findsOneWidget);
      expect(find.text('[ Syntax Guide ]'), findsOneWidget);

      // Switch to Templates tab
      await tester.tap(find.text('[ Templates ]'));
      await tester.pumpAndSettle();
      expect(find.byType(TemplatesSettingsTab), findsOneWidget);
      expect(find.text('Weekly Planning'), findsOneWidget);

      // Switch to Syntax Guide tab
      await tester.tap(find.text('[ Syntax Guide ]'));
      await tester.pumpAndSettle();
      expect(find.byType(SyntaxGuideTab), findsOneWidget);
      expect(find.text('1. Priority'), findsOneWidget);
    });
  });

  group('AddTaskDialog Tests', () {
    testWidgets('renders AddTaskDialog and triggers submit', (tester) async {
      String submittedCommand = '';
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AddTaskDialog(
              isLight: false,
              onCommandSubmit: (cmd) {
                submittedCommand = cmd;
              },
            ),
          ),
        ),
      );

      expect(find.text('[CREATE NEW TASK]'), findsOneWidget);
      expect(find.text('(A)'), findsOneWidget);
      expect(find.text('(B)'), findsOneWidget);
      expect(find.text('due:today'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Test add task via modal');
      await tester.tap(find.text('Create Task'));
      await tester.pumpAndSettle();

      expect(submittedCommand, ':add Test add task via modal');
    });
  });
}
