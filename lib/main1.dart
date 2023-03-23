import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_camera_overlay/flutter_camera_overlay.dart';
import 'package:flutter_camera_overlay/model.dart';

import 'package:http/http.dart' as http;

import 'model/identification_number.dart';

main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ExampleCameraOverlay(),
  );
}

class ExampleCameraOverlay extends StatefulWidget {
  const ExampleCameraOverlay({Key? key}) : super(key: key);

  @override
  _ExampleCameraOverlayState createState() => _ExampleCameraOverlayState();
}

class _ExampleCameraOverlayState extends State<ExampleCameraOverlay> {
  // layout camera overlay
  OverlayFormat format = OverlayFormat.cardID2;
  bool checkTakeImg = false;
  int count = 0;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<List<CameraDescription>?>(
        future: availableCameras(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data == null) {
              return const Align(
                  alignment: Alignment.center,
                  child: Text(
                    'No camera found',
                    style: TextStyle(color: Colors.black),
                  ));
            }
            return CameraOverlay(snapshot.data!.first,
                CardOverlay.byFormat(format), (XFile file) => sendImg(file),

                // showDialog(
                //       context: context,
                //       barrierColor: Colors.black,
                //       builder: (context) {
                //         CardOverlay overlay = CardOverlay.byFormat(format);
                //         return AlertDialog(
                //             actionsAlignment: MainAxisAlignment.center,
                //             backgroundColor: Colors.black,
                //             title: const Text('Capture',
                //                 style: TextStyle(color: Colors.white),
                //                 textAlign: TextAlign.center),
                //             actions: [
                //               OutlinedButton(
                //                   onPressed: () => Navigator.of(context).pop(),
                //                   child: const Icon(Icons.close))
                //             ],
                //             content: SizedBox(
                //                 width: double.infinity,
                //                 child: AspectRatio(
                //                   aspectRatio: overlay.ratio!,
                //                   child: Container(
                //                     decoration: BoxDecoration(
                //                         image: DecorationImage(
                //                       fit: BoxFit.fitWidth,
                //                       alignment: FractionalOffset.center,
                //                       image: FileImage(
                //                         File(file.path),
                //                       ),
                //                     )),
                //                   ),
                //                 )));
                //       },
                //     ),
                info:
                    'Position your ID card within the rectangle and ensure the image is perfectly readable.',
                label: 'Scanning ID Card');
          } else {
            return const Align(
                alignment: Alignment.center,
                child: Text(
                  'Fetching cameras',
                  style: TextStyle(color: Colors.black),
                ));
          }
        },
      ),
    ));
  }

  void sendImg(XFile picture) async {
    final formData = http.MultipartRequest(
        'POST', Uri.parse('http://188.166.217.149:4000/check'));
    final file = await http.MultipartFile.fromPath('file', picture.path);
    formData.files.add(file);
    final response = await formData.send().then((result) async {
      http.Response.fromStream(result).then((response) {
        print("response.statusCode:${response.statusCode}");
        if (response.statusCode == 200) {
          print("Uploaded! ");
          print('response.body::' + response.body);
          var res = identificationNumberFromJson(response.body);
          print("${res.name}");
          print("${res.ndId}");
          setState(() {
            checkTakeImg = res.status!;
          });
        }
        return identificationNumberFromJson(response.body);
      });
    }).catchError((err) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialogPlsTryAgain();
          });
      print('error : ' + err.toString());
    }).whenComplete(() {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialogPlsTryAgain();
          });
    });
  }
}

class AlertDialogPlsTryAgain extends StatelessWidget {
  const AlertDialogPlsTryAgain({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('เกิดข้อผิดพลาดเกิดขึ้น'),
      content: const Text('กรุณาลองใหม่อีกครั้ง'),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, 'Cancel'),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, 'OK'),
          child: const Text('OK'),
        ),
      ],
    );
  }
}

class AlertDialogOK extends StatelessWidget {
  const AlertDialogOK({super.key,});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // title: const Text('ID:${id}'),
      content: const Text('กรุณาลองใหม่อีกครั้ง'),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, 'OK'),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
