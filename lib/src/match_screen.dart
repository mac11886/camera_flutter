import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_face_api/face_api.dart' as faceApi;
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

    Uint8List convertStringToUint8List(String str) {
      final List<int> codeUnits = str.codeUnits;
      final Uint8List unit8List = Uint8List.fromList(codeUnits);

      return unit8List;
    }

    void matchImg(
      String imageFirst,
      XFile imageSecond,
    ) {
      var image1 = faceApi.MatchFacesImage();
      var image2 = faceApi.MatchFacesImage();
      image1.bitmap = base64Encode(convertStringToUint8List(imageFirst));
      image1.imageType = faceApi.ImageType.PRINTED;
      image2.bitmap = base64Encode(File(imageSecond.path).readAsBytesSync());
      image2.imageType = faceApi.ImageType.PRINTED;
      var request = faceApi.MatchFacesRequest();
      request.images = [image1, image2];
      faceApi.FaceSDK.matchFaces(jsonEncode(request))
          .then((macthFacesResponse) {
        var response = faceApi.MatchFacesResponse.fromJson(
            json.decode(macthFacesResponse));
        var split = faceApi.MatchFacesSimilarityThresholdSplit.fromJson(
            json.decode(macthFacesResponse));
        var similarity = split!.matchedFaces.length > 0
            ? ((split.matchedFaces[0]!.similarity! * 100).toStringAsFixed(2) +
                "%")
            : " error ";
        print("similarity:::${similarity}");
      });
    }

    void onTakePicture() async {
      await controller.takePicture().then((XFile xfile) {
        if (mounted) {
          if (xfile != null) {
            print("xfile.path:::::" + xfile.path);
            String pic = identificationNumber.data?.pic ?? "";
            print("Img.path:::::" + pic);

            matchImg(pic, xfile);
            // ref.read(xFileProvider.notifier).state = xfile;
            // context.pushNamed(ProfileScreen.routeName);
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Ambil Gambar'),
                content: SizedBox(
                  width: 200.0,
                  height: 200.0,
                  child: CircleAvatar(
                    backgroundImage: 
                    Image.network(pic).image
                    // Image.file(
                    //   File(xfile.path),
                    // ).image,
                  ),
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
