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
  final List<XFile>? xImages;

  const EditPostScreen(
      {super.key,
      required this.postId,
      required this.title,
      required this.contents,
      required this.xImages});

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Map<String, dynamic> formData = {};
  final ImagePicker picker = ImagePicker();
  List<XFile> _images = [];

  @override
  void initState() {
    if (widget.xImages != null) {
      _images = widget.xImages!;
    }
    super.initState();
  }

  Future getImages(ImageSource imageSource) async {
    //pickedFile에 ImagePicker로 가져온 이미지가 담긴다.
    final List<XFile> pickedFile = await picker.pickMultiImage();
    setState(() {
      for (var image in pickedFile) {
        _images.add(image);
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

    for (var element in _images) {
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
        mutation Mutation(\$postId: Int!, \$title: String, \$content: String, \$image: [Upload]) {
  editPost(postId: \$postId, title: \$title, content: \$content, image: \$image) {
    ok
  }
}
      '''),
      variables: variables,
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

        if (resultData != null && resultData['editPost'] != null) {
          final bool isLikeSuccessful = resultData['editPost']['ok'];

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
                          width:
                              310.0, // Adjusted for slightly larger container
                          child: _images.isEmpty
                              ? const Center(child: Text('イメージが選択されていません。'))
                              : ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _images.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return SizedBox(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Stack(
                                          children: [
                                            Align(
                                              alignment: Alignment.center,
                                              child: Image.file(
                                                  File(_images[index].path)),
                                            ),
                                            Positioned(
                                              bottom: 0,
                                              child: GestureDetector(
                                                onTap: () {
                                                  _images.removeAt(index);
                                                },
                                                child: const Icon(
                                                    Icons.cancel_rounded,
                                                    color: Color(0xFFF9C7C7)),
                                              ),
                                            ),
                                          ],
                                        ),
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
                    children: [
                      GestureDetector(
                        onTap: () {
                          getImages(ImageSource.gallery);
                        },
                        child: const FaIcon(FontAwesomeIcons.photoFilm),
                      ),
                      Gaps.h20,
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
                              'Submit',
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
