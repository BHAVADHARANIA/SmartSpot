import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import 'main_navigation_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.login(_email.text.trim(), _password.text);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainNavigationShell()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(auth.errorMessage ?? 'Login failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Icon(Icons.location_on_rounded, color: AppTheme.primary, size: 48),
                const SizedBox(height: 16),
                const Text('Welcome back', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text('Log in to sync your reminders across devices.', style: TextStyle(color: Colors.grey.shade600)),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _password,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) => (v == null || v.length < 8) ? 'At least 8 characters' : null,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
                    child: const Text('Forgot password?'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: auth.busy ? null : _submit,
                    child: auth.busy
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Log in'),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RegisterScreen())),
                    child: const Text("Don't have an account? Sign up"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
