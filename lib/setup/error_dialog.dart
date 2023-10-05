import 'package:flutter/material.dart';
import 'package:hanasaku/main.dart';

void showErrorDialog(String errorMessage) {
  showDialog(
    context: MyApp.navigatorKey.currentState!.context,
    builder: (context) => AlertDialog(
      title: const Text('すいません.'),
      content: Text(errorMessage),
      actions: <Widget>[
        TextButton(
          child: const Text('OK'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    ),
  );
}
