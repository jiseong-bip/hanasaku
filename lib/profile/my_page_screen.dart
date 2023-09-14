import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hanasaku/auth/logout_screen.dart';
import 'package:hanasaku/constants/font.dart';
import 'package:hanasaku/constants/gaps.dart';
import 'package:hanasaku/constants/sizes.dart';
import 'package:hanasaku/profile/comment_post.dart';
import 'package:hanasaku/profile/liked_post.dart';
import 'package:hanasaku/profile/my_post.dart';
import 'package:hanasaku/setup/navigator.dart';
import 'package:hanasaku/setup/userinfo_provider_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({
    super.key,
  });

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  bool _editMode = false;
  final ImagePicker _picker = ImagePicker();
  File? _profileImage;
  String? nickName;

  Future<void> _loadSavedImage() async {
    final directory = await getApplicationDocumentsDirectory();
    final imagePath = '${directory.path}/profile_image.jpg';
    final savedImage = File(imagePath);

    if (savedImage.existsSync()) {
      setState(() {
        _profileImage = savedImage;
      });
    }
  }

  void getImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final croppedFile = await ImageCropper().cropImage(
          cropStyle: CropStyle.circle,
          sourcePath: image.path,
          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9
          ],
          uiSettings: [
            AndroidUiSettings(
                toolbarTitle: 'Crop',
                cropGridColor: Colors.black,
                initAspectRatio: CropAspectRatioPreset.original,
                lockAspectRatio: false),
            IOSUiSettings(title: 'Crop')
          ]);

      if (croppedFile != null) {
        setState(() {
          _profileImage = File(croppedFile.path);
        });
      }
    }
  }

  Future<void> _saveImage() async {
    if (_profileImage != null) {
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/profile_image.jpg';
      await _profileImage!.copy(imagePath);
    }
  }

  Future initName() async {
    nickName = await Provider.of<UserInfoProvider>(context, listen: false)
        .getNickName();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    initName();
    _loadSavedImage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: 6, color: Colors.grey.shade300),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: Sizes.size16, vertical: Sizes.size10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        GestureDetector(
                          onTap: _editMode ? getImage : null,
                          child: _editMode
                              ? const CircleAvatar(
                                  radius: 35,
                                  backgroundColor: Colors.grey,
                                  child: Text(
                                    '写真編集',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: MyFontFamily.lineSeedJP),
                                  ),
                                )
                              : CircleAvatar(
                                  radius: 35,
                                  backgroundImage: _profileImage != null
                                      ? FileImage(_profileImage!)
                                      : null,
                                ),
                        ),
                        Gaps.v14,
                        GestureDetector(
                          onTap: () {
                            if (_editMode) {
                              _saveImage();
                            }
                            setState(() {
                              _editMode = !_editMode;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              border:
                                  Border.all(width: 0.3, color: Colors.grey),
                              color: Colors.grey.shade300,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: Sizes.size10,
                                vertical: Sizes.size5,
                              ),
                              child: Text(
                                _editMode ? '貯蔵' : '編集',
                                style: const TextStyle(
                                    fontFamily: MyFontFamily.lineSeedJP),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Gaps.h20,
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: Sizes.size16),
                      child: Column(
                        children: [
                          Text(
                            "$nickName",
                            style: const TextStyle(
                              fontSize: Sizes.size20,
                              fontFamily: MyFontFamily.lineSeedJP,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            Column(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MyPostScreen()));
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                        border: Border(
                            bottom:
                                BorderSide(width: 0.6, color: Colors.grey))),
                    padding: const EdgeInsets.symmetric(
                      vertical: Sizes.size16,
                      horizontal: Sizes.size36,
                    ),
                    child: const Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                            alignment: Alignment.centerLeft,
                            child: FaIcon(FontAwesomeIcons.pencil)),
                        Text(
                          '私が書いた掲示物', //작성한 게시물
                          style: TextStyle(
                              fontSize: Sizes.size24,
                              fontFamily: MyFontFamily.lineSeedJP),
                        )
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LikedPostScreen()));
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                        border: Border(
                            bottom:
                                BorderSide(width: 0.6, color: Colors.grey))),
                    padding: const EdgeInsets.symmetric(
                      vertical: Sizes.size16,
                      horizontal: Sizes.size36,
                    ),
                    child: const Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                            alignment: Alignment.centerLeft,
                            child: FaIcon(FontAwesomeIcons.thumbsUp)),
                        Text(
                          'いいねを押した掲示物', //좋아요 누른 게시물
                          style: TextStyle(
                              fontSize: Sizes.size24,
                              fontFamily: MyFontFamily.lineSeedJP),
                        )
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CommentPostScreen()));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                                width: 6, color: Colors.grey.shade300))),
                    padding: const EdgeInsets.symmetric(
                      vertical: Sizes.size16,
                      horizontal: Sizes.size36,
                    ),
                    child: const Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                            alignment: Alignment.centerLeft,
                            child: FaIcon(FontAwesomeIcons.comment)),
                        Text(
                          'コメント欄の掲示物',
                          style: TextStyle(
                              fontSize: Sizes.size24,
                              fontFamily: MyFontFamily.lineSeedJP),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Column(
              children: [
                GestureDetector(
                  onTap: () {
                    navigatorKey.currentState!.push(MaterialPageRoute(
                        builder: (rootContext) => const LogOutScreen()));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                                width: 6, color: Colors.grey.shade300))),
                    padding: const EdgeInsets.symmetric(
                      vertical: Sizes.size16,
                      horizontal: Sizes.size36,
                    ),
                    child: const Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          'LogOut',
                          style: TextStyle(
                              fontSize: Sizes.size24,
                              fontFamily: MyFontFamily.lineSeedJP),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
