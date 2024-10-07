import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vesatogo_app/provider/auth_provider.dart';
import 'package:vesatogo_app/utils/utils.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up', style: appBarStyleText),
        centerTitle: true,
        backgroundColor: appBarColor,
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 150.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15.0),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20.0),
            InkWell(
              onTap: _isLoading ? null : () async {
                if (_isLoading) return; // Prevent multiple taps

                String email = _emailController.text.trim();
                String password = _passwordController.text.trim();

                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid email.')),
                  );
                  return;
                }
                if (password.length < 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password must be at least 6 characters.')),
                  );
                  return;
                }

                setState(() {
                  _isLoading = true;
                });

                try {
                  await ref.read(authProvider.notifier).signUp(email, password);
                  _emailController.clear();
                  _passwordController.clear();
                  // Navigate to homepage or show success message
                  context.go('/homepage');
                } on FirebaseAuthException catch (e) {
                  switch (e.code) {
                    case 'email-already-in-use':
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Email already in use.')),
                      );
                      break;
                    default:
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${e.message}')),
                      );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('An unexpected error occurred.')),
                  );
                } finally {
                  setState(() {
                    _isLoading = false; // Reset loading state
                  });
                }
              },
              child: Container(
                height: 40,
                width: 120,
                decoration: containerButton,
                child: Center(
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Sign Up', style: buttonText),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Already have an account?"),
                TextButton(
                  onPressed: () {
                    context.go('/'); // Navigate back to login
                  },
                  child: const Text("Login"),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
