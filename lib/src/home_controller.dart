import 'dart:io';

import 'package:camera/camera.dart';
import 'package:camera_guide/model/identification_number.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final xFileProvider = StateProvider((ref) => File(''));
final identificationNumberProvider =
    StateProvider((ref) => IdentificationNumber());
