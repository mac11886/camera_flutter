import 'dart:io';

import 'package:camera_guide/model/identification_number.dart';
import 'package:camera_guide/src/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ProfileScreen extends StatefulHookConsumerWidget {
  const ProfileScreen({super.key});
  static const routeName = 'profile-screen';

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final xFileState = ref.watch(xFileProvider);
    final identificationNumber = ref.watch(identificationNumberProvider);
    var txtName = TextEditingController();
    var txtId = TextEditingController();
    var txtAddress = TextEditingController();
    var txtDateOfBirth = TextEditingController();
    txtName.text = (identificationNumber.data?.name ??= "")!;
    txtId.text = (identificationNumber.data?.idCard ??= " ")!;
    txtAddress.text = (identificationNumber.data?.address ??= "")!;
    txtDateOfBirth.text = (identificationNumber.data?.dob ??= "")!;
    return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
        ),
        body: Column(
          children: [
            // Center(
            //   child: Image.file(
            //     File(xFileState.path),
            //   ),
            // ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextField(
                controller: txtName,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), labelText: "ชื่อ-นามสกุล"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextField(
                controller: txtId,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "หมายเลขบัตรประชาชน"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextField(
                controller: txtAddress,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), labelText: "ที่อยู่"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextField(
                controller: txtDateOfBirth,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), labelText: "วันเกิด"),
              ),
            ),
            // Text("Name :${identificationNumber.name} "),
            // Text("ID :${identificationNumber.ndId} ")
          ],
        ));
  }
}

class MatchImg extends StatefulWidget {
  const MatchImg({super.key});

  @override
  State<MatchImg> createState() => _MatchImgState();
}

class _MatchImgState extends State<MatchImg> {
  late final File file;

  @override
  Widget build(BuildContext context) {
    // var request = MatchFacesRequest();
    // request.images = [firstImage, secondImage];
    // FaceSDK.matchFaces(jsonEncode(request)).then((matchFacesResponse) {
    //   var response =
    //       MatchFacesResponse.fromJson(json.decode(matchFacesResponse));
    //   // ... check response?.results for results with score and similarity values.
    // });

    return const Placeholder();
  }
}
