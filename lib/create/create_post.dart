// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:typed_data';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hanasaku/constants/gaps.dart';
import 'package:hanasaku/constants/sizes.dart';
import 'package:hanasaku/setup/userinfo_provider_model.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class CreateScreen extends StatefulWidget {
  const CreateScreen({super.key});

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  int? categoryId;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String content = """内容を入力してください

• 相手に不快感を与えるコンテンツは
  制裁を受ける可能性があります
""";

  Map<String, dynamic> formData = {};
  final ImagePicker picker = ImagePicker();
  final List<XFile> _images = [];

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
    //final size = MediaQuery.of(context).size;
    final userInfoProvider =
        Provider.of<UserInfoProvider>(context, listen: false);
    final selectedCategory = userInfoProvider.getSelectedCategory();
    final deviceHeight = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(),
        body: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Stack(
            children: [
              // Container(
              //   height: 40,
              //   decoration: BoxDecoration(
              //     borderRadius: BorderRadius.circular(20),
              //     border: Border.all(
              //         color: Colors.grey, style: BorderStyle.solid, width: 0.80),
              //   ),
              //   child:
              // ),
              Form(
                  key: _formKey,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: Sizes.size10),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        DropdownButtonFormField(
                          focusColor: Colors.white,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                            ),
                          ),
                          hint: const Center(
                            child: Text(
                              'Room',
                            ),
                          ),
                          items: selectedCategory.map((value) {
                            return DropdownMenuItem(
                              value: value['id'],
                              child: Center(
                                child: Text(
                                  value['name'],
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              categoryId = value as int;
                            });
                          },
                          onSaved: (newValue) {
                            formData['categoryId'] = newValue;
                          },
                        ),
                        TextFormField(
                          textInputAction: TextInputAction.newline,
                          minLines: null,
                          maxLines: null,
                          decoration: InputDecoration(
                            hintText: 'タイトル', //제목
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
                              return "タイトルを入力してください";
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
                          decoration: InputDecoration(
                            // helperText:
                            //     '不適切または不快感を与える可能性のあるコンテンツは\n制裁を受ける可能性があります',
                            hintText: content,
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.white,
                              ),
                            ),
                            focusedBorder: const UnderlineInputBorder(
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
                          height: deviceHeight / 3, // 디바이스 높이의 1/4
                          child: _images.isEmpty
                              ? const Center(child: Text('イメージが選択されていません。'))
                              : CarouselSlider.builder(
                                  itemCount: _images.length,
                                  itemBuilder: (BuildContext context, int index,
                                      int pageViewIndex) {
                                    return Column(
                                      children: [
                                        Flexible(
                                            child: Image.file(
                                                File(_images[index].path))),
                                        IconButton(
                                          icon: const FaIcon(
                                            FontAwesomeIcons.circleXmark,
                                            color: Colors.black,
                                            size: Sizes.size16,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _images.removeAt(index);
                                            });
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                  options: CarouselOptions(
                                    height: deviceHeight / 4,
                                    enlargeCenterPage: true,
                                    autoPlay: false,
                                  ),
                                ),
                        )
                      ],
                    ),
                  )),
              // Positioned(
              //     bottom: 0,
              //     width: size.width,
              //     child: )
            ],
          ),
        ),
        bottomSheet: BottomAppBar(
          elevation: 3,
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
                        onTap: () {
                          getImages(ImageSource.gallery);
                        },
                        child: FaIcon(
                          FontAwesomeIcons.image,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      Gaps.h20,
                      // GestureDetector(
                      //   onTap: () {
                      //     getImages(ImageSource.camera);
                      //   },
                      //   child: const FaIcon(FontAwesomeIcons.camera),
                      // ),

                      GestureDetector(
                        onTap: () {
                          //_toggleSubmit(context);
                          if (_formKey.currentState != null) {
                            if (_formKey.currentState!.validate() &&
                                categoryId != null) {
                              _formKey.currentState!.save();
                              _toggleSubmit(context);
                              Navigator.pop(context);
                            } else {
                              // If the category is not selected, show an AlertDialog
                              if (categoryId == null) {
                                _showDialog(context, "Roomを選択してください。");
                              }
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
