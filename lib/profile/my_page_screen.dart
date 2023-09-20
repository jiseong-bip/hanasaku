// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hanasaku/auth/logout_screen.dart';
import 'package:hanasaku/constants/font.dart';
import 'package:hanasaku/constants/gaps.dart';
import 'package:hanasaku/constants/sizes.dart';
import 'package:hanasaku/profile/comment_post.dart';
import 'package:hanasaku/profile/liked_post.dart';
import 'package:hanasaku/profile/my_post.dart';
import 'package:hanasaku/profile/withdrawal.dart';
import 'package:hanasaku/query&mutation/querys.dart';
import 'package:hanasaku/setup/navigator.dart';
import 'package:hanasaku/setup/userinfo_provider_model.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
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
  final List<Map<int, dynamic>> _medal = [];
  int? lengthOfKey1;
  int? lengthOfKey2;
  int? lengthOfKey3;
  TextEditingController textController = TextEditingController();
  ScrollController scrollController = ScrollController();

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

  Future<void> setProfile(String? userName, File? profileImage) async {
    final GraphQLClient client = GraphQLProvider.of(context).value;
    MultipartFile? listMultipartFile;
    if (profileImage != null) {
      Uint8List byteData = await profileImage.readAsBytes();
      var multipartFile = MultipartFile.fromBytes(
        'photo',
        byteData,
        filename: '$nickName${DateTime.now()}.jpg',
        contentType: MediaType("image", "jpg"),
      );
      listMultipartFile = multipartFile;
      print(multipartFile);
      print(listMultipartFile);
    }

    final MutationOptions editUser = MutationOptions(
      document: gql('''
        mutation EditProfile(\$userName: String, \$avatar: Upload) {
  editProfile(userName: \$userName, avatar: \$avatar) {
    ok
  }
}

      '''),
      variables: <String, dynamic>{
        "userName": userName!.isNotEmpty ? userName : null,
        "avatar": listMultipartFile
      },
      update: (cache, result) => result,
    );
    try {
      final QueryResult result = await client.mutate(editUser);
      if (result.data != null) {
        print(result.data!['editProfile']['ok']);
        if (userName.isNotEmpty) {
          await Provider.of<UserInfoProvider>(context, listen: false)
              .setNickName(userName);
          setState(() {
            nickName = userName;
          });
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _fetchMyPosts() async {
    final GraphQLClient client = GraphQLProvider.of(context).value;

    final QueryOptions options = QueryOptions(
        document: getMyInfoQuery,
        cacheRereadPolicy: CacheRereadPolicy.ignoreAll);

    final QueryResult result = await client.query(options);

    if (!result.hasException) {
      setState(() {
        if (result.data!['me']['medals'] != null) {
          var medals = result.data!['me']['medals'];
          Map<int, List<String>> groupedMedals = {};
          for (var medal in medals) {
            if (groupedMedals[medal["level"]] == null) {
              groupedMedals[medal["level"]] = [];
            }
            groupedMedals[medal["level"]]!.add(medal["name"]);
          }
          groupedMedals.forEach((key, value) {
            _medal.add({key: value});
          });
        }
        var itemsWithKey1 = _medal.where((item) => item.containsKey(1));
        var itemsWithKey2 = _medal.where((item) => item.containsKey(2));
        var itemsWithKey3 = _medal.where((item) => item.containsKey(3));

        if (itemsWithKey1.isNotEmpty) {
          lengthOfKey1 = itemsWithKey1.first[1].length;
        } else {
          print('There is no item with key 1 in the _medal list.');
        }

        if (itemsWithKey2.isNotEmpty) {
          lengthOfKey2 = itemsWithKey2.first[2].length;
        } else {
          print('There is no item with key 2 in the _medal list.');
        }

        if (itemsWithKey3.isNotEmpty) {
          lengthOfKey3 = itemsWithKey3.first[3].length;
        } else {
          print('There is no item with key 3 in the _medal list.');
        }
      });
    } else {
      print(result.exception);
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
    Future.delayed(Duration.zero, () {
      _fetchMyPosts();
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(width: 6, color: Color(0xFFF6F4F4)),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Sizes.size16, vertical: Sizes.size10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            GestureDetector(
                              onTap: _editMode ? getImage : null,
                              child: _editMode
                                  ? CircleAvatar(
                                      radius: 35,
                                      backgroundColor: Colors.grey,
                                      backgroundImage: _profileImage != null
                                          ? FileImage(_profileImage!)
                                          : null,
                                      child: const Text(
                                        '写真編集',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontFamily:
                                                MyFontFamily.lineSeedJP),
                                      ),
                                    )
                                  : CircleAvatar(
                                      radius: 35,
                                      backgroundImage: _profileImage != null
                                          ? FileImage(_profileImage!)
                                          : null,
                                      child: _profileImage != null
                                          ? null
                                          : SvgPicture.asset(
                                              'assets/user.svg',
                                              width: 70,
                                              height: 70,
                                            ),
                                    ),
                            ),
                            Gaps.v14,
                          ],
                        ),
                        Gaps.h20,
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: Sizes.size16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  _editMode
                                      ? SizedBox(
                                          width: 150,
                                          child: TextField(
                                            controller: textController,
                                            autocorrect: false,
                                            decoration: InputDecoration(
                                              hintText: "$nickName",
                                              enabledBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Colors.grey.shade400,
                                                ),
                                              ),
                                              focusedBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Colors.grey.shade400,
                                                ),
                                              ),
                                            ),
                                            cursorColor:
                                                Theme.of(context).primaryColor,
                                          ),
                                        )
                                      : Text(
                                          "$nickName",
                                          style: const TextStyle(
                                            fontSize: Sizes.size20,
                                            fontFamily: MyFontFamily.lineSeedJP,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                  Gaps.h5,
                                  GestureDetector(
                                    onTap: () async {
                                      if (_editMode) {
                                        _saveImage();
                                        await setProfile(
                                            textController.text, _profileImage);
                                        setState(() {});
                                      }
                                      setState(() {
                                        _editMode = !_editMode;
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: Colors.grey.shade200,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: Sizes.size5,
                                          vertical: Sizes.size3,
                                        ),
                                        child: Text(
                                          _editMode ? '貯蔵' : '編集',
                                          style: const TextStyle(
                                              fontSize: Sizes.size12),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Gaps.v12,
                              Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFFECC12A)),
                                  ),
                                  Gaps.h5,
                                  Text('${lengthOfKey1 ?? 0}'),
                                  Gaps.h5,
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFFC8C8C8)),
                                  ),
                                  Gaps.h5,
                                  Text('${lengthOfKey2 ?? 0}'),
                                  Gaps.h5,
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFF946125)),
                                  ),
                                  Gaps.h5,
                                  Text('${lengthOfKey3 ?? 0}'),
                                ],
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MyPostScreen()));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                                width: 0.6, color: Colors.grey.shade300),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: Sizes.size12,
                          horizontal: Sizes.size24,
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.create_outlined,
                              color: Color(0xFFB6DDE6),
                            ),
                            Gaps.h14,
                            Text(
                              '私が書いた掲示物', //작성한 게시물
                              style: TextStyle(
                                  fontSize: Sizes.size20,
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
                        decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  width: 0.6, color: Colors.grey.shade300)),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: Sizes.size12,
                          horizontal: Sizes.size24,
                        ),
                        child: Row(
                          children: [
                            FaIcon(
                              FontAwesomeIcons.heart,
                              color: Theme.of(context).primaryColor,
                            ),
                            Gaps.h14,
                            const Text(
                              'いいねを押した掲示物', //좋아요 누른 게시물
                              style: TextStyle(
                                  fontSize: Sizes.size20,
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
                                builder: (context) =>
                                    const CommentPostScreen()));
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              width: 6,
                              color: Color(0xFFF6F4F4),
                            ),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: Sizes.size12,
                          horizontal: Sizes.size24,
                        ),
                        child: const Row(
                          children: [
                            FaIcon(
                              FontAwesomeIcons.comment,
                              color: Color(0xFFC1DE92),
                            ),
                            Gaps.h14,
                            Text(
                              'コメント欄の掲示物',
                              style: TextStyle(
                                  fontSize: Sizes.size20,
                                  fontFamily: MyFontFamily.lineSeedJP),
                            )
                          ],
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Container(
                          width: screenWidth,
                          decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    width: 0.6, color: Colors.grey.shade300)),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: Sizes.size12,
                            horizontal: Sizes.size24,
                          ),
                          child: const Text(
                            '公知事項', //공지사항
                            style: TextStyle(
                                fontSize: Sizes.size20,
                                fontFamily: MyFontFamily.lineSeedJP),
                          ),
                        ),
                        Container(
                          width: screenWidth,
                          decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    width: 0.6, color: Colors.grey.shade300)),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: Sizes.size12,
                            horizontal: Sizes.size24,
                          ),
                          child: const Text(
                            'キャッシュデータを削除する', //캐시데티어 삭제
                            style: TextStyle(
                                fontSize: Sizes.size20,
                                fontFamily: MyFontFamily.lineSeedJP),
                          ),
                        ),
                        Container(
                          width: screenWidth,
                          decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    width: 0.6, color: Colors.grey.shade300)),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: Sizes.size12,
                            horizontal: Sizes.size24,
                          ),
                          child: const Text(
                            'サービス利用薬科', //서비스 이용약관
                            style: TextStyle(
                                fontSize: Sizes.size20,
                                fontFamily: MyFontFamily.lineSeedJP),
                          ),
                        ),
                        Container(
                          width: screenWidth,
                          decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    width: 0.6, color: Colors.grey.shade300)),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: Sizes.size12,
                            horizontal: Sizes.size24,
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'うはか ん', //버전관리
                                style: TextStyle(
                                    fontSize: Sizes.size20,
                                    fontFamily: MyFontFamily.lineSeedJP),
                              ),
                              Gaps.h3,
                              Text(
                                'さいしんバージョン: 23.32.1', //업데이트 날짜
                                style: TextStyle(
                                    fontSize: Sizes.size12,
                                    fontFamily: MyFontFamily.lineSeedJP),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            navigatorKey.currentState!.push(MaterialPageRoute(
                                builder: (rootContext) =>
                                    const LogOutScreen()));
                          },
                          child: Container(
                            width: screenWidth,
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        width: 0.6,
                                        color: Colors.grey.shade300))),
                            padding: const EdgeInsets.symmetric(
                              vertical: Sizes.size12,
                              horizontal: Sizes.size24,
                            ),
                            child: const Text(
                              'LogOut',
                              style: TextStyle(
                                  fontSize: Sizes.size20,
                                  fontFamily: MyFontFamily.lineSeedJP),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            navigatorKey.currentState!.push(MaterialPageRoute(
                                builder: (context) =>
                                    const DeleteAccountPage()));
                          },
                          child: Container(
                            width: screenWidth,
                            decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      width: 0.6, color: Colors.grey.shade300)),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: Sizes.size12,
                              horizontal: Sizes.size24,
                            ),
                            child: const Text(
                              '脱退する', //탈퇴하기
                              style: TextStyle(
                                  fontSize: Sizes.size20,
                                  fontFamily: MyFontFamily.lineSeedJP),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
