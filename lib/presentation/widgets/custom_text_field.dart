import 'package:flutter/material.dart';

Widget CustomTextField({
  String? initialValue,
  String? labelText,
  void Function(String)? onChanged,
  bool readonly = false,
  TextEditingController? controller,
  String? Function(String?)? validator,
  isPassword = false,
  IconData? prefixIcon,
  String? errorText,
}) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 10),
    margin: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          offset: Offset(0, 0),
          blurRadius: 9,
          blurStyle: BlurStyle.outer,
          spreadRadius: 2,
          color: Color.fromARGB(70, 68, 149, 249),
        ),
      ],
    ),
    child: TextFormField(
      controller: controller,
      readOnly: readonly,
      initialValue: initialValue,
      onChanged: onChanged,
      obscureText: isPassword,
      validator: validator,
      decoration: InputDecoration(
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        labelText: labelText,
        labelStyle: TextStyle(fontSize: 13),
        border: InputBorder.none,
        contentPadding: EdgeInsets.only(bottom: 0, top: 0, left: 15),
        hintStyle: TextStyle(
          color: Color(0xFFA7A9B1),
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        errorText: errorText,
        errorStyle: TextStyle(
          color: Colors.red,
          fontSize: 12,
        ),
      ),
    ),
  );
}
