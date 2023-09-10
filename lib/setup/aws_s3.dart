// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter_aws_s3_client/flutter_aws_s3_client.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

const region = "ap-northeast-2";
const bucketId = "jeon-jue";

final AwsS3Client awsS3Client = AwsS3Client(
    region: region,
    host: "s3.$region.amazonaws.com",
    bucketId: bucketId,
    accessKey: "AKIAXRQ2ICJ2X3COJJ6N",
    secretKey: "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");

Future getImage(List<Object?> images) async {
  final cacheManager = DefaultCacheManager();

  for (var image in images) {
    String imageKey = (image as Map<String, dynamic>)['url'];
    // Check if image data already exists

    if (await cacheManager.getFileFromCache(imageKey) != null) {
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

Future<String> getCachedImagePath(String imageUrl) async {
  File fetchedFile = await DefaultCacheManager().getSingleFile(imageUrl);
  return fetchedFile.path;
}
