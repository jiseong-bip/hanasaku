// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_aws_s3_client/flutter_aws_s3_client.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hanasaku/constants/sizes.dart';

const region = "ap-northeast-2";
const bucketId = "jeon-jue";

final AwsS3Client awsS3Client = AwsS3Client(
    region: region,
    host: "s3.$region.amazonaws.com",
    bucketId: bucketId,
    accessKey: dotenv.get("ACCESS_KEY"),
    secretKey: dotenv.get("SECRET_KEY"));

Future getListImage(List<Object?> images) async {
  final cacheManager = DefaultCacheManager();

  for (var image in images) {
    String? imageKey;
    if ((image as Map<String, dynamic>).containsKey('url')) {
      imageKey = (image)['url'];
    } else if ((image).containsKey('avatar')) {
      imageKey = (image)['avatar'];
    } else {
      // Handle the case where neither key is present
    }
    // Check if image data already exists

    if (await cacheManager.getFileFromCache(imageKey!) != null) {
      print('not access');
      continue; // Image data already downloaded, no need to fetch again
    }

    final response = await awsS3Client.getObject(imageKey);

    if (response.statusCode == 200) {
      await cacheManager.putFile(
        imageKey,
        response.bodyBytes,
        fileExtension: 'jpg', // Set the file extension if necessary
      );

      print('access : $imageKey');
    } else {
      // Handle the case where image download failed
      print("Image download failed: $response");
    }
  }
}

Future<File?> getImage(BuildContext context, String? imageKey) async {
  final cacheManager = DefaultCacheManager();

  if (await cacheManager.getFileFromCache(imageKey!) != null) {
    print('not access');
    return DefaultCacheManager().getSingleFile(
        imageKey); // Image data already downloaded, no need to fetch again
  }

  final response = await awsS3Client.getObject(imageKey);

  if (response.statusCode == 200) {
    await cacheManager.putFile(
      imageKey,
      response.bodyBytes,
      fileExtension: 'jpg', // Set the file extension if necessary
    );

    print('access : $imageKey');
    return DefaultCacheManager().getSingleFile(imageKey);
  } else {
    // Handle the case where image download failed
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: const FittedBox(
          child: Center(
            child: Text(
              "ネットワークを確認してください",
            ),
          ),
        ),
        contentTextStyle:
            const TextStyle(fontSize: Sizes.size10, color: Colors.black),
        actions: <Widget>[
          Center(
            child: CupertinoButton(
              borderRadius: BorderRadius.circular(16.0),
              color: Theme.of(context).primaryColor,
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }
  return null;
}

Future<String> getCachedImagePath(String imageUrl) async {
  File fetchedFile = await DefaultCacheManager().getSingleFile(imageUrl);
  return fetchedFile.path;
}
