// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hanasaku/constants/gaps.dart';
import 'package:hanasaku/constants/sizes.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

class EditPostScreen extends StatefulWidget {
  final int postId;
  final String title;
  final String? contents;
  final List<int>? imageIdList;
  final List<XFile>? xImages;

  const EditPostScreen(
      {super.key,
      required this.postId,
      required this.title,
      required this.contents,
      required this.xImages,
      required this.imageIdList});

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  void _showDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: FittedBox(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(message),
              Gaps.v10,
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'OK',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          )),
        );
      },
    );
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Map<String, dynamic> formData = {};
  final ImagePicker picker = ImagePicker();
  final List<XFile> _images = [];
  List<XFile> displayimages = [];
  final List<XFile> _editImages = [];
  final List<int> _deletedImageId = [];
  List<int> _imageId = [];

  @override
  void initState() {
    if (widget.xImages != null) {
      displayimages = widget.xImages!;
      _images.addAll(displayimages);
      _imageId = widget.imageIdList!;
    }

    super.initState();
  }

  Future getImages(ImageSource imageSource) async {
    if (displayimages.length >= 5) {
      _showDialog(context, "画像は最大5つまで選択できます。");
      return;
    }
    //pickedFile에 ImagePicker로 가져온 이미지가 담긴다.
    final List<XFile> pickedFile = await picker.pickMultiImage();
    setState(() {
      for (var image in pickedFile) {
        if (displayimages.length < 5) {
          print(image);
          _editImages.add(image);
          displayimages.add(image);
        }
      }
    });
  }

  Future<void> _toggleSubmit(BuildContext context) async {
    final GraphQLClient client = GraphQLProvider.of(context).value;

    final Map<String, dynamic> variables = {
      "postId": widget.postId,
      "title": formData['title'],
      "content": formData['contents'],
    };

    // 이미지가 선택되었다면 변수에 이미지를 추가합니다.
    List<Uint8List> listByteData = [];
    List<MultipartFile> listMultipartFile = [];

    for (var element in _editImages) {
      print(element);
      Uint8List byteData = await element.readAsBytes();
      listByteData.add(byteData);
    }

    for (var element in listByteData) {
      var multipartFile = MultipartFile.fromBytes(
        'photo',
        element,
        filename: '${DateTime.now().second}.jpg',
        contentType: MediaType("image", "jpg"),
      );
      listMultipartFile.add(multipartFile);
    }

    variables["images"] = listMultipartFile;

    final MutationOptions options = MutationOptions(
      document: gql('''
        mutation Mutation(\$postId: Int!, \$title: String, \$content: String, \$images: [Upload]) {
          editPost(postId: \$postId, title: \$title, content: \$content, images: \$images) {
            ok
            error
          }
        }
      '''),
      variables: variables,
      onError: (error) {
        print(error);
      },
    );

    try {
      if (_deletedImageId.isNotEmpty) {
        for (var id in _deletedImageId) {
          _deleteImage(context, id);
        }
      }
      print('sending..');
      final QueryResult result = await client.mutate(options);
      print('done Sending..');
      if (result.hasException) {
        // Handle errors
        print("Error occurred: ${result.exception.toString()}");
        // You can also display an error message to the user if needed
      } else {
        final dynamic resultData = result.data;

        if (resultData != null && resultData['editPost'] != null) {
          final bool isLikeSuccessful = resultData['editPost']['ok'];

          if (isLikeSuccessful) {
          } else {
            // Handle the case where the like operation was not successful
            print("not successful.");
            print(resultData['editPost']['error']);
            // You can also display a message to the user if needed
          }
        } else {
          // Handle the case where data is null
          print("Data is null.");
          // You can also display a message to the user if needed
        }
      }
    } catch (e) {
      // Handle exceptions
      print("Error occurred: $e");
      // You can also display an error message to the user if needed
    }
  }

  Future<void> _deleteImage(BuildContext context, int imageId) async {
    final GraphQLClient client = GraphQLProvider.of(context).value;

    final MutationOptions options = MutationOptions(
      document: gql('''
        mutation DeletePostImage(\$postId: Int!, \$imageId: Int!) {
          deletePostImage(postId: \$postId, imageId: \$imageId) {
            ok
          }
        }
      '''),
      variables: {"postId": widget.postId, "imageId": imageId},
      onError: (error) {
        print(error);
      },
    );

    try {
      print('sending..');
      final QueryResult result = await client.mutate(options);
      print('done Sending..');
      if (result.hasException) {
        // Handle errors
        print("Error occurred: ${result.exception.toString()}");
        // You can also display an error message to the user if needed
      } else {
        final dynamic resultData = result.data;

        if (resultData != null && resultData['deletePostImage'] != null) {
          final bool isLikeSuccessful = resultData['deletePostImage']['ok'];

          if (isLikeSuccessful) {
          } else {
            // Handle the case where the like operation was not successful
            print("not successful.");
            // You can also display a message to the user if needed
          }
        } else {
          // Handle the case where data is null
          print("Data is null.");
          // You can also display a message to the user if needed
        }
      }
    } catch (e) {
      // Handle exceptions
      print("Error occurred: $e");
      // You can also display an error message to the user if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController titleController =
        TextEditingController(text: widget.title);
    TextEditingController contentController =
        TextEditingController(text: widget.contents);

    final deviceHeight = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(),
        body: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Stack(
            children: [
              Form(
                  key: _formKey,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: Sizes.size10),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: titleController,
                          textInputAction: TextInputAction.newline,
                          minLines: null,
                          maxLines: null,
                          decoration: InputDecoration(
                            hintText: 'Title',
                            hintStyle: const TextStyle(
                                fontSize: Sizes.size20,
                                fontWeight: FontWeight.w600),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value != null && value.isEmpty) {
                              return "Plase write your Title";
                            }
                            return null;
                          },
                          onSaved: (newValue) {
                            if (newValue != null) {
                              formData['title'] = newValue;
                            }
                          },
                        ),
                        TextFormField(
                          controller: contentController,
                          textInputAction: TextInputAction.newline,
                          minLines: null,
                          maxLines: null,
                          decoration: const InputDecoration(
                            hintText: 'Contents',
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.white,
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.white,
                              ),
                            ),
                          ),
                          validator: (value) {
                            return null;
                          },
                          onSaved: (newValue) {
                            formData['contents'] = newValue ?? " ";
                          },
                        ),
                        SizedBox(
                          height: deviceHeight /
                              3, // Adjusted for slightly larger container
                          // Adjusted for slightly larger container
                          child: displayimages.isEmpty
                              ? const Center(child: Text('イメージが選択されていません。'))
                              : ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: displayimages.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          Text(
                                            '${index + 1} / ${displayimages.length}',
                                            style: const TextStyle(
                                                fontSize: Sizes.size10),
                                          ),
                                          Flexible(
                                            child: Container(
                                              clipBehavior: Clip.hardEdge,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              child: Image.file(File(
                                                  displayimages[index].path)),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              displayimages.removeAt(index);
                                              if (_editImages.isNotEmpty) {
                                                _editImages.removeAt(
                                                    index - _images.length);
                                              }

                                              if (_images.isNotEmpty) {
                                                if (_images.length > index) {
                                                  _deletedImageId
                                                      .add(_imageId[index]);
                                                  _imageId.removeAt(index);
                                                  _images.removeAt(index);
                                                }
                                              }

                                              setState(() {});
                                            },
                                            child: const Icon(
                                                Icons.cancel_rounded,
                                                color: Color(0xFFF9C7C7)),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        )
                      ],
                    ),
                  )),
            ],
          ),
        ),
        bottomSheet: BottomAppBar(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Sizes.size5,
              vertical: Sizes.size10,
            ),
            child: Row(
              children: [
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Sizes.size14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          await getImages(ImageSource.gallery);
                          setState(() {});
                        },
                        child: const FaIcon(FontAwesomeIcons.photoFilm),
                      ),
                      // Gaps.h20,
                      // GestureDetector(
                      //   onTap: () {
                      //     getImages(ImageSource.camera);
                      //   },
                      //   child: const FaIcon(FontAwesomeIcons.camera),
                      // )
                      GestureDetector(
                        onTap: () {
                          //_toggleSubmit(context);
                          if (_formKey.currentState != null) {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              _toggleSubmit(context);
                              Navigator.pop(context);
                            }
                          }
                        },
                        child: Container(
                          height: 45,
                          width: 100,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: Theme.of(context).primaryColor),
                          child: const Center(
                            child: Text(
                              'シェア',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
