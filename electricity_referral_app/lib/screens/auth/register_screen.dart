import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth_provider.dart';
import '../../language_provider.dart';

class RegisterScreen extends StatefulWidget {
  /// Optional referral code pre-filled from a deep link (?ref=CODE).
  final String? initialReferralCode;

  const RegisterScreen({super.key, this.initialReferralCode});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late final TextEditingController _referralController;

  @override
  void initState() {
    super.initState();
    // Pre-fill from passed-in code (deep link) or read directly from URL on web.
    String preFilledCode = widget.initialReferralCode ?? '';
    if (preFilledCode.isEmpty && kIsWeb) {
      preFilledCode = _readRefFromUrl();
    }
    _referralController = TextEditingController(text: preFilledCode);
  }

  /// On web, extract the `ref` query parameter from the current URL.
  String _readRefFromUrl() {
    try {
      // dart:html is only available on web, so we import it lazily via Uri.
      final uri = Uri.base;
      return uri.queryParameters['ref'] ?? '';
    } catch (_) {
      return '';
    }
  }

  Future<void> _register() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final String? referralCode = _referralController.text.trim().isNotEmpty
        ? _referralController.text.trim()
        : null;

    String? error = await authProvider.register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      displayName: _nameController.text.trim(),
      referralCodeInput: referralCode,
    );

    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _signUpWithGoogle() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final String? referralCode = _referralController.text.trim().isNotEmpty
        ? _referralController.text.trim()
        : null;

    String? error = await authProvider.signInWithGoogle(
      referralCode: referralCode,
    );

    if (!context.mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } else {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _referralController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(lang.translate('register')),
        backgroundColor: Colors.transparent,
        actions: [
          TextButton(
            onPressed: () {
              lang.setLanguage(
                lang.currentLanguage == AppLanguage.de
                    ? AppLanguage.en
                    : AppLanguage.de,
              );
            },
            child: Text(
              lang.currentLanguage == AppLanguage.de ? 'EN' : 'DE',
              style: TextStyle(
                color: theme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${lang.translate('sign_up')} WattWise',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                lang.translate('slogan'),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.secondary.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 32),
              // Full Name
              TextField(
                controller: _nameController,
                style: theme.textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: lang.translate('full_name'),
                  prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                ),
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              // Email
              TextField(
                controller: _emailController,
                style: theme.textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: lang.translate('email_hint'),
                  prefixIcon: const Icon(Icons.alternate_email_rounded, size: 20),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              // Password
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: theme.textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: lang.translate('password_hint'),
                  prefixIcon: const Icon(Icons.lock_open_rounded, size: 20),
                ),
              ),
              const SizedBox(height: 16),
              // Referral Code — auto-filled from URL if present
              TextField(
                controller: _referralController,
                style: theme.textTheme.bodyLarge,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: '${lang.translate('invitations')} ID (Optional)',
                  prefixIcon: const Icon(Icons.card_giftcard_rounded, size: 20),
                  helperText: _referralController.text.isNotEmpty
                      ? '🎁 Referral code applied — your friend earns €10!'
                      : null,
                  helperStyle: TextStyle(color: Colors.green.shade600),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _register,
                style: ElevatedButton.styleFrom(
                  elevation: 8,
                  shadowColor: theme.primaryColor.withValues(alpha: 0.3),
                ),
                child: Text(lang.translate('register')),
              ),
              const SizedBox(height: 16),
              // OR Divider
              Row(
                children: [
                  Expanded(
                    child: Divider(color: theme.dividerColor.withValues(alpha: 0.5)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      lang.translate('or'),
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                    ),
                  ),
                  Expanded(
                    child: Divider(color: theme.dividerColor.withValues(alpha: 0.5)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _signUpWithGoogle,
                icon: Image.network(
                  'https://upload.wikimedia.org/wikipedia/commons/c/c1/Google_%22G%22_logo.svg',
                  height: 24,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.login_rounded),
                ),
                label: Text('${lang.translate('sign_up')} with Google'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    lang.translate('has_account'),
                    style: theme.textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      lang.translate('login'),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
