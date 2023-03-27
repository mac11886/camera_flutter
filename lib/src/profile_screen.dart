import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:camera_guide/model/identification_number.dart';
import 'package:camera_guide/src/home_controller.dart';
import 'package:camera_guide/src/match_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_face_api/face_api.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulHookConsumerWidget {
  const ProfileScreen({super.key});
  static const routeName = 'profile-screen';

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  var image1 = MatchFacesImage();
  var image2 = MatchFacesImage();
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
            Text("Pic :${identificationNumber.data?.pic} "),
            // Text("ID :${identificationNumber.ndId} ")
            // MatchImg()
            TextButton(
                onPressed: () {
                  context.pushNamed(MactchScreen.routeName);
                },
                child: Text("Next"))
          ],
        ));
  }
}
