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

class CreateScreen extends StatefulWidget {
  const CreateScreen({super.key});

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  int categoryId = 1;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Map<String, dynamic> formData = {};
  final ImagePicker picker = ImagePicker();
  final List<XFile> _images = [];

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
      "categoryId": categoryId,
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
        mutation Mutation(\$title: String!, \$categoryId: Int!, \$content: String, \$images: [Upload]) {
          createPost(title: \$title, categoryId: \$categoryId, content: \$content, images: \$images) {
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

        if (resultData != null && resultData['createPost'] != null) {
          final bool isLikeSuccessful = resultData['createPost']['ok'];

          if (isLikeSuccessful) {
          } else {
            // Handle the case where the like operation was not successful
            print("Like operation was not successful.");
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
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
          title: SizedBox(
            width: 150,
            child: DropdownButtonFormField(
              hint: const Text('category select'),
              decoration: const InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white))),
              items: <int>[
                1,
                2,
                3,
              ].map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text('$value'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  categoryId = value!;
                });
              },
              onSaved: (newValue) {
                formData['categoryId'] = newValue;
              },
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: Sizes.size16, vertical: Sizes.size10),
              child: GestureDetector(
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
                  width: 85,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(width: 0.3),
                      color: Colors.grey.shade300),
                  child: Transform.translate(
                    offset: const Offset(0, 8),
                    child: const Text(
                      'Submit',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            )
          ]),
      body: Stack(
        children: [
          Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Sizes.size10),
                child: Column(
                  children: [
                    TextFormField(
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
                      height: 210.0, // Adjusted for slightly larger container
                      width: 310.0, // Adjusted for slightly larger container
                      child: _images.isEmpty
                          ? const Center(child: Text('No images selected'))
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _images.length,
                              itemBuilder: (BuildContext context, int index) {
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
                                        const Positioned(
                                          top: 0,
                                          right: 0,
                                          child: Icon(Icons.cancel_rounded,
                                              color: Color(0xFFF9C7C7)),
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
          Positioned(
              bottom: 0,
              width: size.width,
              child: BottomAppBar(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Sizes.size5,
                    vertical: Sizes.size10,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: Sizes.size14),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                getImages(ImageSource.gallery);
                              },
                              child: const FaIcon(FontAwesomeIcons.photoFilm),
                            ),
                            Gaps.h20,
                            GestureDetector(
                              onTap: () {
                                getImages(ImageSource.camera);
                              },
                              child: const FaIcon(FontAwesomeIcons.camera),
                            )
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
              ))
        ],
      ),
    );
  }
}
