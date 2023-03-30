// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api, unnecessary_new

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:camera_guide/src/home_controller.dart';
import 'package:camera_guide/src/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import '../model/identification_number.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

typedef void OffsetCallback(Offset dataOffset);

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
    int x = 0;
    int y = 0;
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
              // alignment: Alignment.bottomCenter,
              children: [
                CameraPreview(
                  controller,
                ),
                GetLayout(
                  onDataReceived: (dataOffset) {
                    setState(() {
                      x = dataOffset.dx.toInt();
                      y = dataOffset.dy.toInt();
                    });
                  },
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                      margin:
                          const EdgeInsets.only(top: 100, left: 20, right: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Scanning ID Card',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w700),
                          ),
                          Flexible(
                            child: Text(
                              'Position your ID card within the rectangle and ensure the image is perfectly readable.',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      )),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Material(
                      color: Colors.transparent,
                      child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.black12,
                            shape: BoxShape.circle,
                          ),
                          margin: const EdgeInsets.all(25),
                          child: IconButton(
                            enableFeedback: true,
                            color: Colors.white,
                            onPressed: () async {
                              for (int i = 10; i > 0; i--) {
                                await HapticFeedback.vibrate();
                              }
                              onTakePicture(x, y);
                            },
                            icon: const Icon(
                              Icons.camera,
                            ),
                            iconSize: 72,
                          ))),
                ),
              ],
            );
          } else {
            return const Center(
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

  void onTakePicture(int xCrop, int yCrop) async {
    await controller.setFocusMode(FocusMode.auto);

    await controller.takePicture().then((XFile xfile) {
      if (mounted) {
        if (xfile != null) {
          cropImage(File(xfile.path), 0, 300, 500, 280).then((value) {
            print("xCrop::${xCrop}" + "yCrop:::${yCrop}");
            sendFormDataImg(value!);
          });
        }
      }
      return;
    });
  }

  void sendFormDataImg(File image) async {
    final formData = http.MultipartRequest(
        'POST', Uri.parse('http://159.65.9.80:4000/check'));
    final file = await http.MultipartFile.fromPath('file', image.path);
    formData.files.add(file);
    final response = await formData.send();
    http.Response.fromStream(response).then((res) {
      if (response.statusCode == HttpStatus.ok) {
        ref.read(xFileProvider.notifier).state = image;
        var profile = identificationNumberFromJson(res.body);
        print(res.body);
        print(profile.data);
        ref.read(identificationNumberProvider.notifier).state = profile;
        context.pushNamed(ProfileScreen.routeName);
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('กรุณาถ่ายใหม่อีกครั้ง'),
            content: SizedBox(
                width: 200.0, height: 200.0, child: Image.file(File(image.path))

                //  CircleAvatar(
                //   backgroundImage: Image.file(
                //     File(image.path),
                //   ).image,

                ),
          ),
        );
      }
    });
  }
}

class GetLayout extends StatefulWidget {
  final OffsetCallback onDataReceived;
  const GetLayout({super.key, required this.onDataReceived});

  @override
  State<GetLayout> createState() => _GetLayoutState();
}

class _GetLayoutState extends State<GetLayout> {
  final _key = GlobalKey();

  double X_Position = 0.00;
  double Y_Position = 0.00;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) => _getPosition());
  }

  void _getPosition() {
    RenderBox? box = _key.currentContext!.findRenderObject() as RenderBox?;
    Offset position = box!.localToGlobal(Offset.zero);
    setState(() {
      X_Position = position.dx;
      Y_Position = position.dy;
      // widget.onDataReceived(Offset(position.dx, position.dy));
      // widget.onDataReceived(Offset(19, 350));
    });
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context);
    var size = media.size;
    double width = media.orientation == Orientation.portrait
        ? size.shortestSide * .9
        : size.longestSide * .5;
    double ratio = 1.42;
    double height = width / ratio;
    double radius = 0.067 * height;
    if (media.orientation == Orientation.portrait) {}
    return Stack(
      children: [
        ColorFiltered(
          colorFilter: const ColorFilter.mode(Colors.black54, BlendMode.srcOut),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    key: _key,
                    width: width,
                    height: width / ratio,
                    decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(radius)),
                  ),
                ),
              ),
              Row(
                children: [
                  Text(
                    X_Position != null
                        ? 'X: ${NumberFormat("#,###.##").format(X_Position)}'
                        : '',
                    style: TextStyle(fontSize: 24),
                  ),
                  Text(
                    Y_Position != null
                        ? 'Y: ${NumberFormat("#,###.##").format(Y_Position)}'
                        : '',
                    style: TextStyle(fontSize: 24),
                  ),
                ],
              )
            ],
          ),
        )
      ],
    );
  }
}

class OverlayShape extends StatelessWidget {
  const OverlayShape({super.key});
  @override
  Widget build(BuildContext context) {
    GlobalKey gbKey = GlobalKey();

    var media = MediaQuery.of(context);
    var size = media.size;
    double width = media.orientation == Orientation.portrait
        ? size.shortestSide * .9
        : size.longestSide * .5;

    double ratio = 1.42;
    double height = width / ratio;
    double radius = 0.067 * height;
    if (media.orientation == Orientation.portrait) {}
    return Stack(
      children: [
        ColorFiltered(
          colorFilter: const ColorFilter.mode(Colors.black54, BlendMode.srcOut),
          child: Stack(
            children: [
              Container(
                key: gbKey,
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: width,
                    height: width / ratio,
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(radius)),
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}

Future<File?> cropImage(
    File imageFile, int x, int y, int width, int height) async {
  final bytes = await imageFile.readAsBytes();
  final originalImage = img.decodeImage(bytes);
  if (originalImage == null) {
    return null;
  }
  final croppedImage =
      img.copyCrop(originalImage, x: x, y: y, width: width, height: height);
  if (croppedImage == null) {
    return null;
  }
  final croppedBytes = img.encodeJpg(croppedImage);
  final croppedFile = File('${imageFile.path}');
  await croppedFile.writeAsBytes(croppedBytes);
  return croppedFile;
}

enum EnumCameraDescription { front, back }
