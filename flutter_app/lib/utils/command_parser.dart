sealed class ParsedCommand {
  const ParsedCommand();
}

class OpenSettingsCommand extends ParsedCommand {
  final int tabIndex;
  const OpenSettingsCommand([this.tabIndex = 0]);
}

class ChangeThemeCommand extends ParsedCommand {
  final String themeKey;
  const ChangeThemeCommand(this.themeKey);
}

class FilterRecurringCommand extends ParsedCommand {
  const FilterRecurringCommand();
}

class SkipRecurrenceCommand extends ParsedCommand {
  const SkipRecurrenceCommand();
}

class SetRecurrenceCommand extends ParsedCommand {
  final String? rule; // null if clearing recurrence
  const SetRecurrenceCommand(this.rule);
}

class OpenTemplatesCommand extends ParsedCommand {
  const OpenTemplatesCommand();
}

class UseTemplateCommand extends ParsedCommand {
  final String templateName;
  const UseTemplateCommand(this.templateName);
}

class SaveTemplateCommand extends ParsedCommand {
  final String? templateName;
  const SaveTemplateCommand([this.templateName]);
}

class AddTaskCommand extends ParsedCommand {
  final String rawTask;
  const AddTaskCommand(this.rawTask);
}

class SetFilterCommand extends ParsedCommand {
  final String filterQuery;
  const SetFilterCommand(this.filterQuery);
}

class CommandParser {
  static ParsedCommand? parse(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;

    if (trimmed == ':settings' || trimmed == ':theme') {
      return const OpenSettingsCommand(0);
    }

    if (trimmed.startsWith(':theme ')) {
      final target = trimmed.substring(7).trim().toLowerCase();
      return ChangeThemeCommand(target);
    }

    if (trimmed == ':syntax') {
      return const OpenSettingsCommand(2);
    }

    if (trimmed == ':recurring') {
      return const FilterRecurringCommand();
    }

    if (trimmed == ':skip') {
      return const SkipRecurrenceCommand();
    }

    if (trimmed.startsWith(':rec ')) {
      final recVal = trimmed.substring(5).trim();
      if (recVal == 'off' || recVal == 'none' || recVal == 'clear') {
        return const SetRecurrenceCommand(null);
      } else {
        final cleanRec = recVal.startsWith('rec:') ? recVal.substring(4) : recVal;
        return SetRecurrenceCommand(cleanRec);
      }
    }

    if (trimmed == ':template') {
      return const OpenTemplatesCommand();
    }

    if (trimmed.startsWith(':use ')) {
      final tmplName = trimmed.substring(5).trim();
      return UseTemplateCommand(tmplName);
    }

    if (trimmed.startsWith(':template save')) {
      final name = trimmed.substring(14).trim();
      return SaveTemplateCommand(name.isNotEmpty ? name : null);
    }

    if (trimmed.startsWith(':add ')) {
      final newTaskRaw = trimmed.substring(5);
      return AddTaskCommand(newTaskRaw);
    }

    return SetFilterCommand(trimmed);
  }
}
