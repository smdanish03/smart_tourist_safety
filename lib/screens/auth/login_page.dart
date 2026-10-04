import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../admin/admin_login_page.dart';
import '../home/home_dashboard.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  final String? successMessage;

  const LoginPage({
    super.key,
    this.successMessage,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();

  final TextEditingController _touristIdController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();

    // Show success message after returning from account deletion.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final String? message = widget.successMessage;

      if (message == null || message.isEmpty) {
        return;
      }

      _showMessage(message);
    });
  }

  @override
  void dispose() {
    _touristIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOGIN
  // ============================================================

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.login(
        touristId: _touristIdController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeDashboard(),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage(
        e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
        isError: true,
      );
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // REGISTER
  // ============================================================

  void _openRegisterPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const RegisterPage(),
      ),
    );
  }

  // ============================================================
  // ADMIN LOGIN
  // ============================================================

  void _openAdminLoginPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AdminLoginPage(),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 450,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                  children: [
                    // ==================================================
                    // APP ICON
                    // ==================================================

                    const Icon(
                      Icons.security,
                      size: 80,
                      color: Colors.blue,
                    ),

                    const SizedBox(height: 18),

                    // ==================================================
                    // APP NAME
                    // ==================================================

                    const Text(
                      'Smart Tourist Safety',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Login to your tourist account',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ==================================================
                    // TOURIST ID
                    // ==================================================

                    TextFormField(
                      controller: _touristIdController,
                      textCapitalization:
                          TextCapitalization.characters,
                      maxLength: 5,
                      decoration:
                          const InputDecoration(
                        labelText: 'Tourist ID',
                        hintText: 'Example: A7K2P',
                        prefixIcon: Icon(
                          Icons.badge_outlined,
                        ),
                        border:
                            OutlineInputBorder(),
                        counterText: '',
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.length != 5) {
                          return 'Tourist ID must be exactly 5 characters.';
                        }

                        if (!RegExp(
                          r'^[A-Za-z0-9]+$',
                        ).hasMatch(value)) {
                          return 'Only letters and numbers are allowed.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    // ==================================================
                    // PASSWORD
                    // ==================================================

                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      maxLength: 6,
                      decoration:
                          InputDecoration(
                        labelText: 'Password',
                        hintText: '6 letters/numbers',
                        prefixIcon:
                            const Icon(
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
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                        ),
                        border:
                            const OutlineInputBorder(),
                        counterText: '',
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.length != 6) {
                          return 'Password must be exactly 6 characters.';
                        }

                        if (!RegExp(
                          r'^[A-Za-z0-9]+$',
                        ).hasMatch(value)) {
                          return 'Only letters and numbers are allowed.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 26),

                    // ==================================================
                    // LOGIN BUTTON
                    // ==================================================

                    SizedBox(
                      height: 52,
                      child: FilledButton(
                        onPressed:
                            _isLoading
                                ? null
                                : _login,
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color:
                                      Colors.white,
                                ),
                              )
                            : const Text(
                                'Login',
                                style:
                                    TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ==================================================
                    // CREATE ACCOUNT
                    // ==================================================

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account? ",
                        ),
                        TextButton(
                          onPressed:
                              _openRegisterPage,
                          child: const Text(
                            'Create New Account',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // ==================================================
                    // ADMIN LOGIN
                    // ==================================================

                    OutlinedButton.icon(
                      onPressed:
                          _openAdminLoginPage,
                      icon: const Icon(
                        Icons.admin_panel_settings,
                      ),
                      label: const Text(
                        'Admin Login',
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}