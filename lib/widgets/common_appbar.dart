import 'package:flutter/material.dart';

AppBar appBar({required String title, List<Widget>? actions}) => AppBar(
      centerTitle: true,
      elevation: 4,
      shadowColor: Colors.black,
      backgroundColor: Colors.white,
      foregroundColor: Colors.green,
      surfaceTintColor: Colors.transparent,
      title: Text(
        title,
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
      ),
      actions: actions,
    );
