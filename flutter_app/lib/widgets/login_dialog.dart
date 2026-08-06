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
  bool _isSignUp = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  Future<void> _handleAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Please enter both email/username and password');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final bool success = _isSignUp
        ? await ApiService.signup(email, password)
        : await ApiService.login(email, password);

    setState(() => _isLoading = false);

    if (success) {
      widget.onLoginSuccess();
      if (mounted) Navigator.of(context).pop();
    } else {
      setState(() => _error = _isSignUp ? 'Registration failed. Check email or password.' : 'Invalid credentials. Try again.');
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
            Text(
              _isSignUp ? 'Create SaaS Workspace Account' : 'Authenticate SaaS Workspace',
              style: GoogleFonts.jetBrainsMono(fontSize: 12, color: Colors.grey[400]),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() { _isSignUp = false; _error = null; }),
                    child: Container(
                      padding: const EdgeInsets.vertical(8),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: !_isSignUp ? Colors.cyan : Colors.transparent, width: 2)),
                      ),
                      child: Text('[ LOG IN ]', style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.bold, color: !_isSignUp ? Colors.cyan : Colors.grey)),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() { _isSignUp = true; _error = null; }),
                    child: Container(
                      padding: const EdgeInsets.vertical(8),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: _isSignUp ? Colors.cyan : Colors.transparent, width: 2)),
                      ),
                      child: Text('[ SIGN UP ]', style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.bold, color: _isSignUp ? Colors.cyan : Colors.grey)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: GoogleFonts.jetBrainsMono(fontSize: 12),
              decoration: InputDecoration(
                hintText: 'Email or username (e.g. bpx)',
                border: OutlineInputBorder(borderSide: BorderSide(color: border)),
                contentPadding: const EdgeInsets.all(10),
              ),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _passwordController,
              obscureText: true,
              style: GoogleFonts.jetBrainsMono(fontSize: 12),
              decoration: InputDecoration(
                hintText: 'Password...',
                border: OutlineInputBorder(borderSide: BorderSide(color: border)),
                contentPadding: const EdgeInsets.all(10),
              ),
              onSubmitted: (_) => _handleAuth(),
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
                onPressed: _isLoading ? null : _handleAuth,
                child: Text(
                  _isLoading ? 'Processing...' : (_isSignUp ? 'Create Account' : 'Authenticate'),
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
