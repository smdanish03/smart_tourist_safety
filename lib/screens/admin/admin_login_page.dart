import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/admin_service.dart';
import 'admin_dashboard.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() =>
      _AdminLoginPageState();
}

class _AdminLoginPageState
    extends State<AdminLoginPage> {
  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  final AdminService _adminService =
      AdminService();

  bool _loading = false;
  bool _obscurePassword = true;

  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final String email =
        _emailController.text.trim();

    final String password =
        _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage =
            'Please enter email and password.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final bool isAdmin =
          await _adminService
              .isCurrentUserAdmin();

      if (!isAdmin) {
        await FirebaseAuth.instance.signOut();

        if (!mounted) return;

        setState(() {
          _errorMessage =
              'This account does not have admin access.';
          _loading = false;
        });

        return;
      }

      if (!mounted) return;

 Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(
    builder: (_) => const AdminDashboard(),
  ),
  (route) => false,
);
    } on FirebaseAuthException catch (error) {
      String message =
          'Admin login failed.';

      if (error.code == 'invalid-credential' ||
          error.code == 'wrong-password' ||
          error.code == 'user-not-found') {
        message =
            'Invalid email or password.';
      } else if (error.code == 'invalid-email') {
        message =
            'Please enter a valid email address.';
      } else if (error.code == 'user-disabled') {
        message =
            'This account has been disabled.';
      } else if (error.code == 'too-many-requests') {
        message =
            'Too many login attempts. Please try again later.';
      }

      if (!mounted) return;

      setState(() {
        _errorMessage = message;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage =
            'Something went wrong. Please try again.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Login',
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(
                maxWidth: 450,
              ),
              child: Card(
                elevation: 3,
                child: Padding(
                  padding:
                      const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 42,
                        child: Icon(
                          Icons.admin_panel_settings,
                          size: 45,
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        'Smart Tourist Safety',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Administrator Login',
                        style: TextStyle(
                          fontSize: 16,
                          color:
                              Colors.grey.shade700,
                        ),
                      ),

                      const SizedBox(height: 28),

                      TextField(
                        controller:
                            _emailController,
                        keyboardType:
                            TextInputType.emailAddress,
                        decoration:
                            const InputDecoration(
                          labelText: 'Admin Email',
                          hintText:
                              'admin@example.com',
                          prefixIcon: Icon(
                            Icons.email_outlined,
                          ),
                          border:
                              OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextField(
                        controller:
                            _passwordController,
                        obscureText:
                            _obscurePassword,
                        decoration:
                            InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                          ),
                          suffixIcon:
                              IconButton(
                            onPressed: () {
                              setState(() {
                                _obscurePassword =
                                    !_obscurePassword;
                              });
                            },
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                          ),
                          border:
                              const OutlineInputBorder(),
                        ),
                      ),

                      if (_errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding:
                              const EdgeInsets.all(12),
                          decoration:
                              BoxDecoration(
                            color: Colors.red
                                .withValues(
                              alpha: 0.08,
                            ),
                            borderRadius:
                                BorderRadius.circular(
                              8,
                            ),
                          ),
                          child: Text(
                            _errorMessage!,
                            textAlign:
                                TextAlign.center,
                            style:
                                const TextStyle(
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed:
                              _loading ? null : _login,
                          icon: _loading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(
                                  Icons.login,
                                ),
                          label: Text(
                            _loading
                                ? 'Signing in...'
                                : 'Admin Login',
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Text(
                        'Authorized administrators only.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color:
                              Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}