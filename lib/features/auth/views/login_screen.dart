import '../../../l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/auth_service.dart';
import '../../../main.dart' show isFirebaseInitialized;

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  int _logoTapCount = 0;
  bool _showDemoAccess = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_emailController.text.trim().isEmpty) {
      setState(() => _error = L.of(context).pleaseEnterEmail);
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final result = await AuthService().signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    if (!mounted) return;
    if (!result.success) {
      setState(() {
        _error = result.error;
        _isLoading = false;
      });
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() { _isLoading = true; _error = null; });
    final result = await AuthService().signInWithGoogle();
    if (!mounted) return;
    if (!result.success) {
      setState(() { _error = result.error; _isLoading = false; });
    }
  }

  Future<void> _signInWithApple() async {
    setState(() { _isLoading = true; _error = null; });
    final result = await AuthService().signInWithApple();
    if (!mounted) return;
    if (!result.success) {
      setState(() { _error = result.error; _isLoading = false; });
    }
  }

  Future<void> _quickLogin(String email) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    // Try sign in first; if account doesn't exist, create it
    var result = await AuthService().signIn(email: email, password: 'demo123');
    if (!result.success) {
      // Account might not exist yet — try creating it
      result = await AuthService().signUp(
        email: email,
        password: 'demo123',
        displayName: email.split('@').first,
      );
    }
    if (!mounted) return;
    if (!result.success) {
      // If both failed, show the error but also log it for debugging
      debugPrint('[Auth] Quick login failed for $email: ${result.error}');
      setState(() {
        _error = '${result.error}\n\nTip: Try using email/password sign-in with your real credentials.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              // Logo area — triple-tap for dev demo access
              Center(
                child: GestureDetector(
                  onTap: () {
                    _logoTapCount++;
                    if (_logoTapCount >= 5 && !_showDemoAccess) {
                      setState(() => _showDemoAccess = true);
                    }
                  },
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.child_care, color: Colors.white, size: 40),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  L.of(context).welcomeBack,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  L.of(context).signInToContinue,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ),
              const SizedBox(height: 32),

              // Social sign-in first — most users will use these
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _signInWithGoogle,
                  icon: const Icon(Icons.g_mobiledata, size: 24),
                  label: Text(L.of(context).continueWithGoogle),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _signInWithApple,
                  icon: const Icon(Icons.apple, size: 24),
                  label: Text(L.of(context).continueWithApple),
                ),
              ),
              const SizedBox(height: 24),

              // Divider
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(L.of(context).orSignInWithEmail,
                        style: const TextStyle(color: AppColors.textHint, fontSize: 13)),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 24),

              // Email field
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: L.of(context).email,
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 16),

              // Password field
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: L.of(context).password,
                  prefixIcon: Icon(Icons.lock_outlined),
                ),
                onSubmitted: (_) => _submit(),
              ),

              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: AppColors.error, fontSize: 13),
                  ),
                ),

              const SizedBox(height: 24),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(L.of(context).signIn),
                ),
              ),
              const SizedBox(height: 24),

              const SizedBox(height: 16),

              // Demo access — always visible for testing
              if (true) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Dev', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _DemoChip(label: 'Owner', onTap: () => _quickLogin('owner@balam.ai')),
                          _DemoChip(label: 'Parent', onTap: () => _quickLogin('parent@balam.ai')),
                          _DemoChip(label: 'Dad', onTap: () => _quickLogin('dad@balam.ai')),
                          _DemoChip(label: 'Admin', onTap: () => _quickLogin('admin@balam.ai')),
                          _DemoChip(label: 'Doctor', onTap: () => _quickLogin('doctor@balam.ai')),
                          _DemoChip(label: 'Vendor', onTap: () => _quickLogin('vendor@balam.ai')),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Toggle login/signup
              Center(
                child: TextButton(
                  onPressed: () => context.push('/signup'),
                  child: Text(L.of(context).dontHaveAccount),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DemoChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _DemoChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.divider),
        ),
        child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
