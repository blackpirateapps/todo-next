import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/utils/command_parser.dart';

void main() {
  group('CommandParser Tests', () {
    test('parses empty or whitespace strings to null', () {
      expect(CommandParser.parse(''), isNull);
      expect(CommandParser.parse('   '), isNull);
    });

    test('parses settings and theme commands', () {
      final cmd1 = CommandParser.parse(':settings');
      expect(cmd1, isA<OpenSettingsCommand>());
      expect((cmd1 as OpenSettingsCommand).tabIndex, 0);

      final cmd2 = CommandParser.parse(':theme');
      expect(cmd2, isA<OpenSettingsCommand>());
      expect((cmd2 as OpenSettingsCommand).tabIndex, 0);

      final cmd3 = CommandParser.parse(':theme mocha');
      expect(cmd3, isA<ChangeThemeCommand>());
      expect((cmd3 as ChangeThemeCommand).themeKey, 'mocha');
    });

    test('parses syntax guide command', () {
      final cmd = CommandParser.parse(':syntax');
      expect(cmd, isA<OpenSettingsCommand>());
      expect((cmd as OpenSettingsCommand).tabIndex, 2);
    });

    test('parses recurring and skip commands', () {
      final cmd1 = CommandParser.parse(':recurring');
      expect(cmd1, isA<FilterRecurringCommand>());

      final cmd2 = CommandParser.parse(':skip');
      expect(cmd2, isA<SkipRecurrenceCommand>());
    });

    test('parses rec rules and clearing rec', () {
      final cmd1 = CommandParser.parse(':rec 1w');
      expect(cmd1, isA<SetRecurrenceCommand>());
      expect((cmd1 as SetRecurrenceCommand).rule, '1w');

      final cmd2 = CommandParser.parse(':rec rec:2w');
      expect(cmd2, isA<SetRecurrenceCommand>());
      expect((cmd2 as SetRecurrenceCommand).rule, '2w');

      final cmd3 = CommandParser.parse(':rec off');
      expect(cmd3, isA<SetRecurrenceCommand>());
      expect((cmd3 as SetRecurrenceCommand).rule, isNull);

      final cmd4 = CommandParser.parse(':rec clear');
      expect(cmd4, isA<SetRecurrenceCommand>());
      expect((cmd4 as SetRecurrenceCommand).rule, isNull);

      final cmd5 = CommandParser.parse(':rec none');
      expect(cmd5, isA<SetRecurrenceCommand>());
      expect((cmd5 as SetRecurrenceCommand).rule, isNull);
    });

    test('parses template commands', () {
      final cmd1 = CommandParser.parse(':template');
      expect(cmd1, isA<OpenTemplatesCommand>());

      final cmd2 = CommandParser.parse(':use Weekly Review');
      expect(cmd2, isA<UseTemplateCommand>());
      expect((cmd2 as UseTemplateCommand).templateName, 'Weekly Review');

      final cmd3 = CommandParser.parse(':template save Weekly Task');
      expect(cmd3, isA<SaveTemplateCommand>());
      expect((cmd3 as SaveTemplateCommand).templateName, 'Weekly Task');
    });

    test('parses add task command', () {
      final cmd = CommandParser.parse(':add (A) Fix production crash +backend @urgent');
      expect(cmd, isA<AddTaskCommand>());
      expect((cmd as AddTaskCommand).rawTask, '(A) Fix production crash +backend @urgent');
    });

    test('parses filter queries', () {
      final cmd1 = CommandParser.parse('+mobile');
      expect(cmd1, isA<SetFilterCommand>());
      expect((cmd1 as SetFilterCommand).filterQuery, '+mobile');

      final cmd2 = CommandParser.parse('@home');
      expect(cmd2, isA<SetFilterCommand>());
      expect((cmd2 as SetFilterCommand).filterQuery, '@home');

      final cmd3 = CommandParser.parse('fix bug');
      expect(cmd3, isA<SetFilterCommand>());
      expect((cmd3 as SetFilterCommand).filterQuery, 'fix bug');
    });
  });
}
