import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _sent = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.forgotPassword(_email.text.trim());
    if (!mounted) return;
    if (ok) {
      setState(() => _sent = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(auth.errorMessage ?? 'Something went wrong')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Reset password')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _sent
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.mark_email_read_outlined, size: 48),
                    const SizedBox(height: 16),
                    const Text('Check your email', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text(
                      "If an account exists for ${_email.text.trim()}, we've sent a link to reset your password.",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                )
              : Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Enter your account email and we'll send you a reset link."),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(labelText: 'Email'),
                        validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: auth.busy ? null : _submit,
                          child: auth.busy
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('Send reset link'),
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
