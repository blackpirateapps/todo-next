import '../models/reference.dart';

enum SmartActionType { phone, email, url, address }

class SmartAction {
  final SmartActionType type;
  final String value;
  final String label;
  final String actionUrl;

  const SmartAction({
    required this.type,
    required this.value,
    required this.label,
    required this.actionUrl,
  });
}

class ReferenceUtils {
  /// Extract phone numbers, URLs, emails, and physical addresses from content
  static List<SmartAction> detectSmartActions(String content) {
    if (content.trim().isEmpty) return [];

    final List<SmartAction> actions = [];
    final trimmed = content.trim();

    // 1. Phone numbers
    final phoneRegex = RegExp(r'(?:\+?\d{1,3}[-.\s]?)?\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4}|\+?\d{1,3}[-.\s]?\d{4,5}[-.\s]?\d{4,6}');
    final phoneMatches = phoneRegex.allMatches(trimmed);
    for (final match in phoneMatches) {
      final phone = match.group(0)?.trim() ?? '';
      final digits = phone.replaceAll(RegExp(r'[^\d+]'), '');
      if (digits.length >= 7 && digits.length <= 15) {
        if (!actions.any((a) => a.value == phone)) {
          actions.add(SmartAction(
            type: SmartActionType.phone,
            value: phone,
            label: 'Call $phone',
            actionUrl: 'tel:${phone.replaceAll(RegExp(r'\s+'), '')}',
          ));
        }
      }
    }

    // 2. URLs
    final urlRegex = RegExp(r'(?:https?:\/\/|www\.)[^\s/$.?#].[^\s]*', caseSensitive: false);
    final urlMatches = urlRegex.allMatches(trimmed);
    for (final match in urlMatches) {
      final url = match.group(0)?.trim() ?? '';
      final href = url.startsWith('http://') || url.startsWith('https://') ? url : 'https://$url';
      if (!actions.any((a) => a.value == url)) {
        final labelUrl = url.length > 25 ? '${url.substring(0, 22)}...' : url;
        actions.add(SmartAction(
          type: SmartActionType.url,
          value: url,
          label: 'Open $labelUrl',
          actionUrl: href,
        ));
      }
    }

    // 3. Email addresses
    final emailRegex = RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}');
    final emailMatches = emailRegex.allMatches(trimmed);
    for (final match in emailMatches) {
      final email = match.group(0)?.trim() ?? '';
      if (!actions.any((a) => a.value == email)) {
        actions.add(SmartAction(
          type: SmartActionType.email,
          value: email,
          label: 'Email $email',
          actionUrl: 'mailto:$email',
        ));
      }
    }

    // 4. Physical Address Detection (conservative)
    final addressKeywords = RegExp(r'\b(Street|St\.?|Road|Rd\.?|Avenue|Ave\.?|Boulevard|Blvd\.?|Lane|Ln\.?|Drive|Dr\.?|Court|Ct\.?|Highway|Hwy\.?|Nagar|Marg|Sector|Plot|Floor|Apt|Suite|Apartment|Building)\b', caseSensitive: false);
    final lines = trimmed.split('\n');
    for (final line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.length >= 10 && addressKeywords.hasMatch(trimmedLine)) {
        if (!trimmedLine.startsWith('http') && !trimmedLine.contains('@') && !actions.any((a) => a.type == SmartActionType.address)) {
          final query = Uri.encodeComponent(trimmedLine);
          final labelAddr = trimmedLine.length > 20 ? '${trimmedLine.substring(0, 18)}...' : trimmedLine;
          actions.add(SmartAction(
            type: SmartActionType.address,
            value: trimmedLine,
            label: 'Map "$labelAddr"',
            actionUrl: 'https://www.google.com/maps/search/?api=1&query=$query',
          ));
          break;
        }
      }
    }

    return actions;
  }

  /// Format full reference for clipboard copy
  static String formatReferenceForCopy(Reference reference) {
    final parts = <String>[];
    if (reference.title.trim().isNotEmpty) {
      parts.add(reference.title.trim());
    }
    if (reference.content.trim().isNotEmpty) {
      parts.add(reference.content.trim());
    }
    if (reference.tags.isNotEmpty) {
      parts.add(reference.tags.join(' '));
    }
    return parts.join('\n');
  }

  /// Extract tags (+tag or @tag) from text
  static List<String> extractTagsFromText(String text) {
    if (text.isEmpty) return [];
    final words = text.split(RegExp(r'\s+'));
    final tags = <String>{};

    for (final word in words) {
      if ((word.startsWith('+') || word.startsWith('@')) && word.length > 1) {
        tags.add(word);
      }
    }

    return tags.toList();
  }
}
