import 'package:flutter/material.dart';
import '../models/template.dart';
import '../theme/app_theme.dart';
import 'settings/theme_settings_tab.dart';
import 'settings/templates_settings_tab.dart';
import 'settings/syntax_guide_tab.dart';

export 'settings/theme_settings_tab.dart';
export 'settings/templates_settings_tab.dart';
export 'settings/syntax_guide_tab.dart';
export 'settings/template_form_dialog.dart';

class SettingsModalWidget extends StatefulWidget {
  final List<Template> templates;
  final Function(String templateId) onInstantiateTemplate;
  final Function(Template template) onCreateTemplate;
  final Function(String templateId, Map<String, dynamic> updates)? onUpdateTemplate;
  final Function(String templateId) onDeleteTemplate;
  final AppThemeId currentTheme;
  final Function(AppThemeId theme) onSelectTheme;
  final bool isLight;
  final String? userEmail;
  final String syncStatus;
  final VoidCallback? onForceSync;
  final VoidCallback? onLogout;
  final VoidCallback? onLogin;
  final int initialTabIndex;
  final bool showIcons;
  final Function(bool value)? onToggleIcons;

  const SettingsModalWidget({
    super.key,
    required this.templates,
    required this.onInstantiateTemplate,
    required this.onCreateTemplate,
    this.onUpdateTemplate,
    required this.onDeleteTemplate,
    required this.currentTheme,
    required this.onSelectTheme,
    required this.isLight,
    this.userEmail,
    this.syncStatus = 'synced',
    this.onForceSync,
    this.onLogout,
    this.onLogin,
    this.initialTabIndex = 0,
    this.showIcons = false,
    this.onToggleIcons,
  });

  @override
  State<SettingsModalWidget> createState() => _SettingsModalWidgetState();
}

class _SettingsModalWidgetState extends State<SettingsModalWidget> {
  late int _activeTabIndex;

  @override
  void initState() {
    super.initState();
    _activeTabIndex = widget.initialTabIndex;
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.isLight ? Colors.white : const Color(0xFF09090B);
    final border = widget.isLight ? const Color(0xFFE4E4E7) : const Color(0xFF27272A);
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth > 600 ? 580.0 : (screenWidth * 0.94);
    final dialogHeight = MediaQuery.of(context).size.height * 0.85;

    final tabs = [
      {'title': widget.showIcons ? '🎨 [ Themes ]' : '[ Themes ]', 'icon': Icons.palette_outlined},
      {'title': widget.showIcons ? '📐 [ Templates ]' : '[ Templates ]', 'icon': Icons.auto_awesome_mosaic_outlined},
      {'title': widget.showIcons ? '📖 [ Syntax Guide ]' : '[ Syntax Guide ]', 'icon': Icons.help_outline},
    ];

    return Dialog(
      backgroundColor: bg,
      insetPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(color: border),
      ),
      child: Container(
        width: dialogWidth,
        height: dialogHeight,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header & Tab Switcher Bar
            Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(tabs.length, (idx) {
                        final isActive = _activeTabIndex == idx;
                        return InkWell(
                          onTap: () => setState(() => _activeTabIndex = idx),
                          child: Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? (widget.isLight ? Colors.grey[300] : Colors.grey[800])
                                  : Colors.transparent,
                              border: Border.all(color: isActive ? Colors.cyan : border),
                            ),
                            child: Text(
                              tabs[idx]['title'] as String,
                              style: AppTheme.monoStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isActive ? Colors.cyan : Colors.grey,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Divider(height: 1, color: border),
            const SizedBox(height: 8),

            // Tab Content
            Expanded(
              child: _activeTabIndex == 0
                  ? ThemeSettingsTab(
                      currentTheme: widget.currentTheme,
                      onSelectTheme: widget.onSelectTheme,
                      isLight: widget.isLight,
                      userEmail: widget.userEmail,
                      syncStatus: widget.syncStatus,
                      onForceSync: widget.onForceSync,
                      onLogout: widget.onLogout,
                      onLogin: widget.onLogin,
                      showIcons: widget.showIcons,
                      onToggleIcons: widget.onToggleIcons,
                    )
                  : _activeTabIndex == 1
                      ? TemplatesSettingsTab(
                          templates: widget.templates,
                          onInstantiateTemplate: widget.onInstantiateTemplate,
                          onCreateTemplate: widget.onCreateTemplate,
                          onUpdateTemplate: widget.onUpdateTemplate,
                          onDeleteTemplate: widget.onDeleteTemplate,
                          isLight: widget.isLight,
                        )
                      : SyntaxGuideTab(isLight: widget.isLight),
            ),
          ],
        ),
      ),
    );
  }
}
