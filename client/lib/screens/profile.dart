import 'dart:io';
import 'package:client/dummy_data.dart';
import 'package:client/elements/bottom_navbar.dart';
import 'package:client/elements/button.dart';
import 'package:client/elements/loading.dart';
import 'package:client/elements/profile_picture.dart';
import 'package:client/screens/profile/main_profile.dart';
import 'package:client/screens/profile/settings.dart';
import 'package:client/tools/api_handler.dart';
import 'package:client/tools/router.dart';
import 'package:client/tools/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class Profile extends ConsumerStatefulWidget {
  const Profile({super.key});

  @override
  ProfileState createState() => ProfileState();
}

class ProfileState extends ConsumerState<Profile> {
  late final RouterNotifier router;
  late final UserNotifier user;
  Map<String, dynamic> profile = {
    "username": "",
    "pfp": DummyData.profilePicture,
    "lvl": 0,
    "exp": 0,
    "xpToNextLevel": 1,
  };
  late List<Map<String, dynamic>> quizzes = [];
  late List<Map<String, dynamic>> history = [];

  bool loading = true;

  String page = "main";

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      router = ref.read(routerProvider.notifier);
      user = ref.read(userProvider.notifier);
      _getProfile();
      _getQuizzes(user.token!);
      _getHistory(user.token!);
      setState(() {
        loading = false;
      });
    });
  }

  void _getProfile() async {
  user.getProfile().then((value) {
    print("Profile data: $value");
    setState(() {
      profile = value;
    });
  });
}


  Future<void> _selectAndUploadImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        File image = File(pickedFile.path);
        await _uploadImage(image);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting image: $e')),
      );
    }
  }

  Future<void> _uploadImage(File image) async {
    final response = await ApiHandler.uploadProfilePicture(image, user.token!);

    if (response["success"]) {
      _getProfile();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response["message"])),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response["message"])),
      );
    }
  }

  Widget profileScreen() {
    if (!loading) {
      if (page == "main") {
        return MainProfile(quizzes: quizzes, history: history);
      } else if (page == "settings") {
        return Settings();
      } else {
        return Container();
      }
    } else {
      return const Center(child: LogoLoading());
    }
  }

  void _getQuizzes(String token) async {
    ApiHandler.getUserQuizzesByToken(token, 0, 5).then((value) {
      setState(() {
        quizzes = value;
      });
    });
  }

  void _getHistory(String token) async {
    ApiHandler.getQuizzesByUserHistory(token, 0, 5).then((value) {
      setState(() {
        history = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.all(10),
        child: Column(
          children: [
            // profile header section
            Row(
              children: [
                GestureDetector(
                  onTap: _selectAndUploadImage,
                  child: ClipOval(
                    child: ProfilePicture(
                      url: profile["pfp"] +
                          "?t=${DateTime.now().millisecondsSinceEpoch}",
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  "${profile["username"]}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                    "Level ${profile["xpToNextLevel"] == -1 ? "Max" : profile["lvl"]}"),
                const SizedBox(width: 10),
                Container(
                  width: 100,
                  height: 10,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: Colors.grey,
                  ),
                  child: Stack(
                    children: [
                      Container(
                        width: profile["xpToNextLevel"] == -1
                            ? 100
                            : (profile["exp"] / profile["xpToNextLevel"]) * 100,
                        height: 10,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: theme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Text("${profile["exp"]} / ${profile["xpToNextLevel"]} XP"),
              ],
            ),
            const SizedBox(height: 10),
            // Button row
            Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: SizedTextButton(
                      text: page == "settings" ? "Profile" : "Settings",
                      icon: Icon(
                          page == "settings" ? Icons.person : Icons.settings,
                          color: Colors.white),
                      onPressed: () => {
                        setState(
                          () {
                            page = page == "settings" ? "main" : "settings";
                          },
                        )
                      },
                      height: 40,
                      textStyle:
                          const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: SizedTextButton(
                      text: "Friends",
                      icon: const Icon(Icons.people, color: Colors.white),
                      onPressed: () => router.setPath(context, "friends"),
                      height: 40,
                      textStyle:
                          const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: SizedTextButton(
                      text: "Sign out",
                      icon: const Icon(Icons.logout, color: Colors.white),
                      onPressed: () => {user.logout(context, router)},
                      height: 40,
                      textStyle:
                          const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Expanded scrollable area
            profileScreen(),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavbar(path: "profile"),
    );
  }
}
