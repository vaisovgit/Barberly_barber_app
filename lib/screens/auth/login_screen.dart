import 'package:barber_panel/screens/main_navigation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';
import '../../providers/firebase_auth_provider.dart';
import '../../storage/localstorage_service.dart';
import '../home/home_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  // final _phoneController = PhoneController(
  //   const PhoneNumber(isoCode: IsoCode.UZ, nsn: ''),
  // );
  final _passwordController = TextEditingController();
  // bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> login(String phone, String password) async {
    try {
      await ref.read(authControllerProvider.notifier).login(phone, password);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Future<void> _loginFirebase() async {
  //
  //
  //   if (!_formKey.currentState!.validate()) return;
  //
  //   setState(() => _isLoading = true);
  //
  //
  //
  //   try {
  //     await ref
  //         .read(authServiceProvider)
  //         .signInWithEmailPassword(
  //       "998909876546@yourapp.com",
  //           "2006shukur"
  //           // _emailController.text.trim(),
  //           // _passwordController.text,
  //         );
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Login failed: ${e.toString()}')),
  //       );
  //     }
  //   } finally {
  //     if (mounted) setState(() => _isLoading = false);
  //   }
  // }

  @override
  Widget build(BuildContext context) {

    final authState = ref.watch(authControllerProvider);

    ref.listen(authControllerProvider, (prev, next) {
      next.status.whenOrNull(
        data: (userdata) async {
          print(userdata);
          final username = userdata['data']['user']['name'];
          final token = userdata['data']['token'];
          final role = userdata['data']['user']['role'];

          print("tokenimiz qaniiiiiiiiiiiiiiiii  $token");
          print("roleimiz qaniiiiiiiiiiiiiiiii  $role");
          print("usernameimiz qaniiiiiiiiiiiiiiiii  $username");
          await LocalStorage.saveToken(token);
          await LocalStorage.saveRole(role);
          await LocalStorage.saveUsername(username);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainNavigationScreen()));
        },
        error: (err, _) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(err.toString())));
        },
      );
    });

    return Scaffold(
      backgroundColor: const Color(0xFF2C3E50),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.content_cut, size: 80, color: Colors.white),
                  const SizedBox(height: 24),
                  const Text(
                    'Barber Panel',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Manage your appointments',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 48),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () {
                                setState(
                                  () => _obscurePassword = !_obscurePassword,
                                );
                              },
                            ),
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(

                            onPressed: authState.status.isLoading
                                ? null
                                : () async {
                              // _loginFirebase();
                              final phone =
                                  _emailController.text.trim();
                              final password = _passwordController.text;

                              await login(phone, password);
                            },
                              child: authState.status.isLoading
                                  ? const CircularProgressIndicator()
                              //     : const Text(
                              //   'Login',
                              //   style: TextStyle(fontWeight: FontWeight.bold),
                              // ),
                            // _isLoading ? null : _loginFirebase,
                            // child: _isLoading
                            //     ? const SizedBox(
                            //         height: 20,
                            //         width: 20,
                            //         child: CircularProgressIndicator(
                            //           strokeWidth: 2,
                            //           color: Colors.white,
                            //         ),
                            //       )
                                : const Text(
                                    'Login',
                                    style: TextStyle(fontSize: 16),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
