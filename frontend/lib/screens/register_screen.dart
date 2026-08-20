import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import 'main_navigation_shell.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.register(_email.text.trim(), _password.text, _name.text.trim());
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const MainNavigationShell()), (r) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(auth.errorMessage ?? 'Registration failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Create your account', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text('Takes less than a minute.', style: TextStyle(color: Colors.grey.shade600)),
                const SizedBox(height: 28),
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 14),
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
                    helperText: 'At least 8 characters',
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) => (v == null || v.length < 8) ? 'At least 8 characters' : null,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: auth.busy ? null : _submit,
                    child: auth.busy
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Create account'),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
