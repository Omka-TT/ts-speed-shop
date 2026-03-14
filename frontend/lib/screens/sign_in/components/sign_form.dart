import 'package:flutter/material.dart';

import '../../../components/custom_surfix_icon.dart';
import '../../../components/form_error.dart';
import '../../../constants.dart';
import '../../../helper/keyboard.dart';
import '../../login_success/login_success_screen.dart';
import '../../../services/auth_service.dart';

class SignForm extends StatefulWidget {
  const SignForm({super.key});

  @override
  _SignFormState createState() => _SignFormState();
}

class _SignFormState extends State<SignForm> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  
  String? username;
  String? email;
  String? password;
  
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  
  // Состояния ошибок для подсветки полей
  bool _hasUsernameError = false;
  bool _hasEmailError = false;
  bool _hasPasswordError = false;
  
  String? _usernameErrorText;
  String? _emailErrorText;
  String? _passwordErrorText;
  
  final List<String?> errors = [];
  
  late AnimationController _buttonController;
  late Animation<double> _buttonScaleAnimation;
  
  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  // Контроллеры для текста
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _buttonController.dispose();
    _usernameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _clearFieldErrors() {
    setState(() {
      _hasUsernameError = false;
      _hasEmailError = false;
      _hasPasswordError = false;
      _usernameErrorText = null;
      _emailErrorText = null;
      _passwordErrorText = null;
      errors.clear();
    });
  }

  void _setFieldErrors({String? usernameError, String? emailError, String? passwordError}) {
    setState(() {
      if (usernameError != null) {
        _hasUsernameError = true;
        _usernameErrorText = usernameError;
        if (!errors.contains(usernameError)) {
          errors.add(usernameError);
        }
      }
      if (emailError != null) {
        _hasEmailError = true;
        _emailErrorText = emailError;
        if (!errors.contains(emailError)) {
          errors.add(emailError);
        }
      }
      if (passwordError != null) {
        _hasPasswordError = true;
        _passwordErrorText = passwordError;
        if (!errors.contains(passwordError)) {
          errors.add(passwordError);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Username field
          _buildAnimatedField(
            index: 0,
            child: _buildTextField(
              hint: "Username",
              icon: Icons.person_outline,
              controller: _usernameController,
              focusNode: _usernameFocus,
              hasError: _hasUsernameError,
              errorText: _usernameErrorText,
              onSaved: (newValue) => username = newValue,
              onChanged: (value) {
                if (_hasUsernameError) {
                  setState(() {
                    _hasUsernameError = false;
                    _usernameErrorText = null;
                  });
                }
              },
            ),
          ),
          const SizedBox(height: 16),
          
          // Email field
          _buildAnimatedField(
            index: 1,
            child: _buildTextField(
              hint: "Email",
              icon: Icons.email_outlined,
              controller: _emailController,
              focusNode: _emailFocus,
              keyboardType: TextInputType.emailAddress,
              hasError: _hasEmailError,
              errorText: _emailErrorText,
              onSaved: (newValue) => email = newValue,
              onChanged: (value) {
                if (_hasEmailError) {
                  setState(() {
                    _hasEmailError = false;
                    _emailErrorText = null;
                  });
                }
              },
            ),
          ),
          const SizedBox(height: 16),
          
          // Password field
          _buildAnimatedField(
            index: 2,
            child: _buildTextField(
              hint: "Password",
              icon: Icons.lock_outline,
              controller: _passwordController,
              focusNode: _passwordFocus,
              isPassword: true,
              hasError: _hasPasswordError,
              errorText: _passwordErrorText,
              onSaved: (newValue) => password = newValue,
              onChanged: (value) {
                if (_hasPasswordError) {
                  setState(() {
                    _hasPasswordError = false;
                    _passwordErrorText = null;
                  });
                }
              },
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Error messages
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: errors.isEmpty 
                ? const SizedBox.shrink()
                : TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 300),
                    builder: (context, double value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.scale(
                          scale: 0.9 + (0.1 * value),
                          child: Container(
                            margin: const EdgeInsets.only(top: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: FormError(errors: errors),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          const SizedBox(height: 20),

          // Login button
          _buildAnimatedField(
            index: 3,
            child: GestureDetector(
              onTapDown: (_) => _buttonController.forward(),
              onTapUp: (_) => _buttonController.reverse(),
              onTapCancel: () => _buttonController.reverse(),
              child: ScaleTransition(
                scale: _buttonScaleAnimation,
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [_hasAnyError() ? Colors.grey : kPrimaryColor, 
                               _hasAnyError() ? Colors.grey.shade400 : kPrimaryColor.withOpacity(0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (_hasAnyError() ? Colors.grey : kPrimaryColor).withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _isLoading ? null : _handleLogin,
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                "Login",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward, size: 20),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _hasAnyError() {
    return _hasUsernameError || _hasEmailError || _hasPasswordError;
  }

  Widget _buildAnimatedField({required int index, required Widget child}) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOutQuad,
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(30 * (1 - value), 0),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildTextField({
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    required Function(String?) onSaved,
    Function(String)? onChanged,
    FocusNode? focusNode,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    bool hasError = false,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 4),
          child: Text(
            hint,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: hasError ? Colors.red.shade400 : Colors.grey.shade700,
            ),
          ),
        ),
        // Text field
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.grey.shade50,
            border: Border.all(
              color: Colors.transparent,
              width: 1,
            ),
          ),
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            obscureText: isPassword ? !_isPasswordVisible : false,
            onSaved: onSaved,
            onChanged: (value) {
              if (onChanged != null) {
                onChanged(value);
              }
            },
            style: TextStyle(
              color: hasError ? Colors.red.shade400 : Colors.black,
            ),
            decoration: InputDecoration(
              hintText: "Enter $hint",
              hintStyle: TextStyle(
                color: hasError ? Colors.red.shade200 : Colors.grey.shade400,
              ),
              floatingLabelBehavior: FloatingLabelBehavior.never,
              prefixIcon: Icon(
                icon, 
                color: hasError ? Colors.red.shade400 : kPrimaryColor, 
                size: 20
              ),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                        color: hasError ? Colors.red.shade400 : Colors.grey,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
        // Error text
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 4),
            child: Text(
              errorText,
              style: TextStyle(
                color: Colors.red.shade400,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      KeyboardUtil.hideKeyboard(context);
      
      // Очищаем предыдущие ошибки
      _clearFieldErrors();
      
      setState(() {
        _isLoading = true;
      });

      AuthService auth = AuthService();
      
      try {
        final result = await auth.login(
          _usernameController.text,
          _emailController.text,
          _passwordController.text,
        );

        setState(() {
          _isLoading = false;
        });

        if (result['success'] == true) {
          _showSuccessDialog();
        } else {
          // Обработка ошибок на основе ответа от сервера
          String message = result['message'] ?? 'Login failed';
          String? fieldError = result['fieldError'];
          int? statusCode = result['statusCode'];
          
          print('Login error: $message, field: $fieldError, status: $statusCode');
          
          // Проверяем статус код и сообщение для определения типа ошибки
          if (statusCode == 404 || message.toLowerCase().contains('not registered') || fieldError == 'user_not_found') {
            // Пользователь не зарегистрирован
            _setFieldErrors(
              usernameError: "User not registered",
              emailError: "Email not registered",
            );
            _showErrorSnackBar(
              "You are not registered. Please sign up first.",
              showSignUp: true,
            );
          } 
          else if (message.toLowerCase().contains('password') || fieldError == 'password') {
            // Неверный пароль
            _setFieldErrors(passwordError: "Incorrect password");
            _showErrorSnackBar("Incorrect password. Please try again.");
          }
          else if (message.toLowerCase().contains('username') || fieldError == 'username') {
            // Неверное имя пользователя
            _setFieldErrors(usernameError: "Invalid username");
            _showErrorSnackBar("Invalid username.");
          }
          else if (message.toLowerCase().contains('email') || fieldError == 'email') {
            // Неверный email
            _setFieldErrors(emailError: "Invalid email");
            _showErrorSnackBar("Invalid email address.");
          }
          else {
            // Общая ошибка
            _setFieldErrors(
              usernameError: message,
              emailError: message,
              passwordError: message,
            );
            _showErrorSnackBar(message);
          }
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        
        print('Unexpected error in login: $e');
        _setFieldErrors(
          usernameError: "Login failed",
          emailError: "Login failed",
          passwordError: "Login failed",
        );
        _showErrorSnackBar("Login failed. Please try again.");
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Welcome Back!"),
        content: const Text("You have successfully logged in."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, LoginSuccessScreen.routeName);
            },
            child: const Text("Continue"),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message, {bool showSignUp = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.red.shade400,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
        action: showSignUp
            ? SnackBarAction(
                label: "Sign Up",
                textColor: Colors.white,
                onPressed: () {
                  Navigator.pushNamed(context, "/sign_up");
                },
              )
            : null,
      ),
    );
  }
}


  