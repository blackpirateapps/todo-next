import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CommandInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSubmit;
  final VoidCallback onToggleSidebar;
  final VoidCallback onOpenTemplates;
  final Function(int initialTab) onOpenSettings;
  final Function(String view) onChangeView;
  final String activeView;
  final bool isLight;

  const CommandInputWidget({
    super.key,
    required this.controller,
    required this.onSubmit,
    required this.onToggleSidebar,
    required this.onOpenTemplates,
    required this.onOpenSettings,
    required this.onChangeView,
    required this.activeView,
    required this.isLight,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isLight ? const Color(0xFFF4F4F5) : const Color(0xFF09090B);
    final border = isLight ? const Color(0xFFE4E4E7) : const Color(0xFF27272A);
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 600;

    Widget navButtons = Wrap(
      spacing: 6,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        InkWell(
          onTap: () => onChangeView('list'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: activeView == 'list'
                  ? (isLight ? Colors.grey[300] : Colors.grey[800])
                  : Colors.transparent,
              border: Border.all(color: border),
            ),
            child: Text('[List]', style: AppTheme.monoStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ),
        InkWell(
          onTap: () => onChangeView('calendar'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: activeView == 'calendar'
                  ? (isLight ? Colors.grey[300] : Colors.grey[800])
                  : Colors.transparent,
              border: Border.all(color: border),
            ),
            child: Text('[Calendar]', style: AppTheme.monoStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ),
        InkWell(
          onTap: () => onChangeView('references'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: activeView == 'references'
                  ? (isLight ? Colors.cyan[100] : Colors.cyan[950])
                  : Colors.transparent,
              border: Border.all(color: border),
            ),
            child: Text('[Refs]', style: AppTheme.monoStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.cyan)),
          ),
        ),
        InkWell(
          onTap: onOpenTemplates,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(border: Border.all(color: border)),
            child: Text('[Templates]', style: AppTheme.monoStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.cyan)),
          ),
        ),
        InkWell(
          onTap: () => onOpenSettings(0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(border: Border.all(color: border)),
            child: Text('[⚙️ Settings]', style: AppTheme.monoStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.purple[300])),
          ),
        ),
      ],
    );

    Widget searchField = Row(
      children: [
        Text('>', style: AppTheme.monoStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green)),
        const SizedBox(width: 6),
        Expanded(
          child: TextField(
            controller: controller,
            style: AppTheme.monoStyle(fontSize: 12),
            decoration: InputDecoration(
              hintText: 'Filter... or :add Task... or :ref John | +91 98765 or :refs',
              hintStyle: AppTheme.monoStyle(fontSize: 11, color: Colors.grey[600]),
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 6),
            ),
            onSubmitted: onSubmit,
          ),
        ),
        if (controller.text.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.clear, size: 16),
            onPressed: () {
              controller.clear();
              onSubmit('');
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
      ],
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        border: Border(bottom: BorderSide(color: border)),
      ),
      child: isCompact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.menu, size: 22),
                      onPressed: onToggleSidebar,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: navButtons)),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: border),
                    color: isLight ? Colors.white : Colors.black,
                  ),
                  child: searchField,
                ),
              ],
            )
          : Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.menu, size: 22),
                  onPressed: onToggleSidebar,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                navButtons,
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: border),
                      color: isLight ? Colors.white : Colors.black,
                    ),
                    child: searchField,
                  ),
                ),
              ],
            ),
    );
  }
}
