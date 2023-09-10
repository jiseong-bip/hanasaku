import 'package:flutter/material.dart';
import 'package:hanasaku/auth/repos/authentication_repository.dart';

class TokenDisplayWidget extends StatefulWidget {
  const TokenDisplayWidget({super.key});

  @override
  State<TokenDisplayWidget> createState() => _TokenDisplayWidgetState();
}

class _TokenDisplayWidgetState extends State<TokenDisplayWidget> {
  String? _token;

  @override
  void initState() {
    super.initState();
    _fetchUid();
  }

  _fetchUid() async {
    final authRepo = AuthenticationRepository();
    final token = await authRepo.getUserUid();
    setState(() {
      _token = token;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('User Token: $_token'),
    );
  }
}
