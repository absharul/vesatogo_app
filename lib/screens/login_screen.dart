// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:vesatogo_app/provider/auth_provider.dart';
// import 'package:vesatogo_app/utils/utils.dart';
//
// class LoginScreen extends ConsumerStatefulWidget {
//   const LoginScreen({super.key});
//
//   @override
//   ConsumerState<LoginScreen> createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends ConsumerState<LoginScreen> {
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _isLogin = true;
//   bool _isLoading = false;
//
//   @override
//   Widget build(BuildContext context) {
//     final user = ref.watch(authProvider);
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('VESATOGO', style: appBarStyleText,),
//         centerTitle: true,
//         backgroundColor: appBarColor,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.only(left: 20.0,right: 20.0,top: 150.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _emailController,
//               decoration: const InputDecoration(
//                   labelText: 'Email',
//                   border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 15.0,),
//             TextField(
//               controller: _passwordController,
//               decoration: const InputDecoration(
//                   labelText: 'Password',
//                   border: OutlineInputBorder(),
//               ),
//               obscureText: true,
//             ),
//             const SizedBox(height: 20.0),
//             InkWell(
//               onTap: _isLoading ? null : () async {
//                 if (_isLoading) return; // Prevent multiple taps
//
//                 String email = _emailController.text.trim();
//                 String password = _passwordController.text.trim();
//
//                 if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('Please enter a valid email.')),
//                   );
//                   return;
//                 }
//                 if (password.length < 6) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('Password must be at least 6 characters.')),
//                   );
//                   return;
//                 }
//
//                 setState(() {
//                   _isLoading = true;
//                 });
//
//                 try {
//                   if (_isLogin) {
//
//                     await ref.read(authProvider.notifier).signIn(email, password);  //sign in
//
//
//                     final user = ref.read(authProvider);   //verifying the user
//                     if (user != null) {
//                       context.go('/homepage');
//                       _emailController.clear();
//                       _passwordController.clear();
//                     }
//                   } else {
//                     await ref.read(authProvider.notifier).signUp(email, password);   //sign up
//                     _emailController.clear(); // Clear email input
//                     _passwordController.clear(); // Clear password input
//                   }
//                 } on FirebaseAuthException catch (e) {
//                   switch (e.code) {
//                     case 'user-not-found':
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text('No user found. Please sign up.')),
//                       );
//                       break;
//                     case 'wrong-password':
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text('Incorrect password. Try again.')),
//                       );
//                       break;
//                     default:
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text('Error: ${e.message}')),
//                       );
//                   }
//                 } catch (e) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('An unexpected error occurred.')),
//                   );
//                 } finally {
//                   setState(() {
//                     _isLoading = false; // Reset loading state
//                   });
//                 }
//               },
//               child: Container(
//                 height: 40,
//                 width: 120,
//                 decoration: containerButton,
//                 child: Center(
//                   child: _isLoading
//                       ? const CircularProgressIndicator()
//                       : Text(_isLogin ? 'Login' : 'Sign Up', style: buttonText),
//                 ),
//               ),
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                const Text("Don't have an account?"),
//                 TextButton(onPressed: () {
//                   setState(() {
//                     _isLogin = !_isLogin;
//                   });
//                 }, child: const Text("Sign Up"),)
//             ],),
//
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }
// }
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
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VESATOGO', style: appBarStyleText),
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
                  await ref.read(authProvider.notifier).signIn(email, password);
                  _emailController.clear();
                  _passwordController.clear();
                  context.go('/homepage'); // Navigate to homepage
                } on FirebaseAuthException catch (e) {
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
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
