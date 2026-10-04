import 'package:flutter/material.dart';

import '../../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() =>
      _RegisterPageState();
}

class _RegisterPageState
    extends State<RegisterPage> {
  final AuthService _authService =
      AuthService();

  final TextEditingController
      _nameController =
      TextEditingController();

  final TextEditingController
      _emailController =
      TextEditingController();

  final TextEditingController
      _phoneController =
      TextEditingController();

  final TextEditingController
      _cityController =
      TextEditingController();

  final TextEditingController
      _passwordController =
      TextEditingController();

  final TextEditingController
      _confirmPasswordController =
      TextEditingController();

  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ============================================================
  // CREATE ACCOUNT
  // ============================================================

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_passwordController.text !=
        _confirmPasswordController.text) {
      _showMessage(
        'Passwords do not match.',
        isError: true,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final String touristId =
          await _authService.createAccount(
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        city: _cityController.text,
        password:
            _passwordController.text,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      await _showTouristIdDialog(
        touristId,
      );

      if (!mounted) return;

      Navigator.pop(context);
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
  // TOURIST ID DIALOG
  // ============================================================

  Future<void> _showTouristIdDialog(
    String touristId,
  ) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
              ),
              SizedBox(width: 8),
              Text('Account Created'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Your Tourist ID has been generated.',
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius:
                      BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        Colors.blue.shade200,
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'YOUR TOURIST ID',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 8),

                    SelectableText(
                      touristId,
                      style:
                          const TextStyle(
                        fontSize: 30,
                        fontWeight:
                            FontWeight.bold,
                        letterSpacing: 4,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Please save this ID. You will use it to log in.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child:
                  const Text('Continue'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError
                ? Colors.red
                : Colors.green,
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Create New Account'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(
                maxWidth: 500,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.person_add,
                      size: 70,
                      color: Colors.blue,
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      'Create Your Tourist Account',
                      textAlign:
                          TextAlign.center,
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Your Tourist ID will be generated automatically.',
                      textAlign:
                          TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ==================================================
                    // NAME
                    // ==================================================

                    TextFormField(
                      controller:
                          _nameController,
                      textCapitalization:
                          TextCapitalization
                              .words,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Full Name',
                        hintText:
                            'Enter your name',
                        prefixIcon: Icon(
                          Icons.person_outline,
                        ),
                        border:
                            OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Please enter your name.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // ==================================================
                    // EMAIL
                    // ==================================================

                    TextFormField(
                      controller:
                          _emailController,
                      keyboardType:
                          TextInputType
                              .emailAddress,
                      decoration:
                          const InputDecoration(
                        labelText: 'Email',
                        hintText:
                            'Enter your email',
                        prefixIcon: Icon(
                          Icons.email_outlined,
                        ),
                        border:
                            OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Please enter your email.';
                        }

                        final RegExp
                            emailRegex =
                            RegExp(
                          r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                        );

                        if (!emailRegex.hasMatch(
                          value.trim(),
                        )) {
                          return 'Enter a valid email address.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // ==================================================
                    // PHONE
                    // ==================================================

                    TextFormField(
                      controller:
                          _phoneController,
                      keyboardType:
                          TextInputType.phone,
                      maxLength: 15,
                      decoration:
                          const InputDecoration(
                        labelText: 'Phone',
                        hintText:
                            'Enter your phone number',
                        prefixIcon: Icon(
                          Icons.phone_outlined,
                        ),
                        border:
                            OutlineInputBorder(),
                        counterText: '',
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Please enter your phone number.';
                        }

                        final String phone =
                            value.trim();

                        if (!RegExp(
                          r'^[0-9+\-\s]+$',
                        ).hasMatch(phone)) {
                          return 'Enter a valid phone number.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // ==================================================
                    // CITY
                    // ==================================================

                    TextFormField(
                      controller:
                          _cityController,
                      textCapitalization:
                          TextCapitalization
                              .words,
                      decoration:
                          const InputDecoration(
                        labelText: 'City',
                        hintText:
                            'Enter your city',
                        prefixIcon: Icon(
                          Icons.location_city_outlined,
                        ),
                        border:
                            OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Please enter your city.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // ==================================================
                    // PASSWORD
                    // ==================================================

                    TextFormField(
                      controller:
                          _passwordController,
                      obscureText:
                          _obscurePassword,
                      maxLength: 6,
                      decoration:
                          InputDecoration(
                        labelText:
                            'Password',
                        hintText:
                            '6 letters/numbers',
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

                    const SizedBox(height: 16),

                    // ==================================================
                    // CONFIRM PASSWORD
                    // ==================================================

                    TextFormField(
                      controller:
                          _confirmPasswordController,
                      obscureText:
                          _obscureConfirmPassword,
                      maxLength: 6,
                      decoration:
                          InputDecoration(
                        labelText:
                            'Confirm Password',
                        hintText:
                            'Enter password again',
                        prefixIcon:
                            const Icon(
                          Icons.lock_outline,
                        ),
                        suffixIcon:
                            IconButton(
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                          icon: Icon(
                            _obscureConfirmPassword
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

                    const SizedBox(height: 24),

                    // ==================================================
                    // CREATE BUTTON
                    // ==================================================

                    SizedBox(
                      height: 52,
                      child: FilledButton(
                        onPressed:
                            _isLoading
                                ? null
                                : _createAccount,
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
                                'Create Account',
                                style:
                                    TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
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