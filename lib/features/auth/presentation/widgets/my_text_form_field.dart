import 'package:flutter/material.dart';

class MyTextFormField extends StatefulWidget {
  final String labelText;
  final IconData prefixIcon;
  final String? validatorErrorText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final Iterable<String> autoFillHint;

  const MyTextFormField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.prefixIcon,
    required this.keyboardType,
    required this.autoFillHint,
    this.validatorErrorText,
  });

  @override
  State<MyTextFormField> createState() => _MyTextFormFieldState();
}

class _MyTextFormFieldState extends State<MyTextFormField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      autofocus: false,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return widget.validatorErrorText;
        } else {
          return null;
        }
      },
      textInputAction: TextInputAction.next,
      autofillHints: widget.autoFillHint,
      style: TextStyle(color: Colors.black, fontSize: 17),
      keyboardType: widget.keyboardType,
      obscureText: widget.prefixIcon == Icons.lock_outline,
      focusNode: FocusNode(canRequestFocus: true),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: widget.labelText,
        labelStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSecondary,
          fontSize: 14,
        ),
        floatingLabelStyle: TextStyle(
          color: Theme.of(context).colorScheme.secondary,
          fontSize: 14,
        ),
        prefixIcon: Icon(
          widget.prefixIcon,
          color: Theme.of(context).colorScheme.secondary,
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            width: 2,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ),
    );
  }
}
