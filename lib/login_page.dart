import 'package:flutter/material.dart';

import 'storefront.dart';

const _loginGreen = Color(0xFF183A34);
const _loginMuted = Color(0xFF77736C);

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool _creatingAccount = false;
  bool _showPassword = false;
  bool _rememberMe = true;

  void _enterStore({bool asGuest = false}) {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!asGuest && !_formKey.currentState!.validate()) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const StorefrontPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
            children: [
              _brandMark(),
              const SizedBox(height: 34),
              Text(
                _creatingAccount ? 'Join V SOLES' : 'Welcome back',
                style: const TextStyle(fontSize: 29, fontWeight: FontWeight.w700, height: 1.1),
              ),
              const SizedBox(height: 8),
              Text(
                _creatingAccount
                    ? 'Create your account to keep your favorite pairs close.'
                    : 'Sign in to pick up where your next great pair begins.',
                style: const TextStyle(fontSize: 14, color: _loginMuted, height: 1.4),
              ),
              const SizedBox(height: 24),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, label: Text('Sign in')),
                  ButtonSegment(value: true, label: Text('Create account')),
                ],
                selected: {_creatingAccount},
                onSelectionChanged: (selection) => setState(() => _creatingAccount = selection.first),
                showSelectedIcon: false,
                style: SegmentedButton.styleFrom(
                  foregroundColor: _loginGreen,
                  selectedForegroundColor: Colors.white,
                  selectedBackgroundColor: _loginGreen,
                ),
              ),
              const SizedBox(height: 20),
              if (_creatingAccount) ...[
                TextFormField(
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: _fieldDecoration('Full name', Icons.person_outline),
                  validator: (value) => value == null || value.trim().isEmpty ? 'Enter your name' : null,
                ),
                const SizedBox(height: 13),
              ],
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                decoration: _fieldDecoration('Email address', Icons.mail_outline),
                validator: (value) {
                  final email = value?.trim() ?? '';
                  if (!email.contains('@') || !email.contains('.')) return 'Enter a valid email address';
                  return null;
                },
              ),
              const SizedBox(height: 13),
              TextFormField(
                obscureText: !_showPassword,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                onFieldSubmitted: (_) => _enterStore(),
                decoration: _fieldDecoration('Password', Icons.lock_outline).copyWith(
                  suffixIcon: IconButton(
                    tooltip: _showPassword ? 'Hide password' : 'Show password',
                    onPressed: () => setState(() => _showPassword = !_showPassword),
                    icon: Icon(_showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                  ),
                ),
                validator: (value) {
                  final minimumLength = _creatingAccount ? 8 : 6;
                  if (value == null || value.length < minimumLength) {
                    return 'Use at least $minimumLength characters';
                  }
                  return null;
                },
              ),
              if (!_creatingAccount)
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      Checkbox(
                        value: _rememberMe,
                        activeColor: _loginGreen,
                        onChanged: (value) => setState(() => _rememberMe = value ?? false),
                      ),
                      const Text('Remember me', style: TextStyle(fontSize: 12, color: _loginMuted)),
                    ]),
                    TextButton(
                      onPressed: _showPasswordResetMessage,
                      child: const Text('Forgot password?', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                )
              else
                const SizedBox(height: 15),
              const SizedBox(height: 8),
              SizedBox(
                height: 52,
                child: FilledButton.icon(
                  onPressed: () => _enterStore(),
                  icon: Icon(_creatingAccount ? Icons.person_add_alt_1 : Icons.login),
                  label: Text(_creatingAccount ? 'Create account' : 'Sign in'),
                  style: FilledButton.styleFrom(backgroundColor: _loginGreen, foregroundColor: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              const Row(children: [
                Expanded(child: Divider()),
                Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('OR', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _loginMuted, letterSpacing: 1))),
                Expanded(child: Divider()),
              ]),
              const SizedBox(height: 16),
              SizedBox(
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () => _enterStore(asGuest: true),
                  icon: const Icon(Icons.shopping_bag_outlined),
                  label: const Text('Continue as guest'),
                  style: OutlinedButton.styleFrom(foregroundColor: _loginGreen, side: const BorderSide(color: Color(0xFFD4D0C7))),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Demo account access is local to this app; connect an authentication service for real accounts.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, color: _loginMuted, height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _brandMark() => Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: _loginGreen, borderRadius: BorderRadius.circular(13)),
            child: const Icon(Icons.directions_run, color: Colors.white, size: 23),
          ),
          const SizedBox(width: 10),
          const Text('V SOLES', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1.1)),
        ],
      );

  InputDecoration _fieldDecoration(String label, IconData icon) => InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 19),
        filled: true,
        fillColor: const Color(0xFFF1EAE0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: const BorderSide(color: _loginGreen, width: 1.5)),
      );

  void _showPasswordResetMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password reset needs an account service connection.')),
    );
  }
}