import 'package:flutter/material.dart';

AppBar TabAppBar({
  String? titleProp,
  bool showBackButton = false,
List<Widget>? actionsProp,
Color? backgroundColor,
Color? backButtonColor,
Color? titleColor,
bool centerTitle = false,
  required BuildContext context,
FontWeight fontWeight = FontWeight.w500
}) {
  return AppBar(
    title: Padding(
      padding: EdgeInsets.only(left: showBackButton ? 0 : 14),
      child: titleProp == null ? null : Text(titleProp,
          maxLines: 3,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
      ),),
    ),
    backgroundColor: backgroundColor ?? Colors.white,
    //brightness: Brightness.light,
    elevation: 0.0,
    key: Key('app-bar'),
    actions: actionsProp,
    leading: showBackButton
        ? Row(
      children: [
        BackButton(
            color: backButtonColor ?? Colors.black.withOpacity(0.54)),
      ],
    )
        : null,
    centerTitle: centerTitle,
  );
}
