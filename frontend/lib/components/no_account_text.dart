import 'package:flutter/material.dart';

import '../../../constants.dart';

class NoAccountText extends StatelessWidget {
  final bool isSignUp;
  
  const NoAccountText({
    super.key,
    required this.isSignUp,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          isSignUp ? "Already have an account? " : "Don't have an account? ",
          style: const TextStyle(color: Colors.grey),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              isSignUp ? "/sign_in" : "/sign_up",
            );
          },
          child: Text(
            isSignUp ? "Login" : "Sign Up",
            style: TextStyle(
              fontSize: 16,
              color: kPrimaryColor,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
              decorationColor: kPrimaryColor.withOpacity(0.3),
              decorationThickness: 2,
            ),
          ),
        ),
      ],
    );
  }
}