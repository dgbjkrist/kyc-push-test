import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Widget CustomTextField({
  bool focus = false,
  String? initialValue,
  String? labelText,
  TextInputType? inputType,
  void Function(String)? onChanged,
  bool readonly = false,
  TextEditingController? controller,
  List<TextInputFormatter>? formatters,
  Function? validator,
  Color? borderColor,
  String? hintText,
  isPassword = false,
  IconData? prefixIcon,
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
      autofocus: focus,
      inputFormatters: formatters ?? [],
      controller: controller,
      readOnly: readonly,
      initialValue: initialValue,
      onChanged: onChanged,
      obscureText: isPassword,
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
        hintText: hintText,
      ),
    ),
  );
}
