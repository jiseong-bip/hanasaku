import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hanasaku/setup/aws_s3.dart';

class CachedImage extends StatefulWidget {
  final String url;

  const CachedImage({Key? key, required this.url}) : super(key: key);

  @override
  State<CachedImage> createState() => _CachedImageState();
}

class _CachedImageState extends State<CachedImage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getImage(context, widget.url),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
          case ConnectionState.active:
            return const CircularProgressIndicator();
          case ConnectionState.done:
            if (snapshot.hasError) {
              return const Icon(Icons.error);
            } else {
              final file = snapshot.data as File;
              return Container(
                  clipBehavior: Clip.hardEdge,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(10)),
                  child: Image.file(file));
            }
        }
      },
    );
  }
}
