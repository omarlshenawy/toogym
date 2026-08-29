import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../api/auth_api.dart';
import '../../core/responsive.dart';
import '../../core/theme.dart';

class ActivationPage extends StatefulWidget {
  const ActivationPage({super.key});

  @override
  State<ActivationPage> createState() =>
      _ActivationPageState();
}

class _ActivationPageState extends State<ActivationPage> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController =
  TextEditingController();

  bool _loading = false;
  bool _verified = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(mobile ? 20 : 40),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 460,
            ),
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(mobile ? 24 : 36),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(),

                      const SizedBox(height: 30),

                      if (!_verified)
                        _buildVerificationForm()
                      else
                        _buildPasswordForm(),

                      const SizedBox(height: 20),

                      TextButton(
                        onPressed: _loading
                            ? null
                            : () {
                          context.go('/login');
                        },
                        child: const Text(
                          'Back to Sign In',
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

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.vpn_key_outlined,
            color: Colors.white,
            size: 30,
          ),
        ),

        const SizedBox(height: 20),

        Text(
          _verified
              ? 'Create your password'
              : 'Activate your account',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          _verified
              ? 'Choose a password to secure your account.'
              : 'Enter the activation details provided by your gym.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildVerificationForm() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _usernameController,
          enabled: !_loading,
          decoration: const InputDecoration(
            labelText: 'Username',
            prefixIcon: Icon(
              Icons.person_outline,
            ),
          ),
          validator: (value) {
            if (value == null ||
                value.trim().isEmpty) {
              return 'Please enter your username';
            }

            return null;
          },
        ),

        const SizedBox(height: 16),

        TextFormField(
          controller: _codeController,
          enabled: !_loading,
          textCapitalization:
          TextCapitalization.characters,
          decoration: const InputDecoration(
            labelText: 'Activation Code',
            prefixIcon: Icon(
              Icons.key_outlined,
            ),
          ),
          validator: (value) {
            if (value == null ||
                value.trim().isEmpty) {
              return 'Please enter your activation code';
            }

            return null;
          },
        ),

        const SizedBox(height: 24),

        SizedBox(
          height: 46,
          child: _loading
              ? const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
            ),
          )
              : ElevatedButton(
            onPressed: _verify,
            child: const Text(
              'Verify Activation',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordForm() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _passwordController,
          enabled: !_loading,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: 'New Password',
            prefixIcon: const Icon(
              Icons.lock_outline,
            ),
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _obscurePassword =
                  !_obscurePassword;
                });
              },
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a password';
            }

            if (value.length < 8) {
              return 'Password must contain at least 8 characters';
            }

            return null;
          },
        ),

        const SizedBox(height: 16),

        TextFormField(
          controller: _confirmPasswordController,
          enabled: !_loading,
          obscureText: _obscureConfirmPassword,
          decoration: InputDecoration(
            labelText: 'Confirm Password',
            prefixIcon: const Icon(
              Icons.lock_outline,
            ),
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword =
                  !_obscureConfirmPassword;
                });
              },
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please confirm your password';
            }

            if (value != _passwordController.text) {
              return 'Passwords do not match';
            }

            return null;
          },
        ),

        const SizedBox(height: 24),

        SizedBox(
          height: 46,
          child: _loading
              ? const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
            ),
          )
              : ElevatedButton(
            onPressed: _setupPassword,
            child: const Text(
              'Create Password',
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _verify() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _loading = true;
    });

    try {
      await AuthApi.verifyActivation(
        username: _usernameController.text.trim(),
        activationCode: _codeController.text.trim(),
      );

      if (!mounted) return;

      setState(() {
        _verified = true;
      });
    } catch (e) {
      if (!mounted) return;

      _showError(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _setupPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _loading = true;
    });

    try {
      await AuthApi.setupPassword(
        username: _usernameController.text.trim(),
        activationCode: _codeController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Password created successfully. You can now sign in.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      context.go('/login');
    } catch (e) {
      if (!mounted) return;

      _showError(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _showError(String error) {
    final message = error.startsWith('Exception: ')
        ? error.substring(11)
        : error;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}