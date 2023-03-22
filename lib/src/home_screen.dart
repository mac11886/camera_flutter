import 'dart:io';

import 'package:camera/camera.dart';
import 'package:camera_guide/src/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:dio/dio.dart';
import 'profile_screen.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulHookConsumerWidget {
  const HomeScreen({super.key});

  static const routeName = 'home-screen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late CameraController controller;

  @override
  Widget build(BuildContext context) {
    final xFileState = ref.watch(xFileProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: Image.file(File(xFileState.path)).image,
            ),
            SizedBox(
              width: 10.0,
            ),
            Text('Home'),
          ],
        ),
      ),
      body: FutureBuilder(
        future: initializationCamera(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              alignment: Alignment.bottomCenter,
              children: [
                AspectRatio(
                  aspectRatio: 3 / 4,
                  child: CameraPreview(controller),
                ),
                AspectRatio(
                  aspectRatio: 3 / 4,
                  child: Image.asset(
                    'assets/images/idTransparent.png',
                    fit: BoxFit.cover,
                  ),
                ),
                InkWell(
                  onTap: () => onTakePicture(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: CircleAvatar(
                      radius: 30.0,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  Future<void> initializationCamera() async {
    var cameras = await availableCameras();
    controller = CameraController(
      cameras[EnumCameraDescription.front.index],
      ResolutionPreset.medium,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );
    await controller.initialize();
  }

  void onTakePicture() async {
    await controller.takePicture().then((XFile xfile) {
      if (mounted) {
        if (xfile != null) {
          ref.read(xFileProvider.notifier).state = xfile;
          // context.pushNamed(ProfileScreen.routeName);
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Ambil Gambar'),
              content: SizedBox(
                width: 200.0,
                height: 200.0,
                child: CircleAvatar(
                  backgroundImage: Image.file(
                    File(xfile.path),
                  ).image,
                ),
              ),
            ),
          );
          sendFormDataImg(File(xfile.path));
        }
      }
      return;
    });
  }

  void sendFormDataImg(File image) async {
    final dio = Dio();
    final formData = FormData.fromMap({
      'file': image,
    });
    print("image:$image");
    final response =
        await dio.post('http://188.166.217.149:4000/check', data: formData);
    print(response.data);
  }
}

enum EnumCameraDescription { front, back }
