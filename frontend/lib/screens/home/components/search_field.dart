import 'package:flutter/material.dart';

import '../../../constants.dart';

class SearchField extends StatelessWidget {
  const SearchField({
    Key? key,
    this.onChanged,
    this.controller,
    this.hintText = 'Search product',
  }) : super(key: key);

  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor: kSecondaryColor.withOpacity(0.1),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        border: searchOutlineInputBorder,
        focusedBorder: searchOutlineInputBorder,
        enabledBorder: searchOutlineInputBorder,
        hintText: hintText,
        prefixIcon: const Icon(Icons.search),
      ),
    );
  }
}

const searchOutlineInputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(12)),
  borderSide: BorderSide.none,
);
