import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FormError extends StatelessWidget {
  const FormError({
    Key? key,
    required this.errors,
  }) : super(key: key);

  final List<String?> errors;

  @override
  Widget build(BuildContext context) {
    final visibleErrors = errors.whereType<String>().toList();

    return Column(
      children:
          visibleErrors.map((error) => formErrorText(error: error)).toList(),
    );
  }

  Row formErrorText({required String error}) {
    return Row(
      children: [
        SvgPicture.asset(
          "assets/icons/Error.svg",
          height: 16,
          width: 16,
        ),
        const SizedBox(
          width: 10,
        ),
        Text(error),
      ],
    );
  }
}
