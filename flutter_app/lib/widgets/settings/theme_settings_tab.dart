import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ThemeSettingsTab extends StatelessWidget {
  final AppThemeId currentTheme;
  final Function(AppThemeId theme) onSelectTheme;
  final bool isLight;
  final String? userEmail;
  final String syncStatus;
  final VoidCallback? onForceSync;
  final VoidCallback? onLogout;
  final VoidCallback? onLogin;

  const ThemeSettingsTab({
    super.key,
    required this.currentTheme,
    required this.onSelectTheme,
    required this.isLight,
    this.userEmail,
    this.syncStatus = 'synced',
    this.onForceSync,
    this.onLogout,
    this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    final isGuest = userEmail == null || userEmail!.isEmpty;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        Text(
          'VISUAL INTERFACE THEMES',
          style: AppTheme.monoStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        ...AppTheme.availableThemes.map((theme) {
          final isActive = currentTheme == theme.id;
          return InkWell(
            onTap: () => onSelectTheme(theme.id),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.card,
                border: Border.all(
                  color: isActive ? theme.accent : theme.border,
                  width: isActive ? 2 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${theme.badgeEmoji} ${theme.name}',
                        style: AppTheme.monoStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: theme.accent,
                        ),
                      ),
                      if (isActive)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.bg,
                            border: Border.all(color: theme.accent),
                          ),
                          child: Text(
                            '[ Active ]',
                            style: AppTheme.monoStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: theme.accent,
                            ),
                          ),
                        )
                      else
                        Text(
                          theme.isLight ? 'Light' : 'Dark',
                          style: AppTheme.monoStyle(fontSize: 10, color: Colors.grey[500]),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    theme.description,
                    style: AppTheme.monoStyle(fontSize: 11, color: theme.text.withValues(alpha: 0.8)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text('Palette: ', style: AppTheme.monoStyle(fontSize: 10, color: Colors.grey)),
                      const SizedBox(width: 4),
                      _colorChip(theme.bg, 'Background'),
                      const SizedBox(width: 4),
                      _colorChip(theme.card, 'Surface'),
                      const SizedBox(width: 4),
                      _colorChip(theme.accent, 'Accent'),
                      const SizedBox(width: 4),
                      _colorChip(theme.text, 'Text'),
                      const SizedBox(width: 4),
                      _colorChip(theme.border, 'Border'),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isLight ? Colors.grey[100] : const Color(0xFF18181B),
            border: Border.all(color: isLight ? Colors.grey[300]! : Colors.grey[800]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SYSTEM & ACCOUNT DIAGNOSTICS',
                style: AppTheme.monoStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              _diagRow('Mode:', isGuest ? 'Local / Offline Mode' : 'Cloud Sync Mode', Colors.cyan),
              _diagRow('User Account:', isGuest ? 'Guest (No login required)' : userEmail!, Colors.green),
              _diagRow('Sync Status:', syncStatus.toUpperCase(), syncStatus == 'synced' ? Colors.green : Colors.amber),
              _diagRow('Local Storage:', 'SQLite / SharedPreferences', null),
              _diagRow('Format:', 'todo.txt utf-8', null),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  if (onForceSync != null)
                    OutlinedButton(
                      onPressed: onForceSync,
                      style: OutlinedButton.styleFrom(
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      ),
                      child: Text('[ Force Database Sync ]', style: AppTheme.monoStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  if (isGuest && onLogin != null)
                    ElevatedButton(
                      onPressed: onLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyan[800],
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      ),
                      child: Text(
                        '[ Cloud Login / Sync ]',
                        style: AppTheme.monoStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  if (!isGuest && onLogout != null)
                    OutlinedButton(
                      onPressed: onLogout,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red[400],
                        side: BorderSide(color: Colors.red[900]!),
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      ),
                      child: Text('[ Logout Session ]', style: AppTheme.monoStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.red[400])),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _diagRow(String label, String value, Color? valColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: AppTheme.monoStyle(fontSize: 11, color: Colors.grey)),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.monoStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: valColor ?? (isLight ? Colors.black87 : Colors.white70),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _colorChip(Color color, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Colors.black26),
        ),
      ),
    );
  }
}
