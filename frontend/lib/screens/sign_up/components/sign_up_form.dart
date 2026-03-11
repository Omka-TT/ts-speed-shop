import 'package:flutter/material.dart';

import '../../../components/custom_surfix_icon.dart';
import '../../../components/form_error.dart';
import '../../../services/register_service.dart';
import '../../login_success/login_success_screen.dart';



class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {

  final _formKey = GlobalKey<FormState>();

  String? username;
  String? email;
  String? password;
  String? confirmPassword;

  final List<String?> errors = [];

  @override
  Widget build(BuildContext context) {

    return Form(
      key: _formKey,
      child: Column(
        children: [

          /// USERNAME
          TextFormField(
            onSaved: (newValue) => username = newValue,
            decoration: const InputDecoration(
              labelText: "Username",
              hintText: "Enter username",
              floatingLabelBehavior: FloatingLabelBehavior.always,
            ),
          ),

          const SizedBox(height: 20),

          /// EMAIL
          TextFormField(
            keyboardType: TextInputType.emailAddress,
            onSaved: (newValue) => email = newValue,
            decoration: const InputDecoration(
              labelText: "Email",
              hintText: "Enter email",
              floatingLabelBehavior: FloatingLabelBehavior.always,
              suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Mail.svg"),
            ),
          ),

          const SizedBox(height: 20),

          /// PASSWORD
          TextFormField(
            obscureText: true,
            onSaved: (newValue) => password = newValue,
            decoration: const InputDecoration(
              labelText: "Password",
              hintText: "Enter password",
              floatingLabelBehavior: FloatingLabelBehavior.always,
              suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Lock.svg"),
            ),
          ),

          const SizedBox(height: 20),

          /// CONFIRM PASSWORD
          TextFormField(
            obscureText: true,
            onSaved: (newValue) => confirmPassword = newValue,
            decoration: const InputDecoration(
              labelText: "Confirm Password",
              hintText: "Re-enter password",
              floatingLabelBehavior: FloatingLabelBehavior.always,
              suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Lock.svg"),
            ),
          ),

          FormError(errors: errors),

          const SizedBox(height: 20),

          ElevatedButton(
            child: const Text("Register"),

            onPressed: () async {

              if (_formKey.currentState!.validate()) {

                _formKey.currentState!.save();

                RegisterService register = RegisterService();

                bool success = await register.register(
                  username!,
                  email!,
                  password!,
                );

                if(success){

                  Navigator.pushNamed(
                    context,
                    LoginSuccessScreen.routeName,
                  );

                }else{

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Registration failed"),
                    ),
                  );

                }

              }

            },

          ),

        ],
      ),
    );
  }
}