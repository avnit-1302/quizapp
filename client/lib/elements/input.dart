import 'package:flutter/material.dart';

/// A text input field.
class Input extends StatelessWidget {
  final String labelText;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final void Function(String)? onReturn;
  final FocusNode? focusNode;
  final IconData? icon;
  final bool enabled;
  final String? hintText; 

  const Input({
    super.key,
    required this.labelText,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
    this.onReturn,
    this.focusNode,
    this.icon,
    this.enabled = true,
    this.hintText, 
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: theme.primaryColor,
          selectionColor: theme.primaryColor,
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        onChanged: onChanged,
        enabled: enabled,
        onSubmitted: onReturn,
        focusNode: focusNode,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText, 
          labelStyle: const TextStyle(color: Colors.black),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(6)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(6)),
            borderSide: BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
          ),
          floatingLabelStyle: const TextStyle(color: Colors.black),
          prefixIcon: icon != null ? Icon(icon) : null,
        ),
      ),
    );
  }
}

