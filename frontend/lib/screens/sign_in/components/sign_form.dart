import 'package:flutter/material.dart';

import '../../../constants.dart';
import '../../../helper/keyboard.dart';
import '../../login_success/login_success_screen.dart';
import '../../../services/auth_service.dart';

class SignForm extends StatefulWidget {
  const SignForm({super.key});

  @override
  _SignFormState createState() => _SignFormState();
}

class _SignFormState extends State<SignForm>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  String? _usernameError;
  String? _emailError;
  String? _passwordError;

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
    _usernameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
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

    if (!isValid) {
      setState(() {});
    }

    return isValid;
  }

  Future<void> _handleLogin() async {
    if (!_validateForm()) return;

    KeyboardUtil.hideKeyboard(context);
    setState(() => _isLoading = true);

    try {
      final result = await AuthService.instance.login(
        _usernameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result['success'] == true) {
        _showSuccessDialog();
        return;
      }

      final message = result['message']?.toString() ?? 'Login failed';
      final fieldError = result['fieldError']?.toString();
      final statusCode = result['statusCode'] as int?;

      if (statusCode == 404 ||
          message.toLowerCase().contains('not registered') ||
          fieldError == 'user_not_found') {
        _usernameError = 'User not registered';
        _emailError = 'Email not registered';

        setState(() {});

        _showSnackBar(
          'You are not registered. Please sign up first.',
          actionLabel: 'Sign Up',
          action: () => Navigator.pushNamed(context, '/sign_up'),
        );
        return;
      }

      if (fieldError == 'password' || message.toLowerCase().contains('password')) {
        _passwordError = 'Incorrect password';
      } else if (fieldError == 'username' ||
          message.toLowerCase().contains('username')) {
        _usernameError = 'Invalid username';
      } else if (fieldError == 'email' ||
          message.toLowerCase().contains('email')) {
        _emailError = 'Invalid email';
      }

      setState(() {});
      _showSnackBar(message);
    } catch (_) {
      setState(() => _isLoading = false);
      _showSnackBar('Login failed. Please try again.');
    }
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

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Welcome back!'),
        content: const Text('You have successfully logged in.'),
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
              },
            ),
          ),
          const SizedBox(height: 24),
          _animatedField(
            index: 3,
            child: _buildActionButton(
              label: 'Login',
              onPressed: _isLoading ? null : _handleLogin,
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
            obscureText: isPassword && !_isPasswordVisible,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: 'Enter $label',
              hintStyle: TextStyle(color: Colors.grey.shade500),
              prefixIcon: Icon(icon, color: kPrimaryColor),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey.shade600,
                      ),
                      onPressed: () {
                        setState(() => _isPasswordVisible = !_isPasswordVisible);
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
