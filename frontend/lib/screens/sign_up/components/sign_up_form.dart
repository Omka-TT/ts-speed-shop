import 'package:flutter/material.dart';

import '../../../constants.dart';
import '../../../helper/keyboard.dart';
import '../../login_success/login_success_screen.dart';
import '../../../services/register_service.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  String? _usernameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  late final AnimationController _staggerController;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _staggerController.forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  Animation<double> _fieldAnimation(int index) {
    final start = 0.1 * index;
    final end = (start + 0.45).clamp(0.0, 1.0);
    return CurvedAnimation(
      parent: _staggerController,
      curve: Interval(start, end, curve: Curves.easeOut),
    );
  }

  void _clearFieldErrors() {
    setState(() {
      _usernameError = null;
      _emailError = null;
      _passwordError = null;
      _confirmPasswordError = null;
    });
  }

  bool _validateForm() {
    var isValid = true;
    _clearFieldErrors();

    if (_usernameController.text.trim().isEmpty) {
      _usernameError = 'Please enter your username';
      isValid = false;
    }

    if (_emailController.text.trim().isEmpty) {
      _emailError = 'Please enter your email';
      isValid = false;
    } else if (!RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$")
        .hasMatch(_emailController.text.trim())) {
      _emailError = 'Enter a valid email address';
      isValid = false;
    }

    if (_passwordController.text.isEmpty) {
      _passwordError = 'Please enter your password';
      isValid = false;
    }

    if (_confirmPasswordController.text.isEmpty) {
      _confirmPasswordError = 'Please confirm your password';
      isValid = false;
    }

    if (!isValid) {
      setState(() {});
    }

    return isValid;
  }

  bool _validatePasswords() {
    if (_passwordController.text != _confirmPasswordController.text) {
      _passwordError = 'Passwords do not match';
      _confirmPasswordError = 'Passwords do not match';
      setState(() {});
      return false;
    }
    return true;
  }

  Future<void> _handleRegister() async {
    if (!_validateForm()) return;
    if (!_validatePasswords()) return;

    KeyboardUtil.hideKeyboard(context);
    setState(() => _isLoading = true);

    try {
      final result = await RegisterService().register(
        _usernameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );

      setState(() => _isLoading = false);

      if (result['success'] == true) {
        _showSuccessDialog();
        return;
      }

      final message = result['message']?.toString() ?? 'Registration failed';
      final fieldErrors = result['fieldErrors'] as Map<String, dynamic>?;
      final userExists = result['userExists'] == true;

      if (userExists) {
        _usernameError = fieldErrors?['username']?.toString() ??
            'Username already taken';
        _emailError =
            fieldErrors?['email']?.toString() ?? 'Email already registered';

        setState(() {});

        _showSnackBar(
          'You are already registered. Please login instead.',
          actionLabel: 'Login',
          action: () => Navigator.pushNamed(context, '/sign_in'),
        );
        return;
      }

      if (fieldErrors != null && fieldErrors.isNotEmpty) {
        _usernameError = fieldErrors['username']?.toString();
        _emailError = fieldErrors['email']?.toString();
        _passwordError = fieldErrors['password']?.toString();
      } else {
        _usernameError = message;
        _emailError = message;
        _passwordError = message;
      }

      setState(() {});
      _showSnackBar(message);
    } catch (_) {
      setState(() => _isLoading = false);
      _showSnackBar('Registration failed. Please try again.');
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Welcome!'),
        content: const Text('Your account has been created successfully.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, LoginSuccessScreen.routeName);
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(
    String message, {
    String? actionLabel,
    VoidCallback? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red.shade500,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
        action: actionLabel != null && action != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: Colors.white,
                onPressed: action,
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _animatedField(
            index: 0,
            child: _buildInput(
              label: 'Username',
              icon: Icons.person_outline,
              controller: _usernameController,
              focusNode: _usernameFocus,
              errorText: _usernameError,
              onChanged: (value) {
                if (_usernameError != null) {
                  setState(() => _usernameError = null);
                }
              },
            ),
          ),
          const SizedBox(height: 16),
          _animatedField(
            index: 1,
            child: _buildInput(
              label: 'Email',
              icon: Icons.email_outlined,
              controller: _emailController,
              focusNode: _emailFocus,
              keyboardType: TextInputType.emailAddress,
              errorText: _emailError,
              onChanged: (value) {
                if (_emailError != null) {
                  setState(() => _emailError = null);
                }
              },
            ),
          ),
          const SizedBox(height: 16),
          _animatedField(
            index: 2,
            child: _buildInput(
              label: 'Password',
              icon: Icons.lock_outline,
              controller: _passwordController,
              focusNode: _passwordFocus,
              isPassword: true,
              errorText: _passwordError,
              onChanged: (value) {
                if (_passwordError != null) {
                  setState(() => _passwordError = null);
                }
                if (_confirmPasswordError != null) {
                  setState(() => _confirmPasswordError = null);
                }
              },
            ),
          ),
          const SizedBox(height: 16),
          _animatedField(
            index: 3,
            child: _buildInput(
              label: 'Confirm Password',
              icon: Icons.lock_outline,
              controller: _confirmPasswordController,
              focusNode: _confirmPasswordFocus,
              isPassword: true,
              isConfirmPassword: true,
              errorText: _confirmPasswordError,
              onChanged: (value) {
                if (_confirmPasswordError != null) {
                  setState(() => _confirmPasswordError = null);
                }
              },
            ),
          ),
          const SizedBox(height: 24),
          _animatedField(
            index: 4,
            child: _buildActionButton(
              label: 'Register',
              onPressed: _isLoading ? null : _handleRegister,
              isLoading: _isLoading,
            ),
          ),
        ],
      ),
    );
  }

  Widget _animatedField({required int index, required Widget child}) {
    return FadeTransition(
      opacity: _fieldAnimation(index),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.18),
          end: Offset.zero,
        ).animate(_fieldAnimation(index)),
        child: child,
      ),
    );
  }

  Widget _buildInput({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required FocusNode focusNode,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    bool isConfirmPassword = false,
    String? errorText,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            obscureText: isPassword &&
                (isConfirmPassword ? !_isConfirmPasswordVisible : !_isPasswordVisible),
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: 'Enter $label',
              hintStyle: TextStyle(color: Colors.grey.shade500),
              prefixIcon: Icon(icon, color: kPrimaryColor),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        isConfirmPassword
                            ? (_isConfirmPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility)
                            : (_isPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility),
                        color: Colors.grey.shade600,
                      ),
                      onPressed: () {
                        setState(() {
                          if (isConfirmPassword) {
                            _isConfirmPasswordVisible =
                                !_isConfirmPasswordVisible;
                          } else {
                            _isPasswordVisible = !_isPasswordVisible;
                          }
                        });
                      },
                    )
                  : null,
              errorText: errorText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.transparent,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required VoidCallback? onPressed,
    required bool isLoading,
  }) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: EdgeInsets.zero,
          elevation: 8,
          shadowColor: kPrimaryColor.withOpacity(0.3),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [kPrimaryColor, kPrimaryColor.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    label,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
