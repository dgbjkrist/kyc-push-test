import 'dart:io';
import 'package:image_picker/image_picker.dart';

abstract class ImagePickerService {
  Future<File?> pickImage();
}

class ImagePickerServiceImpl implements ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  @override
  Future<File?> pickImage() async {
    try {
      final picked = await _picker.pickImage(source: ImageSource.camera);
      return picked != null ? File(picked.path) : null;
    } catch (e) {
      return null;
    }
  }
}
