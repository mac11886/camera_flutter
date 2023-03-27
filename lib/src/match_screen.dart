import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;

import 'home_controller.dart';

late List<CameraDescription> _cameras;

class MactchScreen extends StatefulHookConsumerWidget {
  const MactchScreen({super.key});
  static const routeName = 'match-screen';

  @override
  _MactchScreenState createState() => _MactchScreenState();
}

class _MactchScreenState extends ConsumerState<MactchScreen> {
  late CameraController controller;

  Future<void> initializationCamera() async {
    var cameras = await availableCameras();
    controller = CameraController(
      cameras[EnumCameraDescription.back.index],
      ResolutionPreset.medium,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );
    await controller.initialize();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final identificationNumber = ref.watch(identificationNumberProvider);

    void onTakePicture() async {
      await controller.takePicture().then((XFile xfile) {
        if (mounted) {
          if (xfile != null) {
            print("xfile.path:::::" + xfile.path);
            String pic = identificationNumber.data?.pic ?? "";
            print("Img.path:::::" + pic);
            // ref.read(xFileProvider.notifier).state = xfile;
            // context.pushNamed(ProfileScreen.routeName);
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('รูป'),
                content: SizedBox(
                    width: 200.0,
                    height: 200.0,
                    child: Column(
                      children: [
                        Text(" "),
                        CircleAvatar(backgroundImage: Image.network(pic).image),
                      ],
                    )
                    //     // Image.file(
                    //     //   File(xfile.path),
                    //     // ).image,

                    ),
              ),
            );
          }
        }
        return;
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Match"),
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
                      'assets/images/camera-overlay-conceptcoder.png',
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
          }),
    );
  }
}

enum EnumCameraDescription { front, back }
