import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CachedImage extends StatefulWidget {
  final String url;

  const CachedImage({Key? key, required this.url}) : super(key: key);

  @override
  _CachedImageState createState() => _CachedImageState();
}

class _CachedImageState extends State<CachedImage> {
  late Future<File> _cachedFile;

  @override
  void initState() {
    super.initState();
    _cachedFile = DefaultCacheManager().getSingleFile(widget.url);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _cachedFile,
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
              return Image.file(file);
            }
        }
      },
    );
  }
}
