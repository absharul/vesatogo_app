import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vesatogo_app/provider/auth_provider.dart';
import 'package:vesatogo_app/utils/utils.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login', style: appBarStyleText),
        centerTitle: true,
        backgroundColor: appBarColor,
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 150.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15.0),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                obscureText: _obscurePassword,
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'Password must be at least 6 characters.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              InkWell(
                onTap: _isLoading ? null : _login,
                child: Container(
                  height: 40,
                  width: 120,
                  decoration: containerButton,
                  child: Center(
                    child: _isLoading
                        ? const SizedBox(
                      width: 25.0, // Set the desired width
                      height: 25.0, // Set the desired height
                      child: CircularProgressIndicator(color: Colors.white,),
                    )
                        : const Text('Login', style: buttonText),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? "),
                  TextButton(
                    onPressed: () {
                      context.go('/signup'); // Navigate to Sign Up page
                    },
                    child: const Text("Sign Up"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(authProvider.notifier).signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      _emailController.clear();
      _passwordController.clear();
      context.go('/homepage'); // Navigate to homepage
    } on FirebaseAuthException catch (e) {
      _handleAuthException(e);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An unexpected error occurred.')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Reset loading state
      });
    }
  }

  void _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No user found. Please sign up.')),
        );
        break;
      case 'wrong-password':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Incorrect password. Try again.')),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.message}')),
        );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
