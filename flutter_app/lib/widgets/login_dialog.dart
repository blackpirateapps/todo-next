import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';

class LoginDialogWidget extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  final bool isLight;

  const LoginDialogWidget({
    super.key,
    required this.onLoginSuccess,
    required this.isLight,
  });

  @override
  State<LoginDialogWidget> createState() => _LoginDialogWidgetState();
}

class _LoginDialogWidgetState extends State<LoginDialogWidget> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  Future<void> _handleLogin() async {
    final password = _passwordController.text.trim();
    if (password.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final success = await ApiService.login(password);
    setState(() => _isLoading = false);

    if (success) {
      widget.onLoginSuccess();
      if (mounted) Navigator.of(context).pop();
    } else {
      setState(() => _error = 'Incorrect password or authentication failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.isLight ? Colors.white : const Color(0xFF09090B);
    final border = widget.isLight ? const Color(0xFFE4E4E7) : const Color(0xFF27272A);

    return Dialog(
      backgroundColor: bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero, side: BorderSide(color: border)),
      child: Container(
        width: 380,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('TODO NEXT SYSTEM', style: GoogleFonts.jetBrainsMono(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.cyan)),
            const SizedBox(height: 4),
            Text('Authentication Required', style: GoogleFonts.jetBrainsMono(fontSize: 12, color: Colors.grey[400])),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),

            TextField(
              controller: _passwordController,
              obscureText: true,
              style: GoogleFonts.jetBrainsMono(fontSize: 12),
              decoration: InputDecoration(
                hintText: 'Enter system password...',
                border: OutlineInputBorder(borderSide: BorderSide(color: border)),
                contentPadding: const EdgeInsets.all(10),
              ),
              onSubmitted: (_) => _handleLogin(),
            ),

            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: GoogleFonts.jetBrainsMono(fontSize: 11, color: Colors.red[400])),
            ],

            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan[700]),
                onPressed: _isLoading ? null : _handleLogin,
                child: Text(
                  _isLoading ? 'Authenticating...' : 'Unlock System',
                  style: GoogleFonts.jetBrainsMono(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
