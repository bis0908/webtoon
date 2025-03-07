import 'package:flutter/material.dart';

AppBar appBar({required String title, List<Widget>? actions}) {
  return AppBar(
    centerTitle: true,
    elevation: 4,
    shadowColor: Colors.black,
    surfaceTintColor: Colors.transparent,
    title: Text(
      title,
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
    ),
    actions: actions,
  );
}
